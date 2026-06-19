# CineLog — Your Personal Movie Collection

A **Flutter iOS app** to track all your movies across streaming platforms — like Goodreads, but for movies.

## Features

- 🎬 **Movie Collection** — View all watched movies as beautiful cards
- 🔖 **Watchlist** — Save movies you want to watch
- 🔗 **Platform Connections** — Link Amazon Prime, Netflix, Hotstar, BookMyShow, SonyLIV, ZEE5
- ⭐ **Ratings** — See IMDb ratings + add your own
- 🔍 **Search** — Search across your entire collection
- 📊 **Profile Stats** — Genre breakdown, platform breakdown, favorites

## Getting Started

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── main.dart
├── models/         # Movie, Platform, PlatformConnection
├── providers/      # MovieProvider (state management)
├── screens/        # Home, Search, Platforms, Detail, Profile
├── widgets/        # MovieCard, PlatformCard
└── theme/          # AppTheme (dark iOS-style)
```
