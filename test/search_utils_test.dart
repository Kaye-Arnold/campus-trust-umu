import 'package:flutter_test/flutter_test.dart';
import 'package:campustrust/utils/search_utils.dart';

void main() {
  test('generates lowercase prefix keywords for Firestore search', () {
    expect(SearchUtils.generateSearchKeywords('Nkozi Plumber'), containsAll(['n', 'nk', 'nkozi', 'p', 'plumber']));
  });

  test('handles extra whitespace', () {
    expect(SearchUtils.generateSearchKeywords('  Boda   Rider '), contains('boda'));
  });
}
