import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class PeriodNavigator extends StatelessWidget {
  const PeriodNavigator(
      {super.key,
      required this.label,
      required this.onPrevious,
      required this.onNext});

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            _RoundButton(
                icon: Icons.chevron_left_rounded,
                tooltip: 'Anterior',
                onTap: onPrevious),
            Expanded(
              child: Center(
                child:
                    Text(label, style: Theme.of(context).textTheme.titleMedium),
              ),
            ),
            _RoundButton(
                icon: Icons.chevron_right_rounded,
                tooltip: 'Próximo',
                onTap: onNext),
          ],
        ),
      );
}

class _RoundButton extends StatelessWidget {
  const _RoundButton(
      {required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppTheme.primary.withAlpha(26),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child:
              SizedBox(width: 40, height: 40, child: Icon(icon, color: color)),
        ),
      ),
    );
  }
}
