import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_controller.dart';
import '../utils/navigation.dart';
import '../widgets/pin_keypad.dart';
import 'home_page.dart';

class CreatePinPage extends ConsumerStatefulWidget {
  final String profile, first, last;
  const CreatePinPage({
    super.key,
    required this.profile,
    required this.first,
    required this.last,
  });

  @override
  ConsumerState<CreatePinPage> createState() => _CreatePinPageState();
}

class _CreatePinPageState extends ConsumerState<CreatePinPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  String pin = '', first = '';
  bool confirming = false, busy = false;
  String? error;

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  void _digit(String d) {
    if (busy || pin.length >= 4) return;
    setState(() {
      pin += d;
      error = null;
    });
    if (pin.length == 4) _done();
  }

  void _back() {
    if (busy || pin.isEmpty) return;
    setState(() {
      pin = pin.substring(0, pin.length - 1);
      error = null;
    });
  }

  Future<void> _done() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;
    if (!confirming) {
      setState(() {
        first = pin;
        pin = '';
        confirming = true;
      });
      return;
    }
    if (pin != first) {
      HapticFeedback.heavyImpact();
      _shake.forward(from: 0);
      setState(() {
        error = "PINs don't match. Start again.";
      });
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() {
        pin = '';
        first = '';
        confirming = false;
      });
      return;
    }
    setState(() => busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    ref
        .read(appControllerProvider.notifier)
        .register(
          profileName: widget.profile,
          firstName: widget.first,
          lastName: widget.last,
          pin: pin,
        );
    goRoot(context, const HomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: PinPanel(
          title: confirming ? 'Confirm your PIN' : 'Create your PIN',
          subtitle: confirming
              ? 'Enter the same 4 digits again.'
              : "You'll use these 4 digits to log in.",
          filled: pin.length,
          error: error,
          shake: _shake,
          enabled: !busy,
          onDigit: _digit,
          onBack: _back,
          footer: busy
              ? const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: CircularProgressIndicator(),
                )
              : null,
        ),
      ),
    );
  }
}
