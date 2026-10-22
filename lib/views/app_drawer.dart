import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_controller.dart';
import '../theme/palette.dart';
import '../utils/navigation.dart';
import '../widgets/app_logo.dart';
import '../widgets/dialogs.dart';
import '../widgets/wordmark.dart';
import 'dashboard_page.dart';
import 'expense_form_page.dart';
import 'expenses_page.dart';
import 'login_page.dart';
import 'onboarding_page.dart';
import 'savings_list_page.dart';
import 'settings_page.dart';

class AppDrawer extends ConsumerWidget {
  final BuildContext homeContext;
  const AppDrawer({super.key, required this.homeContext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Palette.of(context);
    final s = ref.watch(appControllerProvider);
    final ctrl = ref.read(appControllerProvider.notifier);

    Widget item(IconData icon, String label, VoidCallback onTap) => ListTile(
      leading: Icon(icon, color: p.on),
      title: Text(
        label,
        style: TextStyle(
          color: p.on,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      shape: const StadiumBorder(),
      onTap: () {
        Navigator.pop(context); // close drawer
        onTap();
      },
    );

    final fullName = '${s.firstName} ${s.lastName}'.trim();

    return Drawer(
      backgroundColor: p.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0, 8, 0, 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: p.pri,
                ),
                child: Row(
                  children: [
                    const AppLogo(44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wordmark(size: 22, color: p.onPri),
                          if (fullName.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: p.onPri,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '@${s.profileName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: fade(p.onPri, .8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              item(
                Icons.dashboard_outlined,
                'Dashboard',
                () => go(homeContext, const DashboardPage()),
              ),
              item(
                Icons.receipt_long_outlined,
                'Expenses',
                () => go(homeContext, const ExpensesPage()),
              ),
              item(
                Icons.add,
                'Add expense',
                () => go(homeContext, const ExpenseFormPage()),
              ),
              item(
                Icons.savings_outlined,
                'Savings challenge',
                () => go(homeContext, const SavingsListPage()),
              ),
              item(
                Icons.calculate_outlined,
                'Currency converter',
                () => showConverter(homeContext, s.disp),
              ),
              Divider(color: p.line, height: 16),
              item(
                Icons.settings_outlined,
                'Settings',
                () => go(homeContext, const SettingsPage()),
              ),
              item(Icons.switch_account_outlined, 'Switch account', () {
                ctrl.logOut();
                goRoot(homeContext, const LoginPage());
              }),
              item(Icons.lock_outline_rounded, 'Log out', () {
                ctrl.logOut();
                goRoot(homeContext, const OnboardingPage());
              }),
            ],
          ),
        ),
      ),
    );
  }
}
