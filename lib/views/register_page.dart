import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_controller.dart';
import '../theme/palette.dart';
import '../utils/navigation.dart';
import '../widgets/common_widgets.dart';
import '../widgets/dialogs.dart';
import '../widgets/primary_button.dart';
import 'create_pin_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final profileC = TextEditingController();
  final firstC = TextEditingController();
  final lastC = TextEditingController();
  String? profileErr, firstErr, lastErr;

  late final TapGestureRecognizer _terms = TapGestureRecognizer()
    ..onTap = () => showLegal(
      context,
      'Terms of Use',
      'LISTOWN is a personal expense tracker. You are responsible for the '
          'accuracy of the information you enter and for keeping your PIN private.\n\n'
          '(Placeholder text: replace with your final Terms of Use.)',
    );
  late final TapGestureRecognizer _privacy = TapGestureRecognizer()
    ..onTap = () => showLegal(
      context,
      'Privacy Policy',
      'Your profile name, name and expenses are kept on this device. '
          'LISTOWN does not ask for your phone number.\n\n'
          '(Placeholder text: replace with your final Privacy Policy.)',
    );
  late final TapGestureRecognizer _sharing = TapGestureRecognizer()
    ..onTap = () => showLegal(
      context,
      'Data Sharing Agreement',
      'LISTOWN does not share your data with third parties in this version.\n\n'
          '(Placeholder text: replace with your final Data Sharing Agreement.)',
    );

  @override
  void dispose() {
    profileC.dispose();
    firstC.dispose();
    lastC.dispose();
    _terms.dispose();
    _privacy.dispose();
    _sharing.dispose();
    super.dispose();
  }

  static final _profileRe = RegExp(r'^[A-Za-z0-9_.]{3,20}$');
  static final _nameRe = RegExp(r"^[A-Za-z][A-Za-z .'\-]{0,29}$");

  void _next() {
    final pr = profileC.text.trim();
    final fn = firstC.text.trim();
    final ln = lastC.text.trim();
    final taken = ref.read(appControllerProvider).find(pr) != null;
    final pe = !_profileRe.hasMatch(pr)
        ? '3–20 letters, numbers, "_" or "."'
        : taken
        ? 'That profile name is already taken'
        : null;
    final fe = _nameRe.hasMatch(fn) ? null : 'Enter your first name';
    final le = _nameRe.hasMatch(ln) ? null : 'Enter your last name';
    if (pe != null || fe != null || le != null) {
      setState(() {
        profileErr = pe;
        firstErr = fe;
        lastErr = le;
      });
      return;
    }
    go(context, CreatePinPage(profile: pr, first: fn, last: ln));
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final linkStyle = TextStyle(
      color: p.on,
      fontWeight: FontWeight.w800,
      decoration: TextDecoration.underline,
    );
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            Text(
              'Create your\nprofile',
              style: TextStyle(
                color: p.on,
                fontSize: 32,
                height: 1.1,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Just a few details to get you started.',
              style: TextStyle(color: p.mut, fontSize: 15),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: profileC,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_.]')),
                LengthLimitingTextInputFormatter(20),
              ],
              onChanged: (_) => setState(() => profileErr = null),
              style: TextStyle(color: p.on, fontSize: 16),
              decoration: fieldDec(p, 'Profile name', error: profileErr),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: firstC,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              inputFormatters: [LengthLimitingTextInputFormatter(30)],
              onChanged: (_) => setState(() => firstErr = null),
              style: TextStyle(color: p.on, fontSize: 16),
              decoration: fieldDec(p, 'First name', error: firstErr),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lastC,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              inputFormatters: [LengthLimitingTextInputFormatter(30)],
              onChanged: (_) => setState(() => lastErr = null),
              onSubmitted: (_) => _next(),
              style: TextStyle(color: p.on, fontSize: 16),
              decoration: fieldDec(p, 'Last name', error: lastErr),
            ),
            const SizedBox(height: 22),
            Text.rich(
              TextSpan(
                style: TextStyle(color: p.on, fontSize: 13, height: 1.45),
                children: [
                  const TextSpan(text: "By continuing you agree to LISTOWN's "),
                  TextSpan(
                    text: 'Terms of Use',
                    style: linkStyle,
                    recognizer: _terms,
                  ),
                  const TextSpan(text: ', '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: linkStyle,
                    recognizer: _privacy,
                  ),
                  const TextSpan(text: ', and '),
                  TextSpan(
                    text: 'Data Sharing Agreement',
                    style: linkStyle,
                    recognizer: _sharing,
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(label: 'Continue', onPressed: _next),
          ],
        ),
      ),
    );
  }
}
