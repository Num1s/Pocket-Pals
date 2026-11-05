import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pet_mood.dart';
import '../models/pet_catalog.dart';
import '../providers/pet_provider.dart';
import '../themes/app_colors.dart';
import '../widgets/capybara.dart';

class PetSelectionScreen extends ConsumerWidget {
  const PetSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
            children: [
              const Text(
                'YOUR NEW\nBEST FRIEND',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 31,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Pick a companion. You can name them and make their little world your own.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.ink.withValues(alpha: .72),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: petSpeciesCatalog.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: .89,
                ),
                itemBuilder: (context, index) {
                  final species = petSpeciesCatalog[index];
                  return Material(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () async {
                        await ref
                            .read(petProvider.notifier)
                            .chooseSpecies(species.id);
                        if (!context.mounted) return;
                        // The home screen reacts to the provider change. When
                        // this chooser was opened from settings, close it so
                        // the updated pet is visible immediately.
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: species.color.withValues(alpha: .65),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 86,
                              height: 86,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: species.color.withValues(alpha: .24),
                                shape: BoxShape.circle,
                              ),
                              child: species.id == 'capybara'
                                  ? Transform.scale(
                                      scale: .48,
                                      child: const Capybara(mood: PetMood.idle),
                                    )
                                  : Text(
                                      species.emoji,
                                      style: const TextStyle(fontSize: 48),
                                    ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              species.name,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              species.description,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.ink.withValues(alpha: .68),
                                fontSize: 10,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 17),
              const Text(
                'Your choice is saved on this device.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
