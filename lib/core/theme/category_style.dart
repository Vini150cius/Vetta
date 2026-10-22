import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Cor + ícone por categoria, para cada lançamento ter identidade própria.
/// Categorias conhecidas têm visual fixo; as criadas pelo usuário recebem uma
/// cor estável (mesmo nome => mesma cor).
class CategoryStyle {
  const CategoryStyle(this.color, this.icon);
  final Color color;
  final IconData icon;

  static const _known = <String, CategoryStyle>{
    'alimentação': CategoryStyle(Color(0xFFFF7A45), Icons.restaurant_rounded),
    'transporte': CategoryStyle(AppTheme.sky, Icons.directions_car_rounded),
    'moradia': CategoryStyle(AppTheme.violet, Icons.home_rounded),
    'saúde': CategoryStyle(AppTheme.pink, Icons.favorite_rounded),
    'lazer': CategoryStyle(AppTheme.amber, Icons.sports_esports_rounded),
    'educação': CategoryStyle(Color(0xFF14B8A6), Icons.school_rounded),
    'eletrônicos': CategoryStyle(Color(0xFF6366F1), Icons.devices_rounded),
    'roupas': CategoryStyle(Color(0xFFD946EF), Icons.checkroom_rounded),
    'salário': CategoryStyle(AppTheme.incomeColor, Icons.payments_rounded),
    'investimentos':
        CategoryStyle(Color(0xFF0EA5A4), Icons.trending_up_rounded),
    'outros': CategoryStyle(Color(0xFF8B8FA8), Icons.category_rounded),
  };

  static const _fallback = <Color>[
    AppTheme.primary,
    AppTheme.sky,
    AppTheme.amber,
    AppTheme.pink,
    Color(0xFFFF7A45),
    Color(0xFF14B8A6),
    AppTheme.violet,
  ];

  static CategoryStyle of(String category) {
    final key = category.trim().toLowerCase();
    final known = _known[key];
    if (known != null) return known;
    final hash = key.codeUnits.fold<int>(0, (a, b) => a + b);
    return CategoryStyle(
        _fallback[hash % _fallback.length], Icons.label_rounded);
  }
}
