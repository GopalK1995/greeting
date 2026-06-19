import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/movie_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
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
          SliverAppBar(
            backgroundColor: AppTheme.background,
            pinned: true,
            title: const Text('Discover',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 22)),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: CupertinoSearchTextField(
                  controller: _ctrl,
                  placeholder: 'Search any movie...',
                  style: const TextStyle(color: AppTheme.textPrimary),
                  backgroundColor: AppTheme.surfaceHigh,
                  onChanged: (q) => movies.search(q),
                ),
              ),
            ),
          ),

          // Loading
          if (movies.loadingSearch)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CupertinoActivityIndicator()),
              ),
            )
          // Results
          else if (movies.searchResults.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final m = movies.searchResults[i];
                  final um = movies.getUserMovie(m.id);
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      ctx,
                      CupertinoPageRoute(
                          builder: (_) => MovieDetailScreen(movie: m)),
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppTheme.border, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 52,
                              height: 78,
                              child: m.posterPath != null
                                  ? CachedNetworkImage(
                                      imageUrl: m.posterUrl,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: AppTheme.surfaceHigh),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.title,
                                    style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 3),
                                Text(m.year,
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12)),
                                const SizedBox(height: 5),
                                Row(children: [
                                  const Icon(CupertinoIcons.star_fill,
                                      color: AppTheme.gold, size: 11),
                                  const SizedBox(width: 3),
                                  Text(m.ratingFormatted,
                                      style: const TextStyle(
                                          color: AppTheme.gold,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ]),
                              ],
                            ),
                          ),
                          // Quick add button
                          _QuickAddButton(
                            isInLibrary: movies.isInLibrary(m.id),
                            status: um?.status,
                            onWatchlist: () =>
                                movies.addToWatchlist(auth.uid, m),
                            onWatched: () =>
                                movies.markWatched(auth.uid, m),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: movies.searchResults.length,
              ),
            )
          // Empty search
          else if (movies.searchQuery.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: Column(
                  children: [
                    Icon(CupertinoIcons.search,
                        color: AppTheme.textTertiary, size: 44),
                    SizedBox(height: 12),
                    Text('No movies found',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 16)),
                  ],
                ),
              ),
            )
          // Default: Popular
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 10),
                child: const Text('🌟 Popular Right Now',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  if (i >= movies.popular.length) return null;
                  final m = movies.popular[i];
                  final um = movies.getUserMovie(m.id);
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      ctx,
                      CupertinoPageRoute(
                          builder: (_) => MovieDetailScreen(movie: m)),
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppTheme.border, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 52,
                              height: 78,
                              child: m.posterPath != null
                                  ? CachedNetworkImage(
                                      imageUrl: m.posterUrl,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: AppTheme.surfaceHigh),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.title,
                                    style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 3),
                                Text(m.year,
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12)),
                                const SizedBox(height: 5),
                                Row(children: [
                                  const Icon(CupertinoIcons.star_fill,
                                      color: AppTheme.gold, size: 11),
                                  const SizedBox(width: 3),
                                  Text(m.ratingFormatted,
                                      style: const TextStyle(
                                          color: AppTheme.gold,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ]),
                              ],
                            ),
                          ),
                          _QuickAddButton(
                            isInLibrary: movies.isInLibrary(m.id),
                            status: um?.status,
                            onWatchlist: () =>
                                movies.addToWatchlist(auth.uid, m),
                            onWatched: () =>
                                movies.markWatched(auth.uid, m),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: movies.popular.length,
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final bool isInLibrary;
  final dynamic status;
  final VoidCallback onWatchlist;
  final VoidCallback onWatched;

  const _QuickAddButton({
    required this.isInLibrary,
    required this.status,
    required this.onWatchlist,
    required this.onWatched,
  });

  @override
  Widget build(BuildContext context) {
    if (isInLibrary) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.green.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(CupertinoIcons.checkmark,
            color: AppTheme.green, size: 16),
      );
    }
    return GestureDetector(
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (_) => CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  onWatched();
                },
                child: const Text('Mark as Watched'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  onWatchlist();
                },
                child: const Text('Add to Watchlist'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(CupertinoIcons.add,
            color: AppTheme.accent, size: 16),
      ),
    );
  }
}
