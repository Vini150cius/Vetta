import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: onPrevious,
              tooltip: 'Anterior'),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: onNext,
              tooltip: 'Próximo'),
        ],
      );
}
