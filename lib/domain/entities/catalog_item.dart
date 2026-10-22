enum CatalogKind { category, place }

class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.name,
    required this.kind,
  });

  final int? id;
  final String name;
  final CatalogKind kind;
}
