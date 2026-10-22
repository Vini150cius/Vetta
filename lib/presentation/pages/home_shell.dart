import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/curved_nav_bar.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  static const _items = [
    CurvedNavItem(icon: Icons.calendar_month_rounded, label: 'Mês'),
    CurvedNavItem(icon: Icons.bar_chart_rounded, label: 'Ano'),
    CurvedNavItem(icon: Icons.account_balance_wallet_rounded, label: 'Saldo'),
    CurvedNavItem(icon: Icons.savings_rounded, label: 'Guardado'),
    CurvedNavItem(icon: Icons.settings_rounded, label: 'Ajustes'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: shell,
        bottomNavigationBar: CurvedNavBar(
          items: _items,
          currentIndex: shell.currentIndex,
          onTap: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
        ),
      );
}
