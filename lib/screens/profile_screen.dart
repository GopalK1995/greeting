import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final movies = context.watch<MovieProvider>();
    final auth = context.watch<AuthProvider>();

    // Genre breakdown from watched movies
    final Map<String, int> genreCount = {};
    for (final m in movies.watched) {
      // Use watchedOnPlatform as a proxy genre label if genre not available
      final label = m.watchedOnPlatform ?? 'Other';
      genreCount[label] = (genreCount[label] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Profile header
          SliverAppBar(
            backgroundColor: AppTheme.background,
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1C1C2E), AppTheme.background],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    // Avatar
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: AppTheme.accent,
                      backgroundImage: auth.photoUrl.isNotEmpty
                          ? NetworkImage(auth.photoUrl)
                          : null,
                      child: auth.photoUrl.isEmpty
                          ? Text(
                              auth.displayName.isNotEmpty
                                  ? auth.displayName[0].toUpperCase()
                                  : 'C',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700),
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(auth.displayName,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600)),
                    Text(auth.email,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Big stats
                  Row(children: [
                    _bigStat('${movies.watched.length}', 'Films\nWatched', AppTheme.accent),
                    const SizedBox(width: 10),
                    _bigStat('${movies.watchlist.length}', 'In\nWatchlist', AppTheme.gold),
                    const SizedBox(width: 10),
                    _bigStat('${movies.favorites.length}', 'Films\nLoved', const Color(0xFFFF453A)),
                  ]),

                  const SizedBox(height: 28),

                  // Firebase info box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.border, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(CupertinoIcons.cloud_fill, color: AppTheme.prime, size: 16),
                          SizedBox(width: 8),
                          Text('Cloud Sync Active', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                        ]),
                        const SizedBox(height: 6),
                        Text(
                          'Your library is synced in real-time to Firebase Firestore. Access it on any device.',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Data source info
                  const Text('Data Sources', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),

                  _infoRow('🎬', 'Movie Data', 'TMDB API (real-time)'),
                  _infoRow('☁️', 'Your Library', 'Firebase Firestore'),
                  _infoRow('🔐', 'Sign In', 'Google Sign-In via Firebase Auth'),
                  _infoRow('🔗', 'Deep Links', 'Netflix · Prime · Hotstar · BMS · SonyLIV · ZEE5'),
                  _infoRow('🌍', 'Watch Providers', 'TMDB Watch Providers API (India region)'),

                  const SizedBox(height: 28),

                  // Sign out
                  GestureDetector(
                    onTap: () => _confirmSignOut(context, auth),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.accent.withOpacity(0.3), width: 0.8),
                      ),
                      child: const Center(
                        child: Text('Sign Out',
                            style: TextStyle(color: AppTheme.accent, fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigStat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 0.5),
        ),
        child: Column(children: [
          Text(value, style: TextStyle(color: color, fontSize: 30, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.3), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _infoRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
            Text(value, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ]),
        ),
      ]),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () { Navigator.pop(context); auth.signOut(); },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
