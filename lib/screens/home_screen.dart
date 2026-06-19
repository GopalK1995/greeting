import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/movie_provider.dart';
import '../providers/auth_provider.dart';
import '../models/tmdb_movie.dart';
import '../theme/app_theme.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadDiscovery();
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movies = context.watch<MovieProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── Large title ──────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: AppTheme.background,
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CineLog',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                    ),
                  ),
                  Text(
                    '${movies.watched.length} watched · ${movies.watchlist.length} in list',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Avatar
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => _showProfileSheet(context, auth),
                  child: CircleAvatar(
                    radius: 17,
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
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),

          // ── Stats ────────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _statsBar(movies)),

          // ── Trending carousel ────────────────────────────────────────────
          if (movies.trending.isNotEmpty) ...[
            _sectionHeader('🔥 Trending This Week'),
            SliverToBoxAdapter(child: _carousel(movies.trending, movies, auth)),
          ],

          // ── My Library tabs ──────────────────────────────────────────────
          _sectionHeader('📚 My Library'),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabDelegate(_tab),
          ),

          // ── Tab content ──────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _tab,
            builder: (_, __) {
              final list =
                  _tab.index == 0 ? movies.watched : movies.watchlist;
              if (list.isEmpty) {
                return SliverToBoxAdapter(child: _emptyState(_tab.index));
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final um = list[i];
                    // We need a TmdbMovie shell to pass to MovieCard
                    final shell = TmdbMovie(
                      id: um.tmdbId,
                      title: um.title,
                      posterPath: um.posterPath,
                      overview: '',
                      releaseDate: um.releaseDate,
                      voteAverage: um.tmdbRating,
                      voteCount: 0,
                      genreIds: const [],
                    );
                    return MovieCard(
                      movie: shell,
                      userMovie: um,
                      onTap: () => _goDetail(context, shell),
                      onFavorite: () =>
                          movies.toggleFavorite(auth.uid, um.tmdbId),
                    );
                  },
                  childCount: list.length,
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _statsBar(MovieProvider movies) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stat('${movies.watched.length}', 'Watched',
              CupertinoIcons.checkmark_circle_fill, AppTheme.green),
          _vDivider(),
          _stat('${movies.watchlist.length}', 'Watchlist',
              CupertinoIcons.bookmark_fill, AppTheme.gold),
          _vDivider(),
          _stat('${movies.favorites.length}', 'Loved',
              CupertinoIcons.heart_fill, AppTheme.accent),
        ],
      ),
    );
  }

  Widget _stat(String val, String label, IconData icon, Color color) =>
      Column(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 3),
        Text(val,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 11)),
      ]);

  Widget _vDivider() =>
      Container(height: 36, width: 0.5, color: AppTheme.border);

  SliverToBoxAdapter _sectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 16, 10),
        child: Text(title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            )),
      ),
    );
  }

  Widget _carousel(List<TmdbMovie> items, MovieProvider movies,
      AuthProvider auth) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (ctx, i) {
          final m = items[i];
          return GestureDetector(
            onTap: () => _goDetail(ctx, m),
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Hero(
                      tag: 'poster_${m.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: m.posterPath != null
                            ? CachedNetworkImage(
                                imageUrl: m.posterUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            : Container(color: AppTheme.surfaceHigh),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    m.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(children: [
                    const Icon(CupertinoIcons.star_fill,
                        color: AppTheme.gold, size: 10),
                    const SizedBox(width: 2),
                    Text(m.ratingFormatted,
                        style: const TextStyle(
                            color: AppTheme.gold, fontSize: 10)),
                  ]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState(int tabIndex) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          const Icon(CupertinoIcons.film, color: AppTheme.textTertiary, size: 48),
          const SizedBox(height: 12),
          Text(
            tabIndex == 0
                ? 'No watched movies yet.\nSearch and mark movies as watched!'
                : 'Your watchlist is empty.\nAdd movies you want to watch!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
          ),
        ],
      ),
    );
  }

  void _goDetail(BuildContext ctx, TmdbMovie movie) {
    Navigator.push(
      ctx,
      CupertinoPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
    );
  }

  void _showProfileSheet(BuildContext ctx, AuthProvider auth) {
    showCupertinoModalPopup(
      context: ctx,
      builder: (_) => CupertinoActionSheet(
        title: Text(auth.displayName),
        message: Text(auth.email),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              auth.signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

class _TabDelegate extends SliverPersistentHeaderDelegate {
  final TabController tab;
  _TabDelegate(this.tab);

  @override
  Widget build(BuildContext ctx, double shrinkOffset, bool overlaps) {
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: AppTheme.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: tab,
          indicator: BoxDecoration(
            color: AppTheme.accent,
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textSecondary,
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [Tab(text: '✓  Watched'), Tab(text: '🔖  Watchlist')],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 54;
  @override
  double get minExtent => 54;
  @override
  bool shouldRebuild(_TabDelegate _) => false;
}
