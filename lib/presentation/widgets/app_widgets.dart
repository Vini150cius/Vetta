import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Cartão padrão: cantos grandes, sombra suave (claro) ou borda sutil (escuro).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    this.padding,
    this.onTap,
    this.onLongPress,
    this.radius = 22,
  });

  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: dark
          ? BorderSide(color: Colors.white.withAlpha(16))
          : BorderSide.none,
    );
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: AppTheme.primary.withAlpha(24),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: theme.colorScheme.surface,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: padding == null
              ? child
              : Padding(padding: padding!, child: child),
        ),
      ),
    );
  }
}

/// Cartão de destaque com gradiente e bolhas decorativas.
class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.child,
    this.gradient = AppTheme.heroGradient,
    this.margin = const EdgeInsets.fromLTRB(16, 8, 16, 8),
  });

  final Widget child;
  final Gradient gradient;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final first = (gradient as LinearGradient).colors.first;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: first.withAlpha(90),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned(right: -34, top: -34, child: _bubble(130, 30)),
            Positioned(left: -28, bottom: -48, child: _bubble(120, 22)),
            Padding(padding: const EdgeInsets.all(22), child: child),
          ],
        ),
      ),
    );
  }

  static Widget _bubble(double size, int alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Colors.white.withAlpha(alpha)),
      );
}

/// Ícone dentro de um quadrado arredondado colorido (listas e ajustes).
class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, this.color, {super.key, this.size = 46});
  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withAlpha(34),
          borderRadius: BorderRadius.circular(size * 0.35),
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      );
}

/// Chips em formato de pílula; o selecionado fica na cor primária.
class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip(
      {super.key,
      required this.label,
      required this.selected,
      required this.onSelected});
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => ChoiceChip(
        label: Text(label),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : null,
        ),
        selected: selected,
        showCheckmark: false,
        selectedColor: AppTheme.primary,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        onSelected: (_) => onSelected(),
      );
}

class AppFilterChip extends StatelessWidget {
  const AppFilterChip(
      {super.key,
      required this.label,
      required this.selected,
      required this.onSelected});
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => FilterChip(
        label: Text(label),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : null,
        ),
        selected: selected,
        checkmarkColor: Colors.white,
        selectedColor: AppTheme.primary,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        onSelected: (_) => onSelected(),
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.subtitle});
  final String text;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: Theme.of(context).textTheme.titleMedium),
            if (subtitle != null)
              Text(subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(150))),
          ],
        ),
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState(this.icon, this.message, {super.key});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconBadge(icon, AppTheme.primary, size: 72),
              const SizedBox(height: 16),
              Text(message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(160))),
            ],
          ),
        ),
      );
}
