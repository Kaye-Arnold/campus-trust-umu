import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import 'provider_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();

  static const _categories = [
    _Cat('Electricians', Icons.bolt,        'electrician'),
    _Cat('Plumbers',     Icons.water_drop,  'plumber'),
    _Cat('Boda Riders',  Icons.two_wheeler, 'boda_rider'),
    _Cat('Peer Tutors',  Icons.school,      'peer_tutor'),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showProfileMenu(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryMuted,
                backgroundImage: auth.user?.photoURL != null
                    ? NetworkImage(auth.user!.photoURL!)
                    : null,
                child: auth.user?.photoURL == null
                    ? const Icon(Icons.person, color: AppColors.primary, size: 30)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                auth.user?.displayName ?? 'CampusTrust User',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                auth.user?.email ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    auth.signOut();
                    Navigator.pop(context); // close bottom sheet
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: Text(
                    'Sign Out',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCategory(String key, String label) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ProviderListScreen(category: key, categoryLabel: label),
        ),
      );

  void _onSearch() {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderListScreen(
          category: '',
          categoryLabel: 'Results for "$q"',
          searchQuery: q,
        ),
      ),
    );
  }

  // ── UPDATED: Production-ready URL Launcher ─────────────────────────────────
  Future<void> _applyToBeListed() async {
    final uri = Uri.parse('https://forms.gle/kVWovJS6eyf4soqm7');
    
    try {
      // Launch IN-APP so they don't lose context of CampusTrust
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      
    } catch (e) {
      // If the device fails to open the link, catch it gracefully
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open the form. Please check your internet connection.',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CampusTrust',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  
                  // User Profile / Sign Out Button
                  Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      // If not logged in, show nothing (Lazy Auth)
                      if (!auth.isAuthenticated) return const SizedBox.shrink();

                      final user = auth.user;
                      return GestureDetector(
                        onTap: () => _showProfileMenu(context, auth),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primaryMuted,
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? const Icon(Icons.person, color: AppColors.primary, size: 20)
                              : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // thin divider under header
            const SizedBox(height: 14),
            Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
            const SizedBox(height: 14),

            // ── Scrollable body ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    TextField(
                      controller: _searchCtrl,
                      onSubmitted: (_) => _onSearch(),
                      textInputAction: TextInputAction.search,
                      style: GoogleFonts.poppins(
                          color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search for verified campus services...',
                        prefixIcon:
                            const Icon(Icons.search, size: 20),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_forward,
                              color: AppColors.primary),
                          onPressed: _onSearch,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Categories header
                    Row(
                      children: [
                        Text(
                          'Categories',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'View All',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 2×2 Category grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.15,
                      children: _categories
                          .map((c) => _CategoryCard(
                                cat: c,
                                onTap: () => _openCategory(c.key, c.label),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 14),

                    // General Fundis featured card
                    _FeaturedCard(
                      onTap: () =>
                          _openCategory('general_fundi', 'General Fundis'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Apply to be Listed ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: _ApplyButton(onTap: _applyToBeListed),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────
class _Cat {
  final String label;
  final IconData icon;
  final String key;
  const _Cat(this.label, this.icon, this.key);
}

// ── Category card ─────────────────────────────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  final _Cat cat;
  final VoidCallback onTap;
  const _CategoryCard({required this.cat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                color: AppColors.primaryMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(cat.icon, color: AppColors.primary, size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              cat.label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Featured General Fundis card ─────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final VoidCallback onTap;
  const _FeaturedCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMuted,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'FEATURED',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'General Fundis',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Find reliable handymen\nfor fixing anything in your room',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        'Explore',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward,
                          color: AppColors.primary, size: 16),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                color: AppColors.featuredIllustration.withOpacity(0.85),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.construction,
                  size: 52, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Apply to be Listed button ────────────────────────────────────────────────
class _ApplyButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ApplyButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.work_outline,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service Provider?',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Apply to be Listed',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}