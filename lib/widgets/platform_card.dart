import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/platform_connection.dart';
import '../models/movie.dart';
import '../theme/app_theme.dart';

class PlatformCard extends StatelessWidget {
  final PlatformConnection connection;
  final VoidCallback onToggle;

  const PlatformCard({
    super.key,
    required this.connection,
    required this.onToggle,
  });

  String get _platformEmoji {
    switch (connection.platform) {
      case Platform.amazonPrime:
        return '📦';
      case Platform.hotstar:
        return '⭐';
      case Platform.bookMyShow:
        return '🎬';
      case Platform.netflix:
        return '🎬';
      case Platform.sonyliv:
        return '📺';
      case Platform.zee5:
        return '🎭';
      default:
        return '🎞';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color startColor = Color(connection.gradientStart);
    final Color endColor = Color(connection.gradientEnd);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            startColor.withOpacity(0.15),
            endColor.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: startColor.withOpacity(connection.isConnected ? 0.5 : 0.2),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Platform icon circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [startColor, endColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: startColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _platformEmoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Platform info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    connection.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (connection.isConnected && connection.connectedEmail != null) ...[
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.checkmark_circle_fill,
                          color: Color(0xFF30D158),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${connection.syncedMovies} movies synced',
                          style: const TextStyle(
                            color: Color(0xFF30D158),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      connection.description,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Toggle / Connect button
            GestureDetector(
              onTap: onToggle,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: connection.isConnected
                      ? Colors.transparent
                      : startColor,
                  borderRadius: BorderRadius.circular(20),
                  border: connection.isConnected
                      ? Border.all(color: AppTheme.textTertiary, width: 0.5)
                      : null,
                  boxShadow: connection.isConnected
                      ? null
                      : [
                          BoxShadow(
                            color: startColor.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Text(
                  connection.isConnected ? 'Disconnect' : 'Connect',
                  style: TextStyle(
                    color: connection.isConnected
                        ? AppTheme.textSecondary
                        : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
