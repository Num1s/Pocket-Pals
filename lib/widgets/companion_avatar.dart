import 'package:flutter/material.dart';

import '../models/cosmetic_catalog.dart';
import '../models/pet_catalog.dart';
import '../models/pet_mood.dart';
import 'capybara.dart';

class CompanionAvatar extends StatelessWidget {
  const CompanionAvatar({
    required this.speciesId,
    required this.mood,
    required this.equippedItems,
    super.key,
  });

  final String? speciesId;
  final PetMood mood;
  final Map<String, String> equippedItems;

  @override
  Widget build(BuildContext context) {
    final species = speciesFor(speciesId);
    final head = cosmeticFor(equippedItems[CosmeticSlot.head.name]);
    final neck = cosmeticFor(equippedItems[CosmeticSlot.neck.name]);
    return SizedBox(
      width: 190,
      height: 176,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (species.id == 'capybara')
            Capybara(mood: mood)
          else
            AnimatedScale(
              scale: mood == PetMood.playing ? 1.09 : 1,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              child: Text(
                _moodEmoji(species.id, mood),
                style: const TextStyle(fontSize: 124, height: 1),
              ),
            ),
          if (head != null)
            Positioned(
              top: 0,
              right: 39,
              child: Text(head.emoji, style: const TextStyle(fontSize: 31)),
            ),
          if (neck != null)
            Positioned(
              bottom: 13,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E9).withValues(alpha: .92),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(neck.emoji, style: const TextStyle(fontSize: 23)),
              ),
            ),
        ],
      ),
    );
  }

  String _moodEmoji(String id, PetMood mood) {
    if (mood == PetMood.playing) {
      return switch (id) {
        'cat' => '😸',
        'dog' => '🐕',
        'bunny' => '🐇',
        _ => speciesFor(id).emoji,
      };
    }
    if (mood == PetMood.eating) return '😋';
    if (mood == PetMood.sleeping) return '😴';
    return speciesFor(id).emoji;
  }
}
