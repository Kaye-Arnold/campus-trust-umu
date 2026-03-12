import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/provider_model.dart';
import '../models/review_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/review_bottom_sheet.dart';

class ProviderDetailScreen extends StatefulWidget {
  final ProviderModel provider;
  const ProviderDetailScreen({super.key, required this.provider});

  @override
  State<ProviderDetailScreen> createState() =>
      _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  final _fs = FirestoreService();
  late ProviderModel _provider;
  List<ReviewModel> _reviews = [];
  bool _loadingReviews = true;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _provider = widget.provider;
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _loadingReviews = true);
    final list = await _fs.getReviews(_provider.id);
    if (mounted) setState(() {
      _reviews = list;
      _loadingReviews = false;
    });
  }

  /// Re-fetches the single provider document so the rating UI reflects the
  /// new review immediately. Costs 1 Firestore read, not N.
  Future<void> _refreshProvider() async {
    final updated = await _fs.getProviderById(_provider.id);
    if (mounted && updated != null) setState(() => _provider = updated);
    await _loadReviews();
  }

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: _provider.phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp() async {
    final number =
        _provider.whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReviewBottomSheet(
        provider: _provider,
        onReviewSubmitted: _refreshProvider,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayed =
        _showAll ? _reviews : _reviews.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Provider Profile',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined,
                color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero ──────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  // Avatar + verified badge
                  Stack(
                    children: [
                      Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.border, width: 2.5),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: _provider.photoUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppColors.primaryMuted,
                              child: const Icon(Icons.person,
                                  size: 46,
                                  color: AppColors.primary),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.primaryMuted,
                              child: const Icon(Icons.person,
                                  size: 46,
                                  color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.black, width: 2),
                          ),
                          child: const Icon(Icons.verified,
                              color: Colors.white, size: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Name
                  Text(
                    _provider.name,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMuted,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'Verified ${_formatCat(_provider.category)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star,
                          color: AppColors.star, size: 18),
                      const SizedBox(width: 5),
                      Text(
                        _provider.ratingAverage > 0
                            ? '${_provider.ratingAverage.toStringAsFixed(1)}'
                              ' (${_provider.ratingCount} reviews)'
                            : 'No reviews yet',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Call / WhatsApp buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _call,
                          icon: const Icon(Icons.phone, size: 18),
                          label: Text(
                            'Call Directly',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 15),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 50),
                            shape: const StadiumBorder(),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _whatsapp,
                          icon: const Icon(Icons.chat, size: 18),
                          label: Text(
                            'WhatsApp',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 15),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.whatsapp,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 50),
                            shape: const StadiumBorder(),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // thin divider
            Divider(
                height: 1,
                color: AppColors.border.withOpacity(0.4),
                indent: 24,
                endIndent: 24),

            // ── About ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _provider.bio,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.65,
                    ),
                  ),
                ],
              ),
            ),

            Divider(
                height: 1,
                color: AppColors.border.withOpacity(0.4),
                indent: 24,
                endIndent: 24),

            // ── Reviews ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Reviews',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: _openReviewSheet,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: const StadiumBorder(),
                          minimumSize: Size.zero,
                          tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          textStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Write a Review'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_loadingReviews)
                    const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    )
                  else if (_reviews.isEmpty)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'No reviews yet. Be the first!',
                          style: GoogleFonts.poppins(
                              color: AppColors.textMuted,
                              fontSize: 13),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        ...displayed
                            .map((r) => _ReviewTile(review: r)),

                        if (_reviews.length > 3)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8, bottom: 24),
                            child: Center(
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _showAll = !_showAll),
                                child: Text(
                                  _showAll
                                      ? 'Show less'
                                      : 'View all ${_reviews.length} reviews',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatCat(String cat) => cat
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) =>
          w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

// ── Review tile ───────────────────────────────────────────────────────────────
class _ReviewTile extends StatelessWidget {
  final ReviewModel review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final initials = review.authorName
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.avatarBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name + time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _timeAgo(review.timestamp),
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),

              // Stars
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    size: 14,
                    color: i < review.ratingValue
                        ? AppColors.star
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays >= 30) return DateFormat('MMM d, y').format(dt);
    if (diff.inDays >= 14) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays >= 7)  return '1 week ago';
    if (diff.inDays >= 2)  return '${diff.inDays} days ago';
    if (diff.inDays == 1)  return '1 day ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'Just now';
  }
}
