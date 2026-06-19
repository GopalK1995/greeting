import 'movie.dart';

class PlatformConnection {
  final Platform platform;
  bool isConnected;
  String? connectedEmail;
  DateTime? connectedAt;
  int syncedMovies;

  PlatformConnection({
    required this.platform,
    this.isConnected = false,
    this.connectedEmail,
    this.connectedAt,
    this.syncedMovies = 0,
  });

  String get name {
    switch (platform) {
      case Platform.amazonPrime:
        return 'Prime Video';
      case Platform.hotstar:
        return 'Disney+ Hotstar';
      case Platform.bookMyShow:
        return 'BookMyShow';
      case Platform.netflix:
        return 'Netflix';
      case Platform.sonyliv:
        return 'SonyLIV';
      case Platform.zee5:
        return 'ZEE5';
      default:
        return 'Manual';
    }
  }

  String get description {
    switch (platform) {
      case Platform.amazonPrime:
        return 'Sync your Prime Video watch history';
      case Platform.hotstar:
        return 'Sync your Hotstar watch history';
      case Platform.bookMyShow:
        return 'Sync your BookMyShow tickets & bookings';
      case Platform.netflix:
        return 'Sync your Netflix watch history';
      case Platform.sonyliv:
        return 'Sync your SonyLIV watch history';
      case Platform.zee5:
        return 'Sync your ZEE5 watch history';
      default:
        return '';
    }
  }

  int get gradientStart {
    switch (platform) {
      case Platform.amazonPrime:
        return 0xFF00A8E1;
      case Platform.hotstar:
        return 0xFF1F80E0;
      case Platform.bookMyShow:
        return 0xFFE5173F;
      case Platform.netflix:
        return 0xFFE50914;
      case Platform.sonyliv:
        return 0xFF0057A8;
      case Platform.zee5:
        return 0xFF8E3AF4;
      default:
        return 0xFF888888;
    }
  }

  int get gradientEnd {
    switch (platform) {
      case Platform.amazonPrime:
        return 0xFF146EB4;
      case Platform.hotstar:
        return 0xFF0A2A6E;
      case Platform.bookMyShow:
        return 0xFF8B0000;
      case Platform.netflix:
        return 0xFF831010;
      case Platform.sonyliv:
        return 0xFF003580;
      case Platform.zee5:
        return 0xFF5B21B6;
      default:
        return 0xFF555555;
    }
  }
}
