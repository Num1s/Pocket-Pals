import 'package:flutter/material.dart';

class PetSpecies {
  const PetSpecies({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.color,
    required this.defaultName,
  });

  final String id;
  final String name;
  final String emoji;
  final String description;
  final Color color;
  final String defaultName;
}

const petSpeciesCatalog = <PetSpecies>[
  PetSpecies(
    id: 'capybara',
    name: 'Capybara',
    emoji: '🧡',
    description: 'A calm little sunshine who loves cozy days.',
    color: Color(0xFFE7A477),
    defaultName: 'Milo',
  ),
  PetSpecies(
    id: 'cat',
    name: 'Cat',
    emoji: '🐱',
    description: 'A curious nap champion with a big purr.',
    color: Color(0xFFAAA9E8),
    defaultName: 'Mochi',
  ),
  PetSpecies(
    id: 'dog',
    name: 'Dog',
    emoji: '🐶',
    description: 'Your loyal best friend, always ready to play.',
    color: Color(0xFF8AB9A0),
    defaultName: 'Biscuit',
  ),
  PetSpecies(
    id: 'bunny',
    name: 'Bunny',
    emoji: '🐰',
    description: 'A gentle hop of joy who adores crunchy snacks.',
    color: Color(0xFFE69BA7),
    defaultName: 'Clover',
  ),
  PetSpecies(
    id: 'fox',
    name: 'Fox',
    emoji: '🦊',
    description: 'A clever forest friend with a playful streak.',
    color: Color(0xFFE79A63),
    defaultName: 'Pip',
  ),
];

PetSpecies speciesFor(String? id) => petSpeciesCatalog.firstWhere(
  (species) => species.id == id,
  orElse: () => petSpeciesCatalog.first,
);
