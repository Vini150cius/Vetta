import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/auth_controller.dart';

/// Única tela acessível sem biometria. Não lê nem exibe nenhum dado financeiro.
class LockPage extends ConsumerWidget {
  const LockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final busy = auth.status == AuthStatus.authenticating;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 132,
                    height: 132,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(36),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo_vetta.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text('Vetta',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8)),
                  const SizedBox(height: 8),
                  Text(
                      auth.message ??
                          'Use sua impressão digital para desbloquear.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white.withAlpha(215), fontSize: 15)),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryDeep,
                      minimumSize: const Size(220, 54),
                    ),
                    onPressed: busy
                        ? null
                        : () =>
                            ref.read(authControllerProvider.notifier).unlock(),
                    icon: const Icon(Icons.lock_open_rounded),
                    label: Text(busy ? 'Aguardando...' : 'Desbloquear'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
