/// Contract: `{ data: [...], meta: { page, limit, total, totalPages } }`.
/// Hand-written because Freezed does not generate generic fromJson factories.
class PageMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PageMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PageMeta.fromJson(Map<String, dynamic> json) => PageMeta(
        page: json['page'] as int,
        limit: json['limit'] as int,
        total: json['total'] as int,
        totalPages: json['totalPages'] as int,
      );
}

class Paginated<T> {
  final List<T> data;
  final PageMeta meta;

  const Paginated({required this.data, required this.meta});

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) =>
      Paginated(
        data: (json['data'] as List)
            .map((e) => fromJsonT(e as Map<String, dynamic>))
            .toList(),
        meta: PageMeta.fromJson(json['meta'] as Map<String, dynamic>),
      );
}
