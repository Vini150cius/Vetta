import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class CurvedNavItem {
  const CurvedNavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

/// Menu inferior flutuante com "recorte" curvo: a bolinha do item ativo sobe
/// acima da barra e desliza suavemente até o próximo item tocado.
class CurvedNavBar extends StatelessWidget {
  const CurvedNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<CurvedNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const double _barHeight = 68;
  static const double _circleRadius = 27;
  static const double _ringWidth = 7;
  static const double _ringRadius = _circleRadius + _ringWidth;
  static const double _lift = 30; // quanto o anel sobe acima da barra

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final bg = theme.scaffoldBackgroundColor;
    final barColor = theme.colorScheme.surface;
    final bottom = math.max(MediaQuery.of(context).padding.bottom, 10.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, bottom),
      child: SizedBox(
        height: _barHeight + _lift,
        child: LayoutBuilder(builder: (context, constraints) {
          final itemW = constraints.maxWidth / items.length;
          final targetX = currentIndex * itemW + itemW / 2;

          return TweenAnimationBuilder<double>(
            tween: Tween<double>(end: targetX),
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            builder: (context, cx, _) => Stack(
              clipBehavior: Clip.none,
              children: [
                // Barra com o recorte
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: _barHeight,
                  child: CustomPaint(
                    painter: _BarPainter(
                      cx: cx,
                      color: barColor,
                      shadowColor:
                          dark ? Colors.black : AppTheme.primary.withAlpha(120),
                      borderColor: dark ? Colors.white.withAlpha(16) : null,
                    ),
                  ),
                ),
                // Ícones e rótulos
                for (var i = 0; i < items.length; i++)
                  Positioned(
                    left: i * itemW,
                    width: itemW,
                    bottom: 0,
                    height: _barHeight,
                    child: _NavButton(
                      item: items[i],
                      selected: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                  ),
                // Bolinha do item ativo
                Positioned(
                  left: cx - _ringRadius,
                  top: 0,
                  width: _ringRadius * 2,
                  height: _ringRadius * 2,
                  child: Container(
                    padding: const EdgeInsets.all(_ringWidth),
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: bg),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.heroGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withAlpha(110),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          items[currentIndex].icon,
                          key: ValueKey(currentIndex),
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton(
      {required this.item, required this.selected, required this.onTap});
  final CurvedNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withAlpha(140);
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // O ícone do item ativo "vira" a bolinha, então some daqui.
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: selected ? 0 : 1,
                child: Icon(item.icon, size: 24, color: muted),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.2,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected ? scheme.primary : muted,
                ),
                child: Text(item.label, maxLines: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.cx,
    required this.color,
    required this.shadowColor,
    this.borderColor,
  });

  final double cx;
  final Color color;
  final Color shadowColor;
  final Color? borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    const depth = CurvedNavBar._ringRadius * 2 - CurvedNavBar._lift; // 38
    const hw = 58.0; // meia-largura do recorte

    final bar = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Offset.zero & size, const Radius.circular(28)));

    // Região "com recorte": retângulo largo cuja borda superior mergulha em cx.
    final notched = Path()
      ..moveTo(-100, 0)
      ..lineTo(cx - hw, 0)
      ..cubicTo(cx - hw * 0.5, 0, cx - CurvedNavBar._ringRadius * 0.95, depth,
          cx, depth)
      ..cubicTo(cx + CurvedNavBar._ringRadius * 0.95, depth, cx + hw * 0.5, 0,
          cx + hw, 0)
      ..lineTo(size.width + 100, 0)
      ..lineTo(size.width + 100, size.height)
      ..lineTo(-100, size.height)
      ..close();

    // Interseção mantém os cantos arredondados mesmo com o recorte na borda.
    final path = Path.combine(PathOperation.intersect, bar, notched);

    canvas.drawShadow(path, shadowColor, 10, false);
    canvas.drawPath(path, Paint()..color = color);
    if (borderColor != null) {
      canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = borderColor!);
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.cx != cx || old.color != color || old.shadowColor != shadowColor;
}
