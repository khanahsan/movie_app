import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/providers/favorites_provider.dart';
import 'package:movie_app/providers/theme_provider.dart';
import 'package:movie_app/screens/home_screen.dart';
import 'package:movie_app/screens/movie_detail_screen.dart';
import 'package:movie_app/screens/popular_movies_screen.dart';
import 'package:movie_app/screens/search_movies_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'providers/api_repository_provider.dart';
import 'model/movie_reponse_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await getTemporaryDirectory(); // This forces path_provider to initialize
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => APIRepository()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Add ThemeProvider
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Flutter Demo',
            debugShowCheckedModeBanner: false,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}

final GoRouter router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/homeScreen',
  routes: <RouteBase>[
    GoRoute(
      path: '/homeScreen',
      name: '/homeScreen',
      builder: (context, state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/popularMoviesScreen',
      name: '/popularMoviesScreen',
      builder: (context, state) {
        return PopularMoviesScreen();
      },
    ),
    GoRoute(
      path: '/searchScreen',
      name: '/searchScreen',
      builder: (context, state) {
        return SearchMoviesScreen();
      },
    ),
    GoRoute(
      path: '/movieDetailScreen',
      name: '/movieDetailScreen',
      builder: (context, state) {
        final movie = state.extra as Movie;
        return MovieDetailScreen(movie: movie);
      },
    ),
  ],
);