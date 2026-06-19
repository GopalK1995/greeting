import '../config/app_config.dart';

class TmdbMovie {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final List<int> genreIds;
  final List<Genre> genres;
  final int? runtime;
  final String? tagline;
  final String? imdbId;
  final List<WatchProvider> flatrateProviders; // subscription platforms
  final List<WatchProvider> rentProviders;

  TmdbMovie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.genreIds,
    this.genres = const [],
    this.runtime,
    this.tagline,
    this.imdbId,
    this.flatrateProviders = const [],
    this.rentProviders = const [],
  });

  String get posterUrl =>
      posterPath != null ? '${AppConfig.tmdbImageBase}$posterPath' : '';

  String get backdropUrl =>
      backdropPath != null ? '${AppConfig.tmdbImageBaseHD}$backdropPath' : '';

  String get year =>
      releaseDate.isNotEmpty ? releaseDate.substring(0, 4) : '';

  String get ratingFormatted => voteAverage.toStringAsFixed(1);

  factory TmdbMovie.fromJson(Map<String, dynamic> json) {
    return TmdbMovie(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      overview: json['overview'] as String? ?? '',
      releaseDate: json['release_date'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      genreIds: (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      runtime: json['runtime'] as int?,
      tagline: json['tagline'] as String?,
      imdbId: json['imdb_id'] as String?,
    );
  }

  TmdbMovie copyWithProviders({
    List<WatchProvider>? flatrate,
    List<WatchProvider>? rent,
  }) {
    return TmdbMovie(
      id: id,
      title: title,
      posterPath: posterPath,
      backdropPath: backdropPath,
      overview: overview,
      releaseDate: releaseDate,
      voteAverage: voteAverage,
      voteCount: voteCount,
      genreIds: genreIds,
      genres: genres,
      runtime: runtime,
      tagline: tagline,
      imdbId: imdbId,
      flatrateProviders: flatrate ?? flatrateProviders,
      rentProviders: rent ?? rentProviders,
    );
  }
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  static const Map<int, String> idToName = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Science Fiction',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
  };
}

class WatchProvider {
  final int providerId;
  final String providerName;
  final String? logoPath;

  WatchProvider({
    required this.providerId,
    required this.providerName,
    this.logoPath,
  });

  String get logoUrl =>
      logoPath != null ? '${AppConfig.tmdbImageBase}$logoPath' : '';

  // Known provider IDs for India
  static const int netflixId = 8;
  static const int primeVideoId = 119;
  static const int hotstarId = 122;
  static const int jiocinemaId = 220;
  static const int sonylivId = 237;
  static const int zee5Id = 232;
  static const int mxPlayerId = 515;

  bool get isNetflix => providerId == netflixId;
  bool get isPrime => providerId == primeVideoId;
  bool get isHotstar => providerId == hotstarId;
  bool get isJioCinema => providerId == jiocinemaId;
  bool get isSonyLiv => providerId == sonylivId;
  bool get isZee5 => providerId == zee5Id;

  factory WatchProvider.fromJson(Map<String, dynamic> json) {
    return WatchProvider(
      providerId: json['provider_id'] as int,
      providerName: json['provider_name'] as String,
      logoPath: json['logo_path'] as String?,
    );
  }
}
