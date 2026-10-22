import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/app_controller.dart';
import 'theme/app_theme.dart';
import 'theme/palette.dart';
import 'views/onboarding_page.dart';

void main() => runApp(const ProviderScope(child: ExpenseApp()));

class ExpenseApp extends ConsumerWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      appControllerProvider.select((s) => s.themeMode),
    );
    return MaterialApp(
      title: 'LISTOWN',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: buildTheme(Palette.light, Brightness.light),
      darkTheme: buildTheme(Palette.dark, Brightness.dark),
      home: const OnboardingPage(),
    );
  }
}
