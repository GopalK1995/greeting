import 'dart:async';
import 'package:flutter/material.dart';
import '../models/tmdb_movie.dart';
import '../models/user_movie.dart';
import '../services/tmdb_service.dart';
import '../services/firestore_service.dart';

class MovieProvider extends ChangeNotifier {
  final TmdbService _tmdb = TmdbService();
  final FirestoreService _db = FirestoreService();

  // ── TMDB data ─────────────────────────────────────────────────────────────
  List<TmdbMovie> trending = [];
  List<TmdbMovie> popular = [];
  List<TmdbMovie> nowPlaying = [];
  List<TmdbMovie> searchResults = [];

  bool loadingTrending = false;
  bool loadingSearch = false;
  String searchQuery = '';

  // ── User library (from Firestore) ─────────────────────────────────────────
  List<UserMovie> _userMovies = [];
  StreamSubscription<List<UserMovie>>? _moviesSubscription;

  List<UserMovie> get watched =>
      _userMovies.where((m) => m.status == WatchStatus.watched).toList();

  List<UserMovie> get watchlist =>
      _userMovies.where((m) => m.status == WatchStatus.watchlist).toList();

  List<UserMovie> get favorites =>
      _userMovies.where((m) => m.isFavorite).toList();

  bool isInLibrary(int tmdbId) =>
      _userMovies.any((m) => m.tmdbId == tmdbId);

  UserMovie? getUserMovie(int tmdbId) =>
      _userMovies.cast<UserMovie?>().firstWhere(
            (m) => m?.tmdbId == tmdbId,
            orElse: () => null,
          );

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  void startListening(String uid) {
    _moviesSubscription?.cancel();
    _moviesSubscription = _db.watchUserMovies(uid).listen((movies) {
      _userMovies = movies;
      notifyListeners();
    });
  }

  void stopListening() {
    _moviesSubscription?.cancel();
    _moviesSubscription = null;
    _userMovies = [];
    notifyListeners();
  }

  Future<void> loadDiscovery() async {
    loadingTrending = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _tmdb.getTrending(),
        _tmdb.getPopular(),
        _tmdb.getNowPlaying(),
      ]);
      trending = results[0];
      popular = results[1];
      nowPlaying = results[2];
    } finally {
      loadingTrending = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    searchQuery = query;
    if (query.trim().isEmpty) {
      searchResults = [];
      notifyListeners();
      return;
    }
    loadingSearch = true;
    notifyListeners();
    try {
      searchResults = await _tmdb.search(query);
    } finally {
      loadingSearch = false;
      notifyListeners();
    }
  }

  Future<TmdbMovie?> getDetails(int movieId) =>
      _tmdb.getMovieDetails(movieId);

  // ── Library actions ───────────────────────────────────────────────────────

  Future<void> addToWatchlist(String uid, TmdbMovie movie) async {
    await _db.addMovie(uid, movie, status: WatchStatus.watchlist);
  }

  Future<void> markWatched(String uid, TmdbMovie movie,
      {String? platform}) async {
    if (isInLibrary(movie.id)) {
      await _db.updateStatus(uid, movie.id, WatchStatus.watched);
    } else {
      await _db.addMovie(uid, movie,
          status: WatchStatus.watched, watchedOnPlatform: platform);
    }
  }

  Future<void> toggleFavorite(String uid, int tmdbId) async {
    final movie = getUserMovie(tmdbId);
    if (movie == null) return;
    await _db.toggleFavorite(uid, tmdbId, !movie.isFavorite);
  }

  Future<void> setRating(String uid, int tmdbId, double rating) async {
    await _db.updateRating(uid, tmdbId, rating);
  }

  Future<void> removeFromLibrary(String uid, int tmdbId) async {
    await _db.removeMovie(uid, tmdbId);
  }
}
