/// A marketplace category, as returned by GET /listings/categories.
/// Includes [count] (how many active listings currently use it) so the UI
/// can, if it wants, hide or de-emphasize categories with zero results —
/// which is exactly the bug the old hardcoded chip list had (two of its
/// four categories didn't match any real listing category and always
/// returned an empty filtered list).
class MarketplaceCategoryModel {
  final String id;
  final String name;
  final int count;

  const MarketplaceCategoryModel({
    required this.id,
    required this.name,
    required this.count,
  });

  factory MarketplaceCategoryModel.fromJson(Map<String, dynamic> json) {
    return MarketplaceCategoryModel(
      id: json['Id'] as String? ?? json['id'] as String? ?? '',
      name: json['Name'] as String? ?? json['name'] as String? ?? '',
      count: json['Count'] as int? ?? json['count'] as int? ?? 0,
    );
  }
}
