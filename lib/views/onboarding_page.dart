import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/palette.dart';
import '../utils/navigation.dart';
import '../widgets/common_widgets.dart';
import '../widgets/dialogs.dart';
import '../widgets/onboarding_widgets.dart';
import '../widgets/primary_button.dart';
import '../widgets/wordmark.dart';
import 'login_page.dart';
import 'register_page.dart';

/// First screen. Holds only local UI state (current slide), so it stays a
/// plain StatefulWidget.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pc = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _goTo(int i) => _pc.animateToPage(
    i,
    duration: const Duration(milliseconds: 320),
    curve: Curves.easeOut,
  );

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final slide = onboardingSlides[_page];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: p.surface,
            systemNavigationBarIconBrightness: dark
                ? Brightness.light
                : Brightness.dark,
          ),
      child: Scaffold(
        backgroundColor: p.surface,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, cs) {
              final heroH = (cs.maxHeight * .40).clamp(230.0, 400.0).toDouble();
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: cs.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Entrance(
                              dy: -10,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Wordmark(size: 40),
                                  IconButton(
                                    tooltip: 'Help',
                                    iconSize: 28,
                                    color: p.on,
                                    onPressed: () => showHelpSheet(context),
                                    icon: const Icon(
                                      Icons.help_outline_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Entrance(
                              ms: 700,
                              child: SizedBox(
                                height: heroH,
                                child: PageView.builder(
                                  controller: _pc,
                                  itemCount: onboardingSlides.length,
                                  onPageChanged: (i) =>
                                      setState(() => _page = i),
                                  itemBuilder: (_, i) =>
                                      HeroPage(slide: onboardingSlides[i]),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            PageDots(
                              count: onboardingSlides.length,
                              index: _page,
                              onTap: _goTo,
                            ),
                          ],
                        ),
                        Entrance(
                          ms: 800,
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: Column(
                                  key: ValueKey(_page),
                                  children: [
                                    Text(
                                      slide.headline,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: p.on,
                                        fontSize: 28,
                                        height: 1.15,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      slide.body,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: p.mut,
                                        fontSize: 15,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),
                              PrimaryButton(
                                label: "Let's Get Started",
                                onPressed: () =>
                                    go(context, const RegisterPage()),
                              ),
                              const SizedBox(height: 4),
                              TextButton(
                                onPressed: () => go(context, const LoginPage()),
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Already have an account? ',
                                    style: TextStyle(color: p.on, fontSize: 15),
                                    children: const [
                                      TextSpan(
                                        text: 'Log in',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    size: 18,
                                    color: p.on,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Your data stays on this device',
                                      style: TextStyle(
                                        color: p.on,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
