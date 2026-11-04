import '../models/pet_mood.dart';
import 'pet_chat_message.dart';

/// Immutable game state. Stats use doubles so short time intervals are not lost
/// to rounding; the UI can display rounded whole numbers.
class PetState {
  const PetState({
    required this.hunger,
    required this.happiness,
    required this.energy,
    required this.currentDay,
    required this.lastInteractionTime,
    required this.createdAt,
    this.speciesId,
    this.coins = 120,
    this.ownedItemIds = const [],
    this.equippedItems = const {},
    this.chatMessages = const [],
    this.lastRewardDate,
    this.name = 'MILO',
    this.mood = PetMood.idle,
    this.autoDecayEnabled = true,
  });

  final double hunger;
  final double happiness;
  final double energy;
  final int currentDay;
  final DateTime lastInteractionTime;
  final DateTime createdAt;
  final String? speciesId;
  final int coins;
  final List<String> ownedItemIds;

  /// Equipped cosmetic ID keyed by slot name (head, neck, room).
  final Map<String, String> equippedItems;
  final List<PetChatMessage> chatMessages;
  final String? lastRewardDate;
  final String name;
  final PetMood mood;
  final bool autoDecayEnabled;

  factory PetState.initial([DateTime? time]) {
    final now = time ?? DateTime.now();
    return PetState(
      hunger: 34,
      happiness: 78,
      energy: 72,
      currentDay: 1,
      lastInteractionTime: now,
      createdAt: now,
    );
  }

  /// Applies needs decay for the real elapsed duration, including time spent
  /// with the app closed. Rates are measured per hour.
  PetState advanceTo(DateTime now) {
    if (!now.isAfter(lastInteractionTime)) return this;
    final hours =
        now.difference(lastInteractionTime).inMicroseconds /
        Duration.microsecondsPerHour;
    final livedDays = now.difference(createdAt).inDays + 1;
    return copyWith(
      hunger: _bound(hunger + (autoDecayEnabled ? 12 * hours : 0)),
      energy: _bound(energy - (autoDecayEnabled ? 10 * hours : 0)),
      happiness: _bound(happiness - (autoDecayEnabled ? 5 * hours : 0)),
      currentDay: livedDays < 1 ? 1 : livedDays,
      lastInteractionTime: now,
    );
  }

  PetState copyWith({
    double? hunger,
    double? happiness,
    double? energy,
    int? currentDay,
    DateTime? lastInteractionTime,
    DateTime? createdAt,
    String? speciesId,
    int? coins,
    List<String>? ownedItemIds,
    Map<String, String>? equippedItems,
    List<PetChatMessage>? chatMessages,
    String? lastRewardDate,
    String? name,
    PetMood? mood,
    bool? autoDecayEnabled,
  }) => PetState(
    hunger: hunger ?? this.hunger,
    happiness: happiness ?? this.happiness,
    energy: energy ?? this.energy,
    currentDay: currentDay ?? this.currentDay,
    lastInteractionTime: lastInteractionTime ?? this.lastInteractionTime,
    createdAt: createdAt ?? this.createdAt,
    speciesId: speciesId ?? this.speciesId,
    coins: coins ?? this.coins,
    ownedItemIds: ownedItemIds ?? this.ownedItemIds,
    equippedItems: equippedItems ?? this.equippedItems,
    chatMessages: chatMessages ?? this.chatMessages,
    lastRewardDate: lastRewardDate ?? this.lastRewardDate,
    name: name ?? this.name,
    mood: mood ?? this.mood,
    autoDecayEnabled: autoDecayEnabled ?? this.autoDecayEnabled,
  );

  Map<String, Object?> toJson() => {
    'hunger': hunger,
    'happiness': happiness,
    'energy': energy,
    'currentDay': currentDay,
    'lastInteractionTime': lastInteractionTime.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'speciesId': speciesId,
    'coins': coins,
    'ownedItemIds': ownedItemIds,
    'equippedItems': equippedItems,
    'chatMessages': chatMessages.map((message) => message.toJson()).toList(),
    'lastRewardDate': lastRewardDate,
    'name': name,
    'mood': mood.name,
    'autoDecayEnabled': autoDecayEnabled,
  };

  factory PetState.fromJson(Map<String, dynamic> json) {
    DateTime date(String key, DateTime fallback) =>
        DateTime.tryParse(json[key] as String? ?? '') ?? fallback;
    final now = DateTime.now();
    final initial = PetState.initial(now);
    final moodName = json['mood'];
    final mood = PetMood.values.where((value) => value.name == moodName);
    final rawMessages = json['chatMessages'];
    double stat(String key, double fallback) =>
        ((json[key] as num?)?.toDouble() ?? fallback).clamp(0, 100).toDouble();
    return PetState(
      hunger: stat('hunger', initial.hunger),
      happiness: stat('happiness', initial.happiness),
      energy: stat('energy', initial.energy),
      currentDay: ((json['currentDay'] as num?)?.toInt() ?? 1)
          .clamp(1, 1 << 30)
          .toInt(),
      lastInteractionTime: date('lastInteractionTime', now),
      createdAt: date('createdAt', now),
      // Older saves had no species selection; keep those pets as capybaras.
      speciesId: json['speciesId'] as String? ?? 'capybara',
      coins: ((json['coins'] as num?)?.toInt() ?? 120)
          .clamp(0, 1 << 30)
          .toInt(),
      ownedItemIds:
          (json['ownedItemIds'] as List<dynamic>?)
              ?.whereType<String>()
              .toSet()
              .toList() ??
          const [],
      equippedItems:
          (json['equippedItems'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ) ??
          const {},
      chatMessages: rawMessages is List
          ? rawMessages
                .whereType<Map<String, dynamic>>()
                .map(PetChatMessage.fromJson)
                .toList()
          : const [],
      lastRewardDate: json['lastRewardDate'] as String?,
      name: (json['name'] as String?) ?? initial.name,
      mood: mood.isEmpty ? PetMood.idle : mood.first,
      autoDecayEnabled: (json['autoDecayEnabled'] as bool?) ?? true,
    );
  }

  static double _bound(double value) => value.clamp(0, 100).toDouble();
}
