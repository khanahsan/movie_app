import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../providers/api_repository_provider.dart';
import '../model/movie_reponse_model.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import 'dart:async';

class PopularMoviesScreen extends StatefulWidget {

  PopularMoviesScreen({super.key});


  @override
  State<PopularMoviesScreen> createState() => _PopularMoviesScreenState();
}

class _PopularMoviesScreenState extends State<PopularMoviesScreen> {
  List<Movie> filteredMovies = [];
  int currentPage = 1;
  bool isLoadingMore = false;
  bool canFetchMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final apiRepo = Provider.of<APIRepository>(context, listen: false);
      apiRepo.fetchPopularMovies(page: currentPage, clear: true);
    });


    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.9 &&
          !isLoadingMore &&
          canFetchMore) {
        final apiRepo = Provider.of<APIRepository>(context, listen: false);
        if (currentPage < apiRepo.totalPages) {
          canFetchMore = false;
          currentPage++;
          setState(() {
            isLoadingMore = true;
          });
          apiRepo.fetchPopularMovies(page: currentPage).then((_) {
            setState(() {
              isLoadingMore = false;
              canFetchMore = true;
            });
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String getReleaseYear(String releaseDate) {
    try {
      return releaseDate.isNotEmpty
          ? DateTime.parse(releaseDate).year.toString()
          : 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<APIRepository>(
      builder: (context, apiRepo, child) {
        if (apiRepo.isLoading && apiRepo.upcomingMovies.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (apiRepo.errorMessage.isNotEmpty && apiRepo.upcomingMovies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(apiRepo.errorMessage),
                TextButton(
                  onPressed: () {
                    apiRepo.clearError();
                    apiRepo.fetchPopularMovies(page: 1, clear: true);
                    currentPage = 1;
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }




        final moviesToDisplay = apiRepo.upcomingMovies;
        /* return RefreshIndicator(
          onRefresh: () async {
            currentPage = 1;
            await Provider.of<APIRepository>(context, listen: false)
                .fetchPopularMovies(page: currentPage, clear: true);
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(10),
            itemCount: moviesToDisplay.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == moviesToDisplay.length) {
                return const Center(child: CircularProgressIndicator());
              }
              if (index == moviesToDisplay.length && apiRepo.errorMessage.isNotEmpty) {
                return Center(
                  child: Column(
                    children: [
                      Text('Error loading page $currentPage: ${apiRepo.errorMessage}'),
                      TextButton(
                        onPressed: () {
                          apiRepo.clearError();
                          apiRepo.fetchPopularMovies(page: currentPage);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              final movie = moviesToDisplay[index];
              return Consumer<FavoritesProvider>(
                builder: (context, favoritesProvider, child) {
                  final isFavorite = favoritesProvider.favoriteMovies.contains(movie);
                  int tag = Random().nextInt(1000000);
                  movie.tag = tag;
                  return GestureDetector(
                    onTap: () {
                      GoRouter.of(context).push(
                        '/movieDetailScreen',
                        extra: movie,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Hero(
                              tag: tag,
                              child: CachedNetworkImage(
                                imageUrl: 'https://image.tmdb.org/t/p/original/${movie.posterPath}',
                                width: 80,
                                height: 120,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 80,
                                    height: 120,
                                    color: Colors.grey[300],
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 80,
                                  height: 120,
                                  color: Colors.grey,
                                  child: const Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  getReleaseYear(movie.releaseDate),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              favoritesProvider.toggleFavorite(movie);
                            },
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );*/

        return RefreshIndicator(
          onRefresh: () async {
            // Reset the current page to 1 for a full refresh
            currentPage = 1;
            final apiRepo = Provider.of<APIRepository>(context, listen: false);

            // Clear any existing error message before refreshing
            apiRepo.clearError();

            // Call fetchPopularMovies, which already includes an internet check
            await apiRepo.fetchPopularMovies(page: currentPage, clear: true);

            // Check if the fetch failed due to no internet connection
            if (apiRepo.errorMessage == 'No internet connection') {
              // Show a SnackBar to inform the user
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.wifi_off,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No internet connection. Please check your connection and try again.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'Retry',
                    textColor: Theme.of(context).colorScheme.onErrorContainer,
                    onPressed: () {
                      // Retry the refresh
                      apiRepo.clearError();
                      apiRepo.fetchPopularMovies(page: currentPage, clear: true);
                    },
                  ),
                ),
              );
            }
          },
          child: Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: moviesToDisplay.length + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == moviesToDisplay.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (index == moviesToDisplay.length && apiRepo.errorMessage.isNotEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          Text('Error loading page $currentPage: ${apiRepo.errorMessage}'),
                          TextButton(
                            onPressed: () {
                              apiRepo.clearError();
                              apiRepo.fetchPopularMovies(page: currentPage);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  final movie = moviesToDisplay[index];
                  final tag = 'movie_poster_${movie.id}'; // Use a unique tag based on movie ID
                  return Consumer<FavoritesProvider>(
                    builder: (context, favoritesProvider, child) {
                      final isFavorite = favoritesProvider.favoriteMovies.contains(movie);
                      return GestureDetector(
                        onTap: () {
                          GoRouter.of(context).push(
                            '/movieDetailScreen',
                            extra: movie,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Hero(
                                  tag: tag,
                                  child: CachedNetworkImage(
                                    imageUrl: 'https://image.tmdb.org/t/p/original/${movie.posterPath}',
                                    width: 80,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        width: 80,
                                        height: 120,
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      width: 80,
                                      height: 120,
                                      color: Colors.grey,
                                      child: const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      getReleaseYear(movie.releaseDate),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  favoritesProvider.toggleFavorite(movie);
                                },
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),


            ],
          ),
        );
      },
    );
  }
}