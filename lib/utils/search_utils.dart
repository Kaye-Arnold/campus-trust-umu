// lib/utils/search_utils.dart

class SearchUtils {
  static List<String> generateSearchKeywords(String text) {
    final List<String> keywords = [];
    final words = text.toLowerCase().trim().split(RegExp(r'\s+'));
    
    for (final word in words) {
      String prefix = '';
      for (int i = 0; i < word.length; i++) {
        prefix += word[i];
        if (!keywords.contains(prefix)) {
          keywords.add(prefix);
        }
      }
    }
    return keywords;
  }
}