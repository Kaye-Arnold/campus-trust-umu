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
    if (query.trim().isEmpty) return [];
    final snap = await _db
        .collection('providers')
        .orderBy('name')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .get();
    return snap.docs.map(ProviderModel.fromDoc).toList();
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

  /// Atomically writes the review document and updates the provider's
  /// ratingAverage + ratingCount in a single Firestore transaction.
  Future<void> submitReview(ReviewModel review) async {
    final providerRef = _db.collection('providers').doc(review.providerId);
    final reviewRef   = _db.collection('reviews').doc(); // auto-ID

    await _db.runTransaction((tx) async {
      final provSnap = await tx.get(providerRef);
      if (!provSnap.exists) throw Exception('Provider not found.');

      final currentCount =
          (provSnap.data()?['ratingCount'] ?? 0).toInt();
      final currentAvg =
          (provSnap.data()?['ratingAverage'] ?? 0.0).toDouble();

      final newCount = currentCount + 1;
      final newAvg =
          ((currentAvg * currentCount) + review.ratingValue) / newCount;

      tx.set(reviewRef, review.toMap());
      tx.update(providerRef, {
        'ratingCount':   newCount,
        'ratingAverage': double.parse(newAvg.toStringAsFixed(1)),
      });
    });
  }
}
