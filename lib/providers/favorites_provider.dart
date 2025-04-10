import 'package:flutter/material.dart';

import '../model/movie_reponse_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesProvider with ChangeNotifier {
  List<Movie> _favoriteMovies = [];

  FavoritesProvider() {
    _loadFavorites(); // Load favorites when the provider is created
  }

  List<Movie> get favoriteMovies => _favoriteMovies;

  void _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString('favoriteMovies');
    if (favoritesJson != null) {
      final List<dynamic> favoritesList = jsonDecode(favoritesJson);
      _favoriteMovies = favoritesList.map((json) => Movie.fromJson(json)).toList();
      notifyListeners();
    }
  }

  void _saveFavorites() async {
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
    _saveFavorites(); // Save the updated list
    notifyListeners();
  }
}