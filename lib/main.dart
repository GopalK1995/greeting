import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/movie_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MovieProvider()),
      ],
      child: const CineLogApp(),
    ),
  );
}

class CineLogApp extends StatelessWidget {
  const CineLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _Root(),
    );
  }
}

/// Listens to auth state. Shows AuthScreen if not signed in,
/// otherwise shows the main tab navigator and starts Firestore sync.
class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final movies = context.read<MovieProvider>();

    if (!auth.isSignedIn) {
      // Stop any previous listener when signed out
      movies.stopListening();
      return const AuthScreen();
    }

    // Start real-time Firestore listener for this user
    movies.startListening(auth.uid);

    return const _MainTabs();
  }
}

class _MainTabs extends StatefulWidget {
  const _MainTabs();

  @override
  State<_MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<_MainTabs> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceHigh,
          border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _tab(0, CupertinoIcons.film_fill, CupertinoIcons.film, 'Collection'),
                _tab(1, CupertinoIcons.search_circle_fill, CupertinoIcons.search_circle, 'Discover'),
                _tab(2, CupertinoIcons.person_circle_fill, CupertinoIcons.person_circle, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(int idx, IconData activeIcon, IconData inactiveIcon, String label) {
    final selected = _index == idx;
    return GestureDetector(
      onTap: () => setState(() => _index = idx),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 90,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            selected ? activeIcon : inactiveIcon,
            color: selected ? AppTheme.accent : AppTheme.textTertiary,
            size: 26,
          ),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(
            color: selected ? AppTheme.accent : AppTheme.textTertiary,
            fontSize: 10,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          )),
        ]),
      ),
    );
  }
}
