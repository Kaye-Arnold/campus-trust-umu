import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/provider_model.dart';
import '../models/review_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Providers ──────────────────────────────────────────────────────────────

  /// Fetches a single provider by its Firestore document ID.
  /// Use this instead of getProvidersByCategory when you already have the ID —
  /// costs exactly 1 read instead of N.
  Future<ProviderModel?> getProviderById(String id) async {
    final doc = await _db.collection('providers').doc(id).get();
    if (!doc.exists) return null;
    return ProviderModel.fromDoc(doc);
  }

  Future<List<ProviderModel>> getProvidersByCategory(String category) async {
    final snap = await _db
        .collection('providers')
        .where('category', isEqualTo: category)
        .orderBy('ratingAverage', descending: true)
        .get();
    return snap.docs.map(ProviderModel.fromDoc).toList();
  }

  Future<List<ProviderModel>> searchProviders(String query) async {
    // 1. Clean the user's input so it matches the lowercase array in Firestore
    final searchTerm = query.toLowerCase().trim();
    if (searchTerm.isEmpty) return [];

    try {
      // 2. Query Firestore natively using the N-Gram array
      final snap = await _db
          .collection('providers')
          .where('searchKeywords', arrayContains: searchTerm)
          .limit(20) // Limits reads to protect your Firebase free tier
          .get();

      // 3. Map the documents back to your ProviderModel
      return snap.docs.map(ProviderModel.fromDoc).toList();
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }

  // ── Reviews ────────────────────────────────────────────────────────────────

  Future<List<ReviewModel>> getReviews(String providerId,
      {int limit = 100}) async {
    final snap = await _db
        .collection('reviews')
        .where('providerId', isEqualTo: providerId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(ReviewModel.fromDoc).toList();
  }

  /// Creates a review. Rating aggregates are intentionally not client-written:
  /// allowing clients to update provider ratings would let a malicious user
  /// forge the trust signal. A trusted Cloud Function can aggregate reviews in
  /// production; the detail screen calculates the current view from reviews.
  Future<void> submitReview(ReviewModel review) async {
    if (review.ratingValue < 1 || review.ratingValue > 5) {
      throw ArgumentError('Rating must be between 1 and 5.');
    }
    if (review.comment.length > 1000) {
      throw ArgumentError('Comment is too long.');
    }
    await _db.collection('reviews').add(review.toMap());
  }
}
