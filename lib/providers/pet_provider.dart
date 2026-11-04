import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pet_mood.dart';
import '../models/pet_state.dart';
import '../models/pet_chat_message.dart';
import '../models/pet_catalog.dart';
import '../models/cosmetic_catalog.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(),
);

/// AsyncNotifier loads the saved pet once, then exposes all game actions.
final petProvider = AsyncNotifierProvider<PetNotifier, PetState>(
  PetNotifier.new,
);
final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

class PetNotifier extends AsyncNotifier<PetState> {
  Timer? _decayTimer;
  Timer? _moodTimer;
  bool _updating = false;

  StorageService get _storage => ref.read(storageServiceProvider);

  @override
  Future<PetState> build() async {
    ref.onDispose(() {
      _decayTimer?.cancel();
      _moodTimer?.cancel();
    });

    final now = DateTime.now();
    final stored = await _storage.loadPet();
    // A temporary animation mood should not survive closing the app.
    final initial = (stored ?? PetState.initial(now))
        .copyWith(mood: PetMood.idle)
        .advanceTo(now);
    await _save(initial);

    _decayTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      unawaited(refreshFromClock());
    });
    return initial;
  }

  /// Recalculates needs from the last persisted timestamp. Safe to call on
  /// launch, resume, user action, and during the foreground minute timer.
  Future<void> refreshFromClock() async {
    if (_updating || !state.hasValue) return;
    _updating = true;
    try {
      final next = state.requireValue.advanceTo(DateTime.now());
      if (next.lastInteractionTime != state.requireValue.lastInteractionTime) {
        state = AsyncData(next);
        await _save(next);
      }
    } finally {
      _updating = false;
    }
  }

  Future<void> act(PetMood action) async {
    final pet = _claimDailyCareReward(await _advanceCurrent());
    var next = pet.copyWith(mood: action);
    switch (action) {
      case PetMood.eating:
        next = next.copyWith(
          hunger: _bound(next.hunger - 24),
          energy: _bound(next.energy + 3),
        );
        break;
      case PetMood.playing:
        next = next.copyWith(
          happiness: _bound(next.happiness + 20),
          energy: _bound(next.energy - 8),
        );
        break;
      case PetMood.sleeping:
        next = next.copyWith(
          energy: _bound(next.energy + 24),
          happiness: _bound(next.happiness + 2),
        );
        break;
      case PetMood.idle:
        break;
    }
    await _publish(next);
    _moodTimer?.cancel();
    _moodTimer = Timer(const Duration(seconds: 3), () {
      if (state.hasValue) {
        unawaited(_publish(state.requireValue.copyWith(mood: PetMood.idle)));
      }
    });
  }

  Future<void> feed() => act(PetMood.eating);
  Future<void> play() => act(PetMood.playing);
  Future<void> sleep() => act(PetMood.sleeping);

  Future<void> setPetName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final pet = await _advanceCurrent();
    await _publish(pet.copyWith(name: trimmed.toUpperCase()));
  }

  Future<void> chooseSpecies(String speciesId) async {
    final species = petSpeciesCatalog.where((item) => item.id == speciesId);
    if (species.isEmpty) return;
    final pet = await _advanceCurrent();
    await _publish(
      pet.copyWith(
        speciesId: species.first.id,
        name: species.first.defaultName.toUpperCase(),
      ),
    );
  }

  Future<bool> buyCosmetic(String itemId) async {
    final item = cosmeticFor(itemId);
    if (item == null) return false;
    final pet = await _advanceCurrent();
    if (pet.ownedItemIds.contains(itemId)) {
      await equipCosmetic(itemId);
      return true;
    }
    if (pet.coins < item.price) return false;
    final nextOwned = [...pet.ownedItemIds, itemId];
    final nextEquipped = {...pet.equippedItems, item.slot.name: itemId};
    await _publish(
      pet.copyWith(
        coins: pet.coins - item.price,
        ownedItemIds: nextOwned,
        equippedItems: nextEquipped,
      ),
    );
    return true;
  }

  Future<void> equipCosmetic(String itemId) async {
    final item = cosmeticFor(itemId);
    if (item == null) return;
    final pet = await _advanceCurrent();
    if (!pet.ownedItemIds.contains(itemId)) return;
    await _publish(
      pet.copyWith(
        equippedItems: {...pet.equippedItems, item.slot.name: itemId},
      ),
    );
  }

  Future<void> unequipSlot(CosmeticSlot slot) async {
    final pet = await _advanceCurrent();
    final next = {...pet.equippedItems}..remove(slot.name);
    await _publish(pet.copyWith(equippedItems: next));
  }

  Future<void> sendMessage(String text) async {
    final message = text.trim();
    if (message.isEmpty) return;
    final pet = await _advanceCurrent();
    final species = speciesFor(pet.speciesId);
    final now = DateTime.now();
    final userMessage = PetChatMessage(
      id: '${now.microsecondsSinceEpoch}-user',
      text: message,
      fromPet: false,
      createdAt: now,
    );
    final reply = ref
        .read(chatServiceProvider)
        .reply(
          species: species,
          petName: pet.name,
          mood: pet.mood,
          message: message,
        );
    final petMessage = PetChatMessage(
      id: '${now.microsecondsSinceEpoch}-pet',
      text: reply,
      fromPet: true,
      createdAt: now.add(const Duration(milliseconds: 1)),
    );
    final messages = [...pet.chatMessages, userMessage, petMessage];
    await _publish(
      pet.copyWith(
        chatMessages: messages.length > 80
            ? messages.sublist(messages.length - 80)
            : messages,
        happiness: _bound(pet.happiness + 1),
      ),
    );
  }

  Future<void> setAutoDecay(bool enabled) async {
    final pet = await _advanceCurrent();
    await _publish(pet.copyWith(autoDecayEnabled: enabled));
  }

  Future<void> incrementAge() async {
    final pet = await _advanceCurrent();
    await _publish(
      pet.copyWith(
        currentDay: pet.currentDay + 1,
        createdAt: pet.createdAt.subtract(const Duration(days: 1)),
      ),
    );
  }

  Future<void> fullCare() async {
    final pet = await _advanceCurrent();
    await _publish(pet.copyWith(hunger: 0, happiness: 100, energy: 100));
  }

  Future<void> resetStats() async {
    final pet = await _advanceCurrent();
    await _publish(
      PetState.initial().copyWith(
        name: pet.name,
        speciesId: pet.speciesId,
        currentDay: pet.currentDay,
        createdAt: pet.createdAt,
        autoDecayEnabled: pet.autoDecayEnabled,
        coins: pet.coins,
        ownedItemIds: pet.ownedItemIds,
        equippedItems: pet.equippedItems,
        chatMessages: pet.chatMessages,
        lastRewardDate: pet.lastRewardDate,
      ),
    );
  }

  Future<PetState> _advanceCurrent() async {
    await refreshFromClock();
    if (!state.hasValue) throw StateError('Pet state has not loaded yet.');
    return state.requireValue;
  }

  Future<void> _publish(PetState next) async {
    state = AsyncData(next);
    await _save(next);
  }

  Future<void> _save(PetState pet) async {
    try {
      await _storage.savePet(pet);
    } catch (error, stackTrace) {
      // Keep the in-memory game responsive if device storage is temporarily unavailable.
      debugPrint('Unable to save Pocket Pals state: $error\n$stackTrace');
    }
  }

  double _bound(double value) => value.clamp(0, 100).toDouble();

  PetState _claimDailyCareReward(PetState pet) {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (pet.lastRewardDate == today) return pet;
    return pet.copyWith(coins: pet.coins + 20, lastRewardDate: today);
  }
}
