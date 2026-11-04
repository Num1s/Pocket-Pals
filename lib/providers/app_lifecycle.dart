import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pet_state.dart';
import '../services/notification_service.dart';
import 'pet_provider.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

/// Connects Flutter's lifecycle callbacks to app services without putting
/// lifecycle or notification code inside the screen widgets.
class PetLifecycleScope extends ConsumerStatefulWidget {
  const PetLifecycleScope({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<PetLifecycleScope> createState() => _PetLifecycleScopeState();
}

class _PetLifecycleScopeState extends ConsumerState<PetLifecycleScope>
    with WidgetsBindingObserver {
  bool _wasBackgrounded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // A notification may have been scheduled by the previous app session.
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_onResume()));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_onResume());
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      if (!_wasBackgrounded) {
        _wasBackgrounded = true;
        unawaited(_onBackground());
      }
    }
  }

  Future<PetState> _loadAndAdvance() async {
    await ref.read(petProvider.future);
    await ref.read(petProvider.notifier).refreshFromClock();
    return ref.read(petProvider).requireValue;
  }

  Future<void> _onBackground() async {
    try {
      final pet = await _loadAndAdvance();
      final hungry = pet.hunger >= 60;
      final delay = hungry
          ? const Duration(hours: 2)
          : pet.happiness < 50
          ? const Duration(hours: 3)
          : const Duration(hours: 4);
      await ref
          .read(notificationServiceProvider)
          .scheduleCareReminder(
            delay: delay,
            hungry: hungry,
            petName: pet.name,
          );
    } catch (error) {
      debugPrint('Could not schedule a care reminder: $error');
    }
  }

  Future<void> _onResume() async {
    _wasBackgrounded = false;
    try {
      await ref.read(notificationServiceProvider).cancelCareReminder();
      await _loadAndAdvance();
    } catch (error) {
      debugPrint('Could not refresh companion after resume: $error');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
