import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/network/constants.dart';
import '../../model/movie_reponse_model.dart';
import '../../data/network/endPoints.dart' as end_point;
import '../../views/screens/trailer_player_screen.dart';

class APIRepository extends ChangeNotifier {
  List<Movie> _upcomingMovies = [];
  bool _isLoading = false;
  String _errorMessage = '';
  int _totalPages = 1;

  List<Movie> get upcomingMovies => _upcomingMovies;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get totalPages => _totalPages;



  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    try {
      final result = await InternetAddress.lookup('www.google.com').timeout(Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    }
  }

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
      _upcomingMovies.clear();
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

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
