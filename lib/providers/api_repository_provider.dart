import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/network/constants.dart';
import '../model/genere_model.dart';
import '../model/movie_reponse_model.dart';
import '../screens/trailer_player_screen.dart';
import '../data/network/endPoints.dart' as end_point;

class APIRepository extends ChangeNotifier {
  List<Movie> _upcomingMovies = [];
  List<Genre> _genres = [];
  bool _isLoading = false;
  String _errorMessage = '';
  int _totalPages = 1; // Add total pages field

  List<Movie> get upcomingMovies => _upcomingMovies;
  List<Genre> get genres => _genres;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get totalPages => _totalPages;


  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

// Fetch Popular Movies with pagination
  Future<void> fetchPopularMovies({required int page, bool clear = false}) async {

    bool hasInternet = await _checkInternetConnection();
    if (!hasInternet) {
      _errorMessage = 'No internet connection';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    if (clear) {
      _upcomingMovies.clear(); // Clear the list if starting fresh
    }
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${end_point.baseUrl}${end_point.upComingApiUrl}&page=$page'),
      );


      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> movieData = data['results'];
        _totalPages = data['total_pages'];
        final newMovies = movieData.map((movie) => Movie.fromJson(movie)).toList();
        _upcomingMovies.addAll(newMovies);
        print('_upcomingMovies $_upcomingMovies');
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('Error occurred: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Trailer
  Future<void> fetchTrailer(BuildContext context, int movieId) async {
    bool hasInternet = await _checkInternetConnection();
    if (!hasInternet) {
      _errorMessage = 'No internet connection';
      notifyListeners();
      return;
    }
    final url = '${end_point.baseUrl}$movieId/videos?api_key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final videos = json.decode(response.body)['results'];
        final trailer = videos.firstWhere(
              (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
          orElse: () => null,
        );
        if (trailer != null) {
          final trailerId = trailer['key'];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrailerPlayerScreen(videoId: trailerId),
            ),
          );
        }
      } else {
        throw Exception('Failed to load trailer');
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
