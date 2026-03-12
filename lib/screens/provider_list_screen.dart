import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/provider_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import 'provider_detail_screen.dart';

class ProviderListScreen extends StatefulWidget {
  final String category;
  final String categoryLabel;
  final String? searchQuery;

  const ProviderListScreen({
    super.key,
    required this.category,
    required this.categoryLabel,
    this.searchQuery,
  });

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  final _fs = FirestoreService();
  late Future<List<ProviderModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.searchQuery != null
        ? _fs.searchProviders(widget.searchQuery!)
        : _fs.getProvidersByCategory(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text(widget.categoryLabel),
        backgroundColor: AppColors.bgPrimary,
      ),
      body: FutureBuilder<List<ProviderModel>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'Could not load providers.',
                style: GoogleFonts.poppins(color: AppColors.textSecondary),
              ),
            );
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off,
                      size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 14),
                  Text(
                    'No providers found',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Check back later or try a different category.',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _ProviderCard(
              provider: list[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProviderDetailScreen(provider: list[i]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final ProviderModel provider;
  final VoidCallback onTap;
  const _ProviderCard({required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: provider.photoUrl,
                width: 68,
                height: 68,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 68,
                  height: 68,
                  color: AppColors.primaryMuted,
                  child: const Icon(Icons.person,
                      color: AppColors.primary, size: 30),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 68,
                  height: 68,
                  color: AppColors.primaryMuted,
                  child: const Icon(Icons.person,
                      color: AppColors.primary, size: 30),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMuted,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      _formatCat(provider.category),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: AppColors.star, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        provider.ratingAverage > 0
                            ? '${provider.ratingAverage.toStringAsFixed(1)}'
                              ' (${provider.ratingCount} reviews)'
                            : 'No reviews yet',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textMuted, size: 22),
          ],
        ),
      ),
    );
  }

  String _formatCat(String cat) => cat
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty
          ? ''
          : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
