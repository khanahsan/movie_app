import 'package:flutter/material.dart';

import '../../model/movie_reponse_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesProvider with ChangeNotifier {
  List<Movie> _favoriteMovies = [];

  FavoritesProvider() {
    _initFavorites();
  }

  List<Movie> get favoriteMovies => _favoriteMovies;

  Future<void> _initFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    if (isFirstLaunch) {
      await prefs.remove('favoriteMovies');
      await prefs.setBool('isFirstLaunch', false); // Mark that the app has been launched
    }

    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString('favoriteMovies');
    if (favoritesJson != null) {
      final List<dynamic> favoritesList = jsonDecode(favoritesJson);
      _favoriteMovies = favoritesList.map((json) => Movie.fromJson(json)).toList();
    } else {
      _favoriteMovies = [];
    }
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String favoritesJson = jsonEncode(_favoriteMovies.map((movie) => movie.toJson()).toList());
    await prefs.setString('favoriteMovies', favoritesJson);
  }

  void toggleFavorite(Movie movie) {
    if (_favoriteMovies.contains(movie)) {
      _favoriteMovies.remove(movie);
    } else {
      _favoriteMovies.add(movie);
    }
    _saveFavorites();
    notifyListeners();
  }
}