import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pet_mood.dart';
import '../models/pet_state.dart';
import '../models/cosmetic_catalog.dart';
import '../providers/pet_provider.dart';
import '../themes/app_colors.dart';
import '../widgets/companion_avatar.dart';
import 'cosmetic_shop_screen.dart';
import 'pet_chat_screen.dart';
import 'pet_selection_screen.dart';
import 'settings_screen.dart';

class PetHomeScreen extends ConsumerWidget {
  const PetHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petProvider);
    return petState.when(
      data: (pet) => pet.speciesId == null
          ? const PetSelectionScreen()
          : _gameScreen(context, ref, pet),
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.ink)),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Could not load your companion: $error')),
      ),
    );
  }

  Widget _gameScreen(BuildContext context, WidgetRef ref, PetState pet) =>
      Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final scale = (constraints.maxHeight / 780).clamp(
                      0.72,
                      1.0,
                    );
                    final width = constraints.maxWidth.clamp(280.0, 390.0);
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Transform.scale(
                        scale: scale,
                        child: SizedBox(width: width, child: _device(ref, pet)),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _topAction(
                      context,
                      Icons.storefront_rounded,
                      const CosmeticShopScreen(),
                    ),
                    _topAction(
                      context,
                      Icons.chat_bubble_rounded,
                      const PetChatScreen(),
                    ),
                    _topAction(
                      context,
                      Icons.settings_rounded,
                      const SettingsScreen(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _device(WidgetRef ref, PetState pet) => Container(
    padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
    decoration: BoxDecoration(
      color: const Color(0xFFFF9F7F),
      borderRadius: BorderRadius.circular(42),
      border: Border.all(color: const Color(0xFFE77861), width: 5),
      boxShadow: const [
        BoxShadow(
          color: Color(0xFFCE8267),
          offset: Offset(0, 10),
          blurRadius: 0,
        ),
        BoxShadow(
          color: Color(0x339C654F),
          offset: Offset(0, 16),
          blurRadius: 22,
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/pocket_pals_logo.png',
              width: 30,
              height: 30,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(width: 8),
            Text(
              'POCKET PALS',
              style: TextStyle(
                color: AppColors.cream,
                fontSize: 18,
                letterSpacing: 3,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: Colors.brown.withValues(alpha: .18),
                    offset: const Offset(1, 2),
                    blurRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF52695B),
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(color: Color(0xFF344B41), offset: Offset(0, 5)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Container(
              color:
                  cosmeticFor(pet.equippedItems[CosmeticSlot.room.name])
                      ?.color ??
                  const Color(0xFFDDF0C8),
              padding: const EdgeInsets.fromLTRB(15, 12, 15, 13),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Color(0xFFE27876),
                        size: 19,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'DAY ${pet.currentDay}',
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '🌰 ${pet.coins}',
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 207,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Positioned(
                          left: 16,
                          top: 31,
                          child: Icon(
                            Icons.cloud,
                            color: Color(0xFFB7D9AC),
                            size: 19,
                          ),
                        ),
                        const Positioned(
                          right: 18,
                          top: 56,
                          child: Icon(
                            Icons.star,
                            color: Color(0xFFF1CF72),
                            size: 19,
                          ),
                        ),
                        const Positioned(
                          left: 33,
                          bottom: 18,
                          child: Icon(
                            Icons.grass,
                            color: Color(0xFF80AA77),
                            size: 19,
                          ),
                        ),
                        const Positioned(
                          right: 28,
                          bottom: 20,
                          child: Icon(
                            Icons.grass,
                            color: Color(0xFF80AA77),
                            size: 19,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: CompanionAvatar(
                            key: ValueKey(
                              '${pet.speciesId}-${pet.mood}-${pet.equippedItems}',
                            ),
                            speciesId: pet.speciesId,
                            mood: pet.mood,
                            equippedItems: pet.equippedItems,
                          ),
                        ),
                        if (pet.mood != PetMood.idle)
                          Positioned(top: 7, child: _moodBubble(pet.mood)),
                      ],
                    ),
                  ),
                  Text(
                    pet.name,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle(pet.mood),
                    style: const TextStyle(
                      color: Color(0xFF687E6A),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _meter(
                    'HUNGER',
                    pet.hunger,
                    const Color(0xFFE39B5E),
                    Icons.restaurant_rounded,
                  ),
                  const SizedBox(height: 6),
                  _meter(
                    'HAPPY',
                    pet.happiness,
                    const Color(0xFFE78683),
                    Icons.favorite_rounded,
                  ),
                  const SizedBox(height: 6),
                  _meter(
                    'ENERGY',
                    pet.energy,
                    const Color(0xFF7AA5B7),
                    Icons.bolt_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 17),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _actionButton(
              'FEED',
              Icons.restaurant_rounded,
              const Color(0xFFFFE49B),
              ref.read(petProvider.notifier).feed,
            ),
            _actionButton(
              'PLAY',
              Icons.sports_esports_rounded,
              const Color(0xFFBDE5C4),
              ref.read(petProvider.notifier).play,
            ),
            _actionButton(
              'SLEEP',
              Icons.nightlight_round,
              const Color(0xFFC8D6F4),
              ref.read(petProvider.notifier).sleep,
            ),
          ],
        ),
        const SizedBox(height: 11),
        const Text(
          'A LITTLE CARE GOES A LONG WAY',
          style: TextStyle(
            color: Color(0xFFFFF0DB),
            fontSize: 9,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );

  String _subtitle(PetMood mood) => switch (mood) {
    PetMood.idle => 'your cozy little buddy',
    PetMood.eating => 'nom nom, so yummy!',
    PetMood.playing => 'wheee! so much fun!',
    PetMood.sleeping => 'zzz... sweet dreams',
  };

  Widget _topAction(BuildContext context, IconData icon, Widget screen) =>
      IconButton(
        tooltip: switch (icon) {
          Icons.storefront_rounded => 'Little shop',
          Icons.chat_bubble_rounded => 'Talk to your pet',
          _ => 'Settings',
        },
        icon: Icon(icon, color: AppColors.ink),
        onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      );

  Widget _moodBubble(PetMood mood) {
    final (icon, color) = switch (mood) {
      PetMood.eating => (Icons.favorite, const Color(0xFFE78683)),
      PetMood.playing => (Icons.auto_awesome, const Color(0xFFE8B84D)),
      PetMood.sleeping => (Icons.bedtime, const Color(0xFF7796C8)),
      PetMood.idle => (Icons.favorite, const Color(0xFFE78683)),
    };
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x3346593E),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Icon(icon, size: 17, color: color),
    );
  }

  Widget _meter(String label, double value, Color color, IconData icon) => Row(
    children: [
      SizedBox(
        width: 80,
        child: Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: .6,
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: (value / 100).clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, _) => LinearProgressIndicator(
              value: animatedValue,
              minHeight: 9,
              backgroundColor: const Color(0xFFC7DDB8),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
      ),
      SizedBox(
        width: 31,
        child: Text(
          '${value.round()}',
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ],
  );

  Widget _actionButton(
    String label,
    IconData icon,
    Color color,
    Future<void> Function() onTap,
  ) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      onTap: () => onTap(),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFBA715F), width: 3),
              boxShadow: const [
                BoxShadow(color: Color(0xFFAD6556), offset: Offset(0, 5)),
              ],
            ),
            child: Icon(icon, color: AppColors.ink, size: 25),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.cream,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    ),
  );
}
