class PagedResult<T> {
  final List<T> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final bool hasNext;

  const PagedResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.hasNext,
  });

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final itemsJson = json['Items'] ?? json['items'] ?? [];
    final items = (itemsJson as List).map((e) => fromJsonT(e as Map<String, dynamic>)).toList();
    return PagedResult<T>(
      items: items,
      totalCount: (json['TotalCount'] ?? json['totalCount'] ?? 0) as int,
      pageNumber: (json['PageNumber'] ?? json['pageNumber'] ?? 1) as int,
      pageSize: (json['PageSize'] ?? json['pageSize'] ?? 20) as int,
      totalPages: (json['TotalPages'] ?? json['totalPages'] ?? 1) as int,
      hasNext: (json['HasNext'] ?? json['hasNext'] ?? false) as bool,
    );
  }
}