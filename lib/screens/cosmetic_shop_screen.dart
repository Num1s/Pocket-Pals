import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cosmetic_catalog.dart';
import '../providers/pet_provider.dart';
import '../themes/app_colors.dart';

class CosmeticShopScreen extends ConsumerWidget {
  const CosmeticShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(petProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Little shop',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.ink),
        actions: [
          if (pet.hasValue)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: _CoinPill(coins: pet.requireValue.coins)),
            ),
        ],
      ),
      body: pet.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Could not load the shop: $error')),
        data: (state) => ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                'A little treat for your little friend ✨\nEarn 20 acorns the first time you care for your pet each day.',
                style: TextStyle(
                  color: AppColors.ink,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            for (final slot in CosmeticSlot.values) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _slotTitle(slot),
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              for (final item in cosmeticCatalog.where(
                (item) => item.slot == slot,
              ))
                _ShopItemTile(
                  item: item,
                  owned: state.ownedItemIds.contains(item.id),
                  equipped: state.equippedItems[slot.name] == item.id,
                  coins: state.coins,
                  onPressed: () async {
                    final notifier = ref.read(petProvider.notifier);
                    if (state.ownedItemIds.contains(item.id)) {
                      await notifier.equipCosmetic(item.id);
                    } else {
                      final success = await notifier.buyCosmetic(item.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? '${item.name} is yours!'
                                  : 'Care for your pet to earn more acorns.',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                ),
              const SizedBox(height: 18),
            ],
          ],
        ),
      ),
    );
  }

  String _slotTitle(CosmeticSlot slot) => switch (slot) {
    CosmeticSlot.head => 'For their head',
    CosmeticSlot.neck => 'Little accessories',
    CosmeticSlot.room => 'Make a cozy home',
  };
}

class _ShopItemTile extends StatelessWidget {
  const _ShopItemTile({
    required this.item,
    required this.owned,
    required this.equipped,
    required this.coins,
    required this.onPressed,
  });
  final CosmeticItem item;
  final bool owned;
  final bool equipped;
  final int coins;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(19),
    ),
    child: Row(
      children: [
        Container(
          width: 54,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(item.emoji, style: const TextStyle(fontSize: 28)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.ink.withValues(alpha: .7),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                owned ? 'OWNED' : '🌰 ${item.price}',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 82,
          child: FilledButton(
            onPressed: equipped ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: owned
                  ? const Color(0xFF78A489)
                  : const Color(0xFFE98E76),
              disabledBackgroundColor: const Color(0xFFC9D9C4),
              padding: const EdgeInsets.symmetric(horizontal: 5),
            ),
            child: Text(
              equipped
                  ? 'On pet'
                  : owned
                  ? 'Wear'
                  : coins < item.price
                  ? 'Need more'
                  : 'Get',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ),
      ],
    ),
  );
}

class _CoinPill extends StatelessWidget {
  const _CoinPill({required this.coins});
  final int coins;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      '🌰 $coins',
      style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w900),
    ),
  );
}
