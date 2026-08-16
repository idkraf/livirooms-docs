import 'api_response.dart';

/// Generic paginated list. Page counters come from the envelope's `meta`.
class Paginated<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  Paginated({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.perPage = 15,
  });

  const Paginated.empty()
      : data = const [],
        currentPage = 1,
        lastPage = 1,
        perPage = 15,
        total = 0;

  bool get hasMore => currentPage < lastPage;
  bool get isEmpty => data.isEmpty;

  /// Builds a page from the response envelope: items from `data`, counters
  /// from `meta`. `has_more` is honoured when the server sent it, since a
  /// simple paginator has no reliable `last_page`.
  factory Paginated.fromResponse(
    ApiResponse res,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final items = res.dataObjects.map(fromItem).toList();
    final currentPage = res.metaInt('current_page', 1);
    final serverHasMore = res.meta?['has_more'];

    final lastPage = res.metaInt(
      'last_page',
      serverHasMore == true ? currentPage + 1 : currentPage,
    );

    return Paginated<T>(
      data: items,
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: res.metaInt('per_page', items.isEmpty ? 15 : items.length),
      total: res.metaInt('total', items.length),
    );
  }

  Paginated<T> merge(Paginated<T> next) => Paginated<T>(
        data: [...data, ...next.data],
        currentPage: next.currentPage,
        lastPage: next.lastPage,
        perPage: next.perPage,
        total: next.total,
      );
}
