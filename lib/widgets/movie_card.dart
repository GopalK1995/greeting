import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/tmdb_movie.dart';
import '../models/user_movie.dart';
import '../theme/app_theme.dart';

class MovieCard extends StatelessWidget {
  final TmdbMovie movie;
  final UserMovie? userMovie;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;

  const MovieCard({
    super.key,
    required this.movie,
    this.userMovie,
    required this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Hero(
              tag: 'poster_${movie.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: SizedBox(
                  width: 88,
                  height: 132,
                  child: movie.posterPath != null
                      ? CachedNetworkImage(
                          imageUrl: movie.posterUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _shimmer(),
                          errorWidget: (_, __, ___) => _posterPlaceholder(),
                        )
                      : _posterPlaceholder(),
                ),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + heart
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            movie.title,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onFavorite != null)
                          GestureDetector(
                            onTap: onFavorite,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Icon(
                                userMovie?.isFavorite == true
                                    ? CupertinoIcons.heart_fill
                                    : CupertinoIcons.heart,
                                color: userMovie?.isFavorite == true
                                    ? AppTheme.accent
                                    : AppTheme.textTertiary,
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),
                    Text(
                      movie.year,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // IMDb rating
                    Row(
                      children: [
                        const Icon(CupertinoIcons.star_fill,
                            color: AppTheme.gold, size: 12),
                        const SizedBox(width: 3),
                        Text(
                          movie.ratingFormatted,
                          style: const TextStyle(
                            color: AppTheme.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('TMDB',
                            style: TextStyle(
                                color: AppTheme.textTertiary, fontSize: 10)),
                        if (userMovie?.userRating != null) ...[
                          const SizedBox(width: 8),
                          const Icon(CupertinoIcons.person_fill,
                              color: AppTheme.accentLight, size: 11),
                          const SizedBox(width: 3),
                          Text(
                            userMovie!.userRating!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppTheme.accentLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Status badge
                    if (userMovie != null)
                      _statusBadge(userMovie!.status)
                    else
                      const SizedBox.shrink(),

                    // Watched date
                    if (userMovie?.watchedDate != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(CupertinoIcons.checkmark_circle_fill,
                              color: AppTheme.green, size: 11),
                          const SizedBox(width: 4),
                          Text(
                            _fmtDate(userMovie!.watchedDate!),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(WatchStatus status) {
    final isWatched = status == WatchStatus.watched;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:
            (isWatched ? AppTheme.green : AppTheme.gold).withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color:
              (isWatched ? AppTheme.green : AppTheme.gold).withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Text(
        isWatched ? '✓ Watched' : '🔖 Watchlist',
        style: TextStyle(
          color: isWatched ? AppTheme.green : AppTheme.gold,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _shimmer() => Container(color: AppTheme.surfaceHigh);

  Widget _posterPlaceholder() => Container(
        color: AppTheme.surfaceHigh,
        child: const Center(
          child: Icon(CupertinoIcons.film,
              color: AppTheme.textTertiary, size: 28),
        ),
      );

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
                'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }
}
