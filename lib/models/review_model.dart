import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String providerId;
  final String userId;
  final String authorName;
  final int ratingValue;
  final String comment;
  final DateTime timestamp;

  const ReviewModel({
    required this.id,
    required this.providerId,
    required this.userId,
    required this.authorName,
    required this.ratingValue,
    required this.comment,
    required this.timestamp,
  });

  factory ReviewModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      providerId: d['providerId'] ?? '',
      userId: d['userId'] ?? '',
      authorName: d['authorName'] ?? 'Anonymous',
      ratingValue: (d['ratingValue'] ?? 0).toInt(),
      comment: d['comment'] ?? '',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'providerId': providerId,
        'userId': userId,
        'authorName': authorName,
        'ratingValue': ratingValue,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
      };
}
