import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/app_lifecycle.dart';
import 'themes/app_theme.dart';
import 'screens/pet_home_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notifications = NotificationService();
  await notifications.initialize();
  runApp(
    ProviderScope(
      overrides: [notificationServiceProvider.overrideWithValue(notifications)],
      child: const PetLifecycleScope(child: CapyPalApp()),
    ),
  );
}

class CapyPalApp extends StatelessWidget {
  const CapyPalApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Pocket Pals',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    home: const PetHomeScreen(),
  );
}
