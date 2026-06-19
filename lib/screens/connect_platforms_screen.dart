import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/platform_card.dart';

class ConnectPlatformsScreen extends StatelessWidget {
  const ConnectPlatformsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: AppTheme.background,
            border: null,
            largeTitle: const Text(
              'Connect Platforms',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            middle: const Text(
              'Connect Platforms',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                CupertinoIcons.back,
                color: AppTheme.accent,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Text(
                'Connect your streaming accounts to automatically sync your watched movies and watchlist.',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),

          // Connected section
          if (provider.connections.any((c) => c.isConnected)) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
                child: Text(
                  'CONNECTED',
                  style: TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final connected =
                      provider.connections.where((c) => c.isConnected).toList();
                  if (index >= connected.length) return null;
                  final conn = connected[index];
                  return PlatformCard(
                    connection: conn,
                    onToggle: () => _showDisconnectDialog(context, provider, conn.platform),
                  );
                },
                childCount:
                    provider.connections.where((c) => c.isConnected).length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],

          // Available section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
              child: Text(
                'AVAILABLE',
                style: TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final disconnected =
                    provider.connections.where((c) => !c.isConnected).toList();
                if (index >= disconnected.length) return null;
                final conn = disconnected[index];
                return PlatformCard(
                  connection: conn,
                  onToggle: () => _showConnectDialog(context, provider, conn.platform),
                );
              },
              childCount:
                  provider.connections.where((c) => !c.isConnected).length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),

          // How it works
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardBorder, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(CupertinoIcons.info_circle_fill,
                          color: AppTheme.accentLight, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'How it works',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _howItWorksItem('1', 'Connect your streaming account'),
                  _howItWorksItem('2', 'We sync your watch history automatically'),
                  _howItWorksItem('3', 'Movies appear as cards in your collection'),
                  _howItWorksItem('4', 'Rate, review & track across all platforms'),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _howItWorksItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConnectDialog(BuildContext context, MovieProvider provider, dynamic platform) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Connect Account'),
        content: const Text(
          'This will sync your watch history and watchlist from this platform.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              provider.toggleConnection(platform);
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context, MovieProvider provider, dynamic platform) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Disconnect?'),
        content: const Text(
          'Your synced movies will remain in your collection but won\'t auto-update.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              provider.toggleConnection(platform);
            },
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}
