import 'package:flutter/material.dart';

enum CosmeticSlot { head, neck, room }

class CosmeticItem {
  const CosmeticItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.price,
    required this.slot,
    required this.color,
  });

  final String id;
  final String name;
  final String emoji;
  final String description;
  final int price;
  final CosmeticSlot slot;
  final Color color;
}

const cosmeticCatalog = <CosmeticItem>[
  CosmeticItem(
    id: 'daisy_crown',
    name: 'Daisy crown',
    emoji: '🌼',
    description: 'A sunny little flower crown.',
    price: 45,
    slot: CosmeticSlot.head,
    color: Color(0xFFFFE6A6),
  ),
  CosmeticItem(
    id: 'party_hat',
    name: 'Party hat',
    emoji: '🥳',
    description: 'Every day deserves a celebration.',
    price: 55,
    slot: CosmeticSlot.head,
    color: Color(0xFFF6B9A4),
  ),
  CosmeticItem(
    id: 'star_crown',
    name: 'Star crown',
    emoji: '👑',
    description: 'Royal sparkle for your best friend.',
    price: 90,
    slot: CosmeticSlot.head,
    color: Color(0xFFE7D2FF),
  ),
  CosmeticItem(
    id: 'berry_bow',
    name: 'Berry bow',
    emoji: '🎀',
    description: 'A soft pop of color.',
    price: 35,
    slot: CosmeticSlot.neck,
    color: Color(0xFFFFD2DE),
  ),
  CosmeticItem(
    id: 'leaf_scarf',
    name: 'Leaf scarf',
    emoji: '🍃',
    description: 'A little forest style.',
    price: 65,
    slot: CosmeticSlot.neck,
    color: Color(0xFFD3EBCF),
  ),
  CosmeticItem(
    id: 'cozy_scarf',
    name: 'Cozy scarf',
    emoji: '🧣',
    description: 'Warm hugs, all day long.',
    price: 80,
    slot: CosmeticSlot.neck,
    color: Color(0xFFFFD2B8),
  ),
  CosmeticItem(
    id: 'cloud_room',
    name: 'Cloud garden',
    emoji: '☁️',
    description: 'A dreamy sky-blue home.',
    price: 70,
    slot: CosmeticSlot.room,
    color: Color(0xFFD9ECF5),
  ),
  CosmeticItem(
    id: 'sunset_room',
    name: 'Peach sunset',
    emoji: '🌅',
    description: 'Golden-hour glow for your screen.',
    price: 100,
    slot: CosmeticSlot.room,
    color: Color(0xFFFFD9C5),
  ),
  CosmeticItem(
    id: 'night_room',
    name: 'Moonlit nook',
    emoji: '🌙',
    description: 'A calm lavender night sky.',
    price: 120,
    slot: CosmeticSlot.room,
    color: Color(0xFFE1DDF5),
  ),
];

CosmeticItem? cosmeticFor(String? id) {
  for (final item in cosmeticCatalog) {
    if (item.id == id) return item;
  }
  return null;
}
