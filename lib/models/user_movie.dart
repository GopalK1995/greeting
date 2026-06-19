import 'package:cloud_firestore/cloud_firestore.dart';

enum WatchStatus { watched, watchlist }

class UserMovie {
  final String id; // Firestore doc id (same as tmdbId as string)
  final int tmdbId;
  final String title;
  final String posterPath;
  final String releaseDate;
  final double tmdbRating;
  WatchStatus status;
  double? userRating;
  DateTime? watchedDate;
  DateTime addedDate;
  bool isFavorite;
  String? note;
  // Which platform the user added this from / watched it on
  String? watchedOnPlatform;

  UserMovie({
    required this.id,
    required this.tmdbId,
    required this.title,
    required this.posterPath,
    required this.releaseDate,
    required this.tmdbRating,
    required this.status,
    this.userRating,
    this.watchedDate,
    required this.addedDate,
    this.isFavorite = false,
    this.note,
    this.watchedOnPlatform,
  });

  String get year =>
      releaseDate.isNotEmpty ? releaseDate.substring(0, 4) : '';

  Map<String, dynamic> toFirestore() {
    return {
      'tmdbId': tmdbId,
      'title': title,
      'posterPath': posterPath,
      'releaseDate': releaseDate,
      'tmdbRating': tmdbRating,
      'status': status.name,
      'userRating': userRating,
      'watchedDate':
          watchedDate != null ? Timestamp.fromDate(watchedDate!) : null,
      'addedDate': Timestamp.fromDate(addedDate),
      'isFavorite': isFavorite,
      'note': note,
      'watchedOnPlatform': watchedOnPlatform,
    };
  }

  factory UserMovie.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserMovie(
      id: doc.id,
      tmdbId: data['tmdbId'] as int,
      title: data['title'] as String,
      posterPath: data['posterPath'] as String? ?? '',
      releaseDate: data['releaseDate'] as String? ?? '',
      tmdbRating: (data['tmdbRating'] as num?)?.toDouble() ?? 0.0,
      status: WatchStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => WatchStatus.watchlist,
      ),
      userRating: (data['userRating'] as num?)?.toDouble(),
      watchedDate: (data['watchedDate'] as Timestamp?)?.toDate(),
      addedDate: (data['addedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isFavorite: data['isFavorite'] as bool? ?? false,
      note: data['note'] as String?,
      watchedOnPlatform: data['watchedOnPlatform'] as String?,
    );
  }
}
