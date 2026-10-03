class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;

  const PaginatedResult({
    required this.items,
    required this.totalCount,
  });
}
