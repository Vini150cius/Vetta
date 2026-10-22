import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_controller.dart';
import 'presentation/providers/theme_controller.dart';

class FinancasApp extends ConsumerWidget {
  const FinancasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Finanças',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeControllerProvider),
      routerConfig: ref.watch(routerProvider),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) =>
          LifecycleGate(child: child ?? const SizedBox()),
    );
  }
}

/// Dispara a biometria na abertura e ao voltar do segundo plano, e TRAVA o app
/// (fecha o banco e descarta a chave da memória) sempre que ele vai para background.
class LifecycleGate extends ConsumerStatefulWidget {
  const LifecycleGate({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<LifecycleGate> createState() => _LifecycleGateState();
}

class _LifecycleGateState extends ConsumerState<LifecycleGate>
    with WidgetsBindingObserver {
  // Só pede biometria ao voltar de `paused`; evita laço de prompts após cancelar.
  bool _wasPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(authControllerProvider.notifier).unlock());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final auth = ref.read(authControllerProvider.notifier);
    if (state == AppLifecycleState.paused) {
      _wasPaused = true;
      auth.lock(auto: true);
    } else if (state == AppLifecycleState.resumed && _wasPaused) {
      _wasPaused = false;
      auth.unlock();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
