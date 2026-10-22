import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account.dart';
import '../providers/app_controller.dart';
import '../theme/palette.dart';
import '../utils/navigation.dart';
import '../widgets/app_logo.dart';
import '../widgets/common_widgets.dart';
import '../widgets/dialogs.dart';
import '../widgets/pin_keypad.dart';
import '../widgets/primary_button.dart';
import 'home_page.dart';
import 'register_page.dart';

class AccountTile extends StatelessWidget {
  final Account a;
  final VoidCallback onTap;
  const AccountTile({super.key, required this.a, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final initial = a.firstName.isEmpty ? '?' : a.firstName[0].toUpperCase();
    return Material(
      color: p.chip,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: p.pri,
                child: Text(
                  initial,
                  style: TextStyle(
                    color: p.onPri,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.fullName.isEmpty ? '@${a.profileName}' : a.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: p.on,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '@${a.profileName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: p.mut, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: p.mut),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  final nameC = TextEditingController();

  /// Profile name being logged into. null = step 1 (choose profile),
  /// set = step 2 (PIN). The Account itself always comes from Riverpod.
  String? profile;
  String? nameErr;
  String pin = '';
  String? error;
  bool busy = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _shake.dispose();
    nameC.dispose();
    super.dispose();
  }

  String _lockMsg(int seconds) => 'Too many attempts. Try again in ${seconds}s.';

  void _startTimer(String name) {
    _timer?.cancel();
    final first = ref.read(appControllerProvider).find(name);
    if (first == null || first.lockLeft == 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final a = mounted ? ref.read(appControllerProvider).find(name) : null;
      if (!mounted || a == null || profile != a.profileName) {
        t.cancel();
        return;
      }
      if (a.lockLeft == 0) {
        t.cancel();
        ref.read(appControllerProvider.notifier).clearLock(a.profileName);
        setState(() => error = null);
      } else {
        setState(() => error = _lockMsg(a.lockLeft));
      }
    });
  }

  void _choose(Account a) {
    setState(() {
      profile = a.profileName;
      pin = '';
      nameErr = null;
      error = a.lockLeft > 0 ? _lockMsg(a.lockLeft) : null;
    });
    _startTimer(a.profileName);
  }

  void _lookup() {
    final a = ref.read(appControllerProvider).find(nameC.text);
    if (a == null) {
      setState(() {
        nameErr = nameC.text.trim().isEmpty
            ? 'Enter your profile name'
            : 'No profile with that name on this device';
      });
      return;
    }
    _choose(a);
  }

  void _changeProfile() {
    _timer?.cancel();
    setState(() {
      profile = null;
      pin = '';
      error = null;
    });
  }

  void _digit(String d) {
    final name = profile;
    if (name == null || busy || pin.length >= 4) return;
    final a = ref.read(appControllerProvider).find(name);
    if (a == null || a.lockLeft > 0) return;
    setState(() {
      pin += d;
      error = null;
    });
    if (pin.length == 4) _submit(name);
  }

  void _back() {
    final name = profile;
    if (name == null || busy || pin.isEmpty) return;
    final a = ref.read(appControllerProvider).find(name);
    if (a == null || a.lockLeft > 0) return;
    setState(() {
      pin = pin.substring(0, pin.length - 1);
      error = null;
    });
  }

  Future<void> _submit(String name) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted || profile != name) return;
    final ctrl = ref.read(appControllerProvider.notifier);
    if (ctrl.checkPin(name, pin)) {
      setState(() => busy = true);
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      ctrl.logIn(name);
      goRoot(context, const HomePage());
      return;
    }
    HapticFeedback.heavyImpact();
    _shake.forward(from: 0);
    final r = ctrl.registerFailedPin(name);
    setState(() {
      if (r.locked) {
        error = _lockMsg(AppController.lockSeconds);
      } else {
        error =
            'Incorrect PIN. ${r.triesLeft} ${r.triesLeft == 1 ? 'try' : 'tries'} left.';
      }
    });
    _startTimer(name);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted || profile != name) return;
    setState(() => pin = '');
  }

  Future<void> _forgot(Account a) async {
    final ok = await confirmDialog(
      context,
      'Reset @${a.profileName}?',
      'LISTOWN cannot recover a forgotten PIN. Resetting deletes this '
          'profile and its expenses from this device. Your other profiles '
          'are not affected.',
      'Reset',
    );
    if (!ok || !mounted) return;
    _timer?.cancel();
    ref.read(appControllerProvider.notifier).removeAccount(a.profileName);
    setState(() {
      profile = null;
      pin = '';
      error = null;
      nameC.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final s = ref.watch(appControllerProvider);

    if (!s.hasAccount) {
      return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(80),
                  const SizedBox(height: 20),
                  Text(
                    'No account on this device yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: p.on,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a profile and a 4-digit PIN to get started.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: p.mut, fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Create account',
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final name = profile;
    final a = name == null ? null : s.find(name);
    if (a == null) return _profileStep(p, s.accounts);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Use a different profile',
          icon: const Icon(Icons.arrow_back),
          onPressed: busy ? null : _changeProfile,
        ),
      ),
      body: SafeArea(
        child: PinPanel(
          title: 'Welcome back, ${a.firstName}',
          subtitle: '@${a.profileName} · Enter your 4-digit PIN',
          filled: pin.length,
          error: error,
          shake: _shake,
          enabled: !busy && a.lockLeft == 0,
          onDigit: _digit,
          onBack: _back,
          footer: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: busy
                ? const CircularProgressIndicator()
                : TextButton(
                    onPressed: () => _forgot(a),
                    child: const Text(
                      'Forgot PIN?',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _profileStep(Palette p, List<Account> accounts) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            Text(
              'Log in',
              style: TextStyle(
                color: p.on,
                fontSize: 32,
                height: 1.1,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your profile name, then your 4-digit PIN.',
              style: TextStyle(color: p.mut, fontSize: 15),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameC,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_.]')),
                LengthLimitingTextInputFormatter(20),
              ],
              onChanged: (_) {
                if (nameErr != null) setState(() => nameErr = null);
              },
              onSubmitted: (_) => _lookup(),
              style: TextStyle(color: p.on, fontSize: 16),
              decoration: fieldDec(p, 'Profile name', error: nameErr),
            ),
            const SizedBox(height: 16),
            PrimaryButton(label: 'Continue', onPressed: _lookup),
            sectionHeader(context, 'Saved on this device'),
            const SizedBox(height: 8),
            for (final x in accounts)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AccountTile(a: x, onTap: () => _choose(x)),
              ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () => go(context, const RegisterPage()),
                child: const Text(
                  'Create a new account',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
