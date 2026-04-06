List<String> generateSearchKeywords(String text) {
  final words = text
    .toLowerCase()
    .split(RegExp(r'\s+'))
    .map((word) => word.trim())
    .where((word) => word.isNotEmpty)
    .toSet()   // prevent duplicates
    .toList();

    return words;
}