import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/pages/balance_page.dart';
import '../../presentation/pages/home_shell.dart';
import '../../presentation/pages/lock_page.dart';
import '../../presentation/pages/month_page.dart';
import '../../presentation/pages/savings_page.dart';
import '../../presentation/pages/settings_page.dart';
import '../../presentation/pages/year_page.dart';
import '../../presentation/providers/auth_controller.dart';

/// Guarda de rota: sem biometria só existe a rota /lock. As abas usam
/// StatefulShellRoute.indexedStack, mantendo o estado (rolagem, filtros) de cada aba.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen<AuthState>(authControllerProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/lock',
    refreshListenable: refresh,
    redirect: (context, state) {
      final unlocked =
          ref.read(authControllerProvider).status == AuthStatus.unlocked;
      final onLock = state.matchedLocation == '/lock';
      if (!unlocked) return onLock ? null : '/lock';
      return onLock ? '/month' : null;
    },
    routes: [
      GoRoute(path: '/lock', builder: (_, __) => const LockPage()),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/month', builder: (_, __) => const MonthPage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/year', builder: (_, __) => const YearPage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/balance', builder: (_, __) => const BalancePage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/savings', builder: (_, __) => const SavingsPage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', builder: (_, __) => const SettingsPage())
          ]),
        ],
      ),
    ],
  );
});
