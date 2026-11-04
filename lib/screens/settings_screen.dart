import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pet_catalog.dart';
import '../providers/pet_provider.dart';
import '../themes/app_colors.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    ref.read(petProvider.future).then((pet) {
      if (mounted) _nameController.text = pet.name;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Pet Profile',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      body: pet.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load pet: $error')),
        data: (state) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBA715F), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${state.name} · Day ${state.currentDay}',
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${speciesFor(state.speciesId).name} companion  ·  🌰 ${state.coins} acorns',
                    style: TextStyle(
                      color: AppColors.ink.withValues(alpha: .72),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Hunger ${state.hunger.round()}%   ·   Happy ${state.happiness.round()}%   ·   Energy ${state.energy.round()}%',
                    style: const TextStyle(color: AppColors.ink),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _nameController,
                    maxLength: 16,
                    decoration: const InputDecoration(
                      labelText: 'Pet name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () async {
                        await ref
                            .read(petProvider.notifier)
                            .setPetName(_nameController.text);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pet name saved!')),
                          );
                        }
                      },
                      child: const Text('Save name'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: state.autoDecayEnabled,
              activeThumbColor: AppColors.ink,
              title: const Text('Needs change over time'),
              subtitle: const Text(
                'Your companion keeps living while the app is closed.',
              ),
              onChanged: (enabled) =>
                  ref.read(petProvider.notifier).setAutoDecay(enabled),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => ref.read(petProvider.notifier).incrementAge(),
              icon: const Icon(Icons.cake_outlined),
              label: const Text('Celebrate a birthday'),
            ),
            OutlinedButton.icon(
              onPressed: () => ref.read(petProvider.notifier).fullCare(),
              icon: const Icon(Icons.favorite_outline),
              label: const Text('Give full care'),
            ),
            TextButton.icon(
              onPressed: () => ref.read(petProvider.notifier).resetStats(),
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset stats'),
            ),
          ],
        ),
      ),
    );
  }
}
