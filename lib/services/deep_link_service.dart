import 'package:url_launcher/url_launcher.dart';
import '../models/tmdb_movie.dart';

/// Opens the movie directly in the streaming app.
/// Strategy:
///   1. Try the app's URI scheme (opens native app if installed).
///   2. Fall back to the HTTPS URL (opens in browser / universal link).
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> openOnProvider(WatchProvider provider, TmdbMovie movie) async {
    switch (provider.providerId) {
      case WatchProvider.netflixId:
        await _openNetflix(movie);
      case WatchProvider.primeVideoId:
        await _openPrimeVideo(movie);
      case WatchProvider.hotstarId:
        await _openHotstar(movie);
      case WatchProvider.jiocinemaId:
        await _openJioCinema(movie);
      case WatchProvider.sonylivId:
        await _openSonyLiv(movie);
      case WatchProvider.zee5Id:
        await _openZee5(movie);
      default:
        await _openGenericSearch(provider.providerName, movie.title);
    }
  }

  Future<void> openBookMyShow(TmdbMovie movie) async {
    // BookMyShow cinema ticketing — search by movie name
    final query = Uri.encodeComponent(movie.title);
    await _tryLaunch(
      appUri: 'bookmyshow://search?q=$query',
      webUrl: 'https://in.bookmyshow.com/search?q=$query',
    );
  }

  // ── Per-platform openers ──────────────────────────────────────────────────

  Future<void> _openNetflix(TmdbMovie movie) async {
    // Netflix supports title search via universal link
    final query = Uri.encodeComponent(movie.title);
    await _tryLaunch(
      appUri: 'nflx://www.netflix.com/search?q=$query',
      webUrl: 'https://www.netflix.com/search?q=$query',
    );
  }

  Future<void> _openPrimeVideo(TmdbMovie movie) async {
    final query = Uri.encodeComponent(movie.title);
    await _tryLaunch(
      appUri: 'aiv://aiv/search?phrase=$query',
      webUrl:
          'https://www.primevideo.com/search?phrase=$query',
    );
  }

  Future<void> _openHotstar(TmdbMovie movie) async {
    final query = Uri.encodeComponent(movie.title);
    await _tryLaunch(
      appUri: 'hotstar://search/$query',
      webUrl:
          'https://www.hotstar.com/in/search?q=$query',
    );
  }

  Future<void> _openJioCinema(TmdbMovie movie) async {
    final query = Uri.encodeComponent(movie.title);
    await _tryLaunch(
      appUri: 'jiocinemain://search?q=$query',
      webUrl:
          'https://www.jiocinema.com/search?q=$query',
    );
  }

  Future<void> _openSonyLiv(TmdbMovie movie) async {
    final query = Uri.encodeComponent(movie.title);
    await _tryLaunch(
      appUri: 'sonyliv://search?q=$query',
      webUrl: 'https://www.sonyliv.com/search?keyword=$query',
    );
  }

  Future<void> _openZee5(TmdbMovie movie) async {
    final query = Uri.encodeComponent(movie.title);
    await _tryLaunch(
      appUri: 'zee5://search/$query',
      webUrl: 'https://www.zee5.com/search?q=$query',
    );
  }

  Future<void> _openGenericSearch(String platformName, String title) async {
    final query = Uri.encodeComponent('$title $platformName');
    await _tryLaunch(
      webUrl: 'https://www.google.com/search?q=$query',
    );
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  Future<void> _tryLaunch({String? appUri, required String webUrl}) async {
    // 1. Try native app URI scheme
    if (appUri != null) {
      final uri = Uri.parse(appUri);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    // 2. Fall back to web URL (universal links handle app redirect on iOS)
    final uri = Uri.parse(webUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
