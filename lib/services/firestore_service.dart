import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_movie.dart';
import '../models/tmdb_movie.dart';

/// Firestore structure:
/// users/{uid}/movies/{tmdbId}  →  UserMovie document
/// users/{uid}/profile          →  { displayName, email, photoUrl }

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _moviesCol(String uid) =>
      _db.collection('users').doc(uid).collection('movies');

  DocumentReference<Map<String, dynamic>> _profileDoc(String uid) =>
      _db.collection('users').doc(uid);

  // ── Profile ─────────────────────────────────────────────────────────────

  Future<void> upsertProfile(String uid,
      {required String name,
      required String email,
      required String photoUrl}) async {
    await _profileDoc(uid).set({
      'displayName': name,
      'email': email,
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── Movies ───────────────────────────────────────────────────────────────

  Stream<List<UserMovie>> watchUserMovies(String uid) {
    return _moviesCol(uid)
        .orderBy('addedDate', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => UserMovie.fromFirestore(doc)).toList());
  }

  Future<List<UserMovie>> getUserMovies(String uid) async {
    final snap = await _moviesCol(uid)
        .orderBy('addedDate', descending: true)
        .get();
    return snap.docs.map((doc) => UserMovie.fromFirestore(doc)).toList();
  }

  Future<UserMovie?> getMovie(String uid, int tmdbId) async {
    final doc = await _moviesCol(uid).doc('$tmdbId').get();
    if (!doc.exists) return null;
    return UserMovie.fromFirestore(doc);
  }

  /// Add a movie to watchlist or mark as watched
  Future<void> addMovie(String uid, TmdbMovie movie,
      {required WatchStatus status, String? watchedOnPlatform}) async {
    final userMovie = UserMovie(
      id: '${movie.id}',
      tmdbId: movie.id,
      title: movie.title,
      posterPath: movie.posterPath ?? '',
      releaseDate: movie.releaseDate,
      tmdbRating: movie.voteAverage,
      status: status,
      addedDate: DateTime.now(),
      watchedDate: status == WatchStatus.watched ? DateTime.now() : null,
      watchedOnPlatform: watchedOnPlatform,
    );
    await _moviesCol(uid).doc('${movie.id}').set(userMovie.toFirestore());
  }

  Future<void> updateStatus(
      String uid, int tmdbId, WatchStatus status) async {
    final updates = <String, dynamic>{
      'status': status.name,
    };
    if (status == WatchStatus.watched) {
      updates['watchedDate'] = Timestamp.fromDate(DateTime.now());
    }
    await _moviesCol(uid).doc('$tmdbId').update(updates);
  }

  Future<void> updateRating(
      String uid, int tmdbId, double rating) async {
    await _moviesCol(uid).doc('$tmdbId').update({'userRating': rating});
  }

  Future<void> toggleFavorite(
      String uid, int tmdbId, bool isFavorite) async {
    await _moviesCol(uid)
        .doc('$tmdbId')
        .update({'isFavorite': isFavorite});
  }

  Future<void> removeMovie(String uid, int tmdbId) async {
    await _moviesCol(uid).doc('$tmdbId').delete();
  }

  Future<void> updateNote(String uid, int tmdbId, String note) async {
    await _moviesCol(uid).doc('$tmdbId').update({'note': note});
  }
}
