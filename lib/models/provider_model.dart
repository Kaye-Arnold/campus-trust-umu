import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderModel {
  final String id;
  final String name;
  final String category;
  final String phone;
  final String whatsapp;
  final String bio;
  final double ratingAverage;
  final int ratingCount;
  final String photoUrl;

  const ProviderModel({
    required this.id,
    required this.name,
    required this.category,
    required this.phone,
    required this.whatsapp,
    required this.bio,
    required this.ratingAverage,
    required this.ratingCount,
    required this.photoUrl,
  });

  factory ProviderModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ProviderModel(
      id: doc.id,
      name: d['name'] ?? '',
      category: d['category'] ?? '',
      phone: d['phone'] ?? '',
      whatsapp: d['whatsapp'] ?? '',
      bio: d['bio'] ?? '',
      ratingAverage: (d['ratingAverage'] ?? 0.0).toDouble(),
      ratingCount: (d['ratingCount'] ?? 0).toInt(),
      photoUrl: d['photoUrl'] ?? '',
    );
  }
}
