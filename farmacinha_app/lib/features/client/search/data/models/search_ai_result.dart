class SearchAiResult {
  const SearchAiResult({
    required this.productIds,
    required this.terms,
    required this.categories,
  });

  final List<String> productIds;
  final List<String> terms;
  final List<String> categories;

  bool get hasProductMatches => productIds.isNotEmpty;

  factory SearchAiResult.fromJson(Map<String, dynamic> json) {
    return SearchAiResult(
      productIds: _stringListFrom(json['ids'] ?? json['productIds']),
      terms: _stringListFrom(json['termos'] ?? json['terms']),
      categories: _stringListFrom(json['categorias'] ?? json['categories']),
    );
  }

  static List<String> _stringListFrom(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
}
