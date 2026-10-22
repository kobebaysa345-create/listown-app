import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_controller.dart';
import '../theme/palette.dart';
import '../utils/navigation.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_button.dart';
import '../widgets/wave_painter.dart';
import '../widgets/wordmark.dart';
import 'app_drawer.dart';
import 'dashboard_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Palette.of(context);
    final firstName = ref.watch(appControllerProvider.select((s) => s.firstName));
    return Scaffold(
      backgroundColor: p.surface,
      appBar: AppBar(),
      drawer: AppDrawer(homeContext: context),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 190,
            child: CustomPaint(
              painter: WavePainter(
                color: p.on,
                waves: const [Wave(.42, .23, .08), Wave(.63, .21, .12)],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 70),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(112),
                  const SizedBox(height: 22),
                  const Wordmark(size: 38),
                  if (firstName.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Hi, $firstName!',
                      style: TextStyle(
                        color: p.mut,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 26),
                  SizedBox(
                    width: 240,
                    child: PrimaryButton(
                      label: 'Open dashboard',
                      onPressed: () => go(context, const DashboardPage()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
