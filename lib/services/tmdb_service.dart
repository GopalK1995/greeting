import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/tmdb_movie.dart';

class TmdbService {
  static final TmdbService _instance = TmdbService._internal();
  factory TmdbService() => _instance;
  TmdbService._internal();

  final _client = http.Client();

  String _url(String path, {Map<String, String>? extra}) {
    final params = {
      'api_key': AppConfig.tmdbApiKey,
      'language': 'en-US',
      ...?extra,
    };
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '${AppConfig.tmdbBaseUrl}$path?$query';
  }

  Future<List<TmdbMovie>> getTrending() async {
    final res = await _client.get(Uri.parse(_url('/trending/movie/week')));
    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;
    return results
        .map((e) => TmdbMovie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<TmdbMovie>> getPopular({int page = 1}) async {
    final res = await _client
        .get(Uri.parse(_url('/movie/popular', extra: {'page': '$page'})));
    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;
    return results
        .map((e) => TmdbMovie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<TmdbMovie>> getNowPlaying() async {
    final res = await _client.get(Uri.parse(_url('/movie/now_playing',
        extra: {'region': AppConfig.watchRegion})));
    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;
    return results
        .map((e) => TmdbMovie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<TmdbMovie>> search(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];
    final res = await _client.get(Uri.parse(_url('/search/movie',
        extra: {
          'query': Uri.encodeComponent(query),
          'page': '$page',
          'region': AppConfig.watchRegion,
        })));
    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;
    return results
        .map((e) => TmdbMovie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TmdbMovie?> getMovieDetails(int movieId) async {
    final res = await _client.get(Uri.parse(_url('/movie/$movieId')));
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final movie = TmdbMovie.fromJson(data);

    // Fetch watch providers for India
    final providers = await getWatchProviders(movieId);
    return movie.copyWithProviders(
      flatrate: providers['flatrate'] ?? [],
      rent: providers['rent'] ?? [],
    );
  }

  Future<Map<String, List<WatchProvider>>> getWatchProviders(
      int movieId) async {
    final res = await _client
        .get(Uri.parse(_url('/movie/$movieId/watch/providers')));
    if (res.statusCode != 200) return {};

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = data['results'] as Map<String, dynamic>?;
    if (results == null) return {};

    // Prioritise IN (India), fall back to US
    final region =
        results['IN'] as Map<String, dynamic>? ??
        results['US'] as Map<String, dynamic>? ??
        {};

    List<WatchProvider> parseProviders(String key) {
      final list = region[key] as List<dynamic>?;
      if (list == null) return [];
      return list
          .map((e) => WatchProvider.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return {
      'flatrate': parseProviders('flatrate'),
      'rent': parseProviders('rent'),
      'buy': parseProviders('buy'),
    };
  }

  Future<List<TmdbMovie>> getSimilar(int movieId) async {
    final res = await _client
        .get(Uri.parse(_url('/movie/$movieId/similar')));
    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;
    return results
        .take(10)
        .map((e) => TmdbMovie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>?> getCredits(int movieId) async {
    final res = await _client
        .get(Uri.parse(_url('/movie/$movieId/credits')));
    if (res.statusCode != 200) return null;
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
