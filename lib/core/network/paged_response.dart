class PagedResponse<T> {
  final List<T> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasPrevious;
  final bool hasNext;

  PagedResponse({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasPrevious,
    required this.hasNext,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFactory,
  ) {
    final itemsJson = (_val(json, 'items') ?? _val(json, 'Items') ?? []) as List<dynamic>;
    return PagedResponse(
      items: itemsJson.map((e) => itemFactory(e as Map<String, dynamic>)).toList(),
      pageNumber: (_val(json, 'pageNumber') ?? _val(json, 'PageNumber') ?? 0) as int,
      pageSize: (_val(json, 'pageSize') ?? _val(json, 'PageSize') ?? 0) as int,
      totalCount: (_val(json, 'totalCount') ?? _val(json, 'TotalCount') ?? 0) as int,
      totalPages: (_val(json, 'totalPages') ?? _val(json, 'TotalPages') ?? 1) as int,
      hasPrevious: (_val(json, 'hasPrevious') ?? _val(json, 'HasPrevious') ?? false) as bool,
      hasNext: (_val(json, 'hasNext') ?? _val(json, 'HasNext') ?? false) as bool,
    );
  }

  static dynamic _val(Map<String, dynamic> json, String key) => json.containsKey(key) ? json[key] : null;
}