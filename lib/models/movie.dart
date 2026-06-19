enum Platform {
  amazonPrime,
  hotstar,
  bookMyShow,
  netflix,
  sonyliv,
  zee5,
  manual,
}

enum WatchStatus {
  watched,
  watchlist,
}

class Movie {
  final String id;
  final String title;
  final String posterUrl;
  final String year;
  final String genre;
  final double imdbRating;
  double? userRating;
  final Platform platform;
  WatchStatus status;
  final String? description;
  final String? director;
  final int? durationMinutes;
  DateTime? watchedDate;
  bool isFavorite;

  Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.year,
    required this.genre,
    required this.imdbRating,
    this.userRating,
    required this.platform,
    required this.status,
    this.description,
    this.director,
    this.durationMinutes,
    this.watchedDate,
    this.isFavorite = false,
  });

  String get platformName {
    switch (platform) {
      case Platform.amazonPrime:
        return 'Prime Video';
      case Platform.hotstar:
        return 'Hotstar';
      case Platform.bookMyShow:
        return 'BookMyShow';
      case Platform.netflix:
        return 'Netflix';
      case Platform.sonyliv:
        return 'SonyLIV';
      case Platform.zee5:
        return 'ZEE5';
      case Platform.manual:
        return 'Manual';
    }
  }

  String get platformLogoAsset {
    switch (platform) {
      case Platform.amazonPrime:
        return 'assets/icons/prime.png';
      case Platform.hotstar:
        return 'assets/icons/hotstar.png';
      case Platform.bookMyShow:
        return 'assets/icons/bms.png';
      case Platform.netflix:
        return 'assets/icons/netflix.png';
      case Platform.sonyliv:
        return 'assets/icons/sonyliv.png';
      case Platform.zee5:
        return 'assets/icons/zee5.png';
      default:
        return 'assets/icons/manual.png';
    }
  }
}
