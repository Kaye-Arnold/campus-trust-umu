import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/provider_model.dart';
import '../models/review_model.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class ReviewBottomSheet extends StatefulWidget {
  final ProviderModel provider;
  final VoidCallback onReviewSubmitted;

  const ReviewBottomSheet({
    super.key,
    required this.provider,
    required this.onReviewSubmitted,
  });

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  int _rating = 0;
  final _commentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    // 1. Check rating BEFORE making them sign in
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating first.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.signInWithGoogle();
    if (!mounted) return;
    
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign-in failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop here if sign-in failed
    }

    // 2. If sign-in was successful, automatically submit the review!
    await _submitReview();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating.')),
      );
      return;
    }
    final user = context.read<AuthProvider>().user;
if (user == null) {
  print('🚨 SILENT FAILURE CAUGHT: AuthProvider user is null!');
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Finalizing sign-in... Please tap Submit again.'),
      backgroundColor: Colors.orange,
    ),
  );
  return;
}

    setState(() => _submitting = true);
    try {
      await FirestoreService().submitReview(
        ReviewModel(
          id: '',
          providerId: widget.provider.id,
          userId: user.uid,
          authorName: user.displayName ?? 'Anonymous',
          ratingValue: _rating,
          comment: _commentCtrl.text.trim(),
          timestamp: DateTime.now(),
        ),
      );
      if (!mounted) return;
      // Capture BEFORE pop to avoid detached context errors
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      widget.onReviewSubmitted();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Review submitted! Thank you.'),
          backgroundColor: AppColors.whatsapp, // Assuming you defined this in theme
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bgSheet, // warm dark brown
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // WRAPPED IN SingleChildScrollView to prevent keyboard overflow crashes
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 22),

              // CAMPUSTRUST label
              Text(
                'CAMPUSTRUST',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),

              // Title
              Text(
                'Leave a Review',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SELECT RATING label
                    Center(
                      child: Text(
                        'SELECT RATING',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stars — large, matching mockup
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (i) {
                          final filled = i < _rating;
                          return GestureDetector(
                            onTap: () => setState(() => _rating = i + 1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Icon(
                                Icons.star,
                                size: 48,
                                color: filled
                                    ? AppColors.primary
                                    : AppColors.textMuted.withOpacity(0.5),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 26),

                    // Your comments label
                    Text(
                      'Your comments',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Comment text field
                    TextField(
                      controller: _commentCtrl,
                      minLines: 4,
                      maxLines: 6,
                      maxLength: 1000,
                      textCapitalization: TextCapitalization.sentences,
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Share your experience with this provider...',
                        hintStyle: GoogleFonts.poppins(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: AppColors.bgSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 26),

                    // CTA — switches between Sign In and Submit
                    if (!auth.isAuthenticated)
                      _GoogleSignInButton(
                        onTap: _signInWithGoogle,
                        loading: auth.isLoading,
                      )
                    else
                      // STYLED to perfectly match the dimensions of the Google button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _submitReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 0,
                          ),
                          child: _submitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Submit Review',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),

                    const SizedBox(height: 14),

                    // ToS
                    Center(
                      child: Text(
                        'By submitting, you agree to CampusTrust Terms of Service.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Google Sign-In button ─────────────────────────────────────────────────────
class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool loading;
  const _GoogleSignInButton({required this.onTap, required this.loading});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: loading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google G
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'G',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Sign in with Google to Submit',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}