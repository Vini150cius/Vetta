import '../entities/catalog_item.dart';

abstract class CatalogRepository {
  Future<List<CatalogItem>> list(CatalogKind kind);
  Future<void> add(CatalogItem item);
  Future<void> update(CatalogItem item);
  Future<void> delete(int id);
}
