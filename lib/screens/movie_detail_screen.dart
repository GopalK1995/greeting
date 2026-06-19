import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/tmdb_movie.dart';
import '../models/user_movie.dart';
import '../providers/movie_provider.dart';
import '../providers/auth_provider.dart';
import '../services/deep_link_service.dart';
import '../theme/app_theme.dart';
import '../widgets/provider_chip.dart';

class MovieDetailScreen extends StatefulWidget {
  final TmdbMovie movie;
  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  TmdbMovie? _detailed;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final details = await context.read<MovieProvider>().getDetails(widget.movie.id);
    if (mounted) setState(() { _detailed = details; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final movie = _detailed ?? widget.movie;
    final provider = context.watch<MovieProvider>();
    final auth = context.watch<AuthProvider>();
    final userMovie = provider.getUserMovie(movie.id);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Hero backdrop
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 360,
            pinned: true,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                child: const Icon(CupertinoIcons.back, color: Colors.white),
              ),
            ),
            actions: [
              if (userMovie != null)
                GestureDetector(
                  onTap: () => provider.toggleFavorite(auth.uid, movie.id),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                    child: Icon(
                      userMovie.isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                      color: userMovie.isFavorite ? AppTheme.accent : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (movie.backdropPath != null)
                    CachedNetworkImage(imageUrl: movie.backdropUrl, fit: BoxFit.cover)
                  else if (movie.posterPath != null)
                    CachedNetworkImage(imageUrl: movie.posterUrl, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppTheme.background.withOpacity(0.7), AppTheme.background],
                        stops: const [0.4, 0.75, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16, left: 0, right: 0,
                    child: Center(
                      child: Hero(
                        tag: 'poster_${movie.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 120, height: 180,
                            child: movie.posterPath != null
                                ? CachedNetworkImage(imageUrl: movie.posterUrl, fit: BoxFit.cover)
                                : Container(color: AppTheme.surfaceHigh),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Center(
                    child: Text(movie.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                  ),
                  const SizedBox(height: 6),

                  // Meta row
                  Center(
                    child: Text(
                      [
                        movie.year,
                        if (movie.runtime != null && movie.runtime! > 0) '${movie.runtime}m',
                        if (movie.genres.isNotEmpty)
                          movie.genres.take(2).map((g) => g.name).join(' · ')
                        else if (movie.genreIds.isNotEmpty)
                          movie.genreIds.take(2).map((id) => Genre.idToName[id] ?? '').where((s) => s.isNotEmpty).join(' · '),
                      ].join('  ·  '),
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ),

                  if (movie.tagline != null && movie.tagline!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: Text('"${movie.tagline}"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.textTertiary, fontSize: 13, fontStyle: FontStyle.italic)),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Ratings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ratingBadge(CupertinoIcons.star_fill, AppTheme.gold, movie.ratingFormatted, 'TMDB'),
                      if (userMovie?.userRating != null) ...[
                        const SizedBox(width: 10),
                        _ratingBadge(CupertinoIcons.person_fill, AppTheme.accentLight, userMovie!.userRating!.toStringAsFixed(1), 'Your rating'),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Action buttons
                  Row(children: [
                    Expanded(child: _actionBtn(
                      icon: userMovie?.status == WatchStatus.watched ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.checkmark_circle,
                      label: userMovie?.status == WatchStatus.watched ? 'Watched' : 'Mark Watched',
                      color: AppTheme.green,
                      active: userMovie?.status == WatchStatus.watched,
                      onTap: () => provider.markWatched(auth.uid, movie),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _actionBtn(
                      icon: userMovie?.status == WatchStatus.watchlist ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
                      label: userMovie?.status == WatchStatus.watchlist ? 'In List' : 'Add to List',
                      color: AppTheme.gold,
                      active: userMovie?.status == WatchStatus.watchlist,
                      onTap: () => provider.addToWatchlist(auth.uid, movie),
                    )),
                  ]),

                  // Watch On (streaming platforms from TMDB)
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CupertinoActivityIndicator()),
                    )
                  else if (movie.flatrateProviders.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('Watch On', style: TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    const Text('Tap to open the app directly', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: movie.flatrateProviders.map((p) => ProviderChip(
                          provider: p,
                          onTap: () => DeepLinkService().openOnProvider(p, movie),
                        )).toList(),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border, width: 0.5),
                      ),
                      child: const Row(children: [
                        Icon(CupertinoIcons.info_circle, color: AppTheme.textSecondary, size: 16),
                        SizedBox(width: 8),
                        Expanded(child: Text('Not available on streaming in India right now.',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
                      ]),
                    ),
                  ],

                  // BookMyShow — cinema tickets
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => DeepLinkService().openBookMyShow(movie),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.bms.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.bms.withOpacity(0.4), width: 0.5),
                      ),
                      child: Row(children: [
                        const Text('🎟', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('BookMyShow', style: TextStyle(color: AppTheme.bms, fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('Book cinema tickets — opens BookMyShow app ↗', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                        ]),
                      ]),
                    ),
                  ),

                  // Overview
                  if (movie.overview.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('Overview', style: TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(movie.overview, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.6)),
                  ],

                  // Rate it
                  if (userMovie?.status == WatchStatus.watched) ...[
                    const SizedBox(height: 24),
                    const Text('Your Rating', style: TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    _RatingRow(current: userMovie?.userRating, onRate: (r) => provider.setRating(auth.uid, movie.id, r)),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingBadge(IconData icon, Color color, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 5),
        Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ]),
    );
  }

  Widget _actionBtn({required IconData icon, required String label, required Color color, required bool active, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.2) : AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? color.withOpacity(0.6) : AppTheme.border, width: 0.8),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: active ? color : AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _RatingRow extends StatefulWidget {
  final double? current;
  final void Function(double) onRate;
  const _RatingRow({this.current, required this.onRate});

  @override
  State<_RatingRow> createState() => _RatingRowState();
}

class _RatingRowState extends State<_RatingRow> {
  late double _val;

  @override
  void initState() {
    super.initState();
    _val = widget.current ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(10, (i) {
        final star = i + 1;
        return GestureDetector(
          onTap: () { setState(() => _val = star.toDouble()); widget.onRate(_val); },
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              star <= _val ? CupertinoIcons.star_fill : CupertinoIcons.star,
              color: star <= _val ? AppTheme.gold : AppTheme.textTertiary,
              size: 26,
            ),
          ),
        );
      }),
    );
  }
}
