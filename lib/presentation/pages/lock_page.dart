import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_controller.dart';

/// Única tela acessível sem biometria. Não lê nem exibe nenhum dado financeiro.
class LockPage extends ConsumerWidget {
  const LockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final busy = auth.status == AuthStatus.authenticating;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.fingerprint,
                  size: 96, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text('Finanças',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                  auth.message ?? 'Use sua impressão digital para desbloquear.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: busy
                    ? null
                    : () => ref.read(authControllerProvider.notifier).unlock(),
                icon: const Icon(Icons.lock_open),
                label: Text(busy ? 'Aguardando...' : 'Desbloquear'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
