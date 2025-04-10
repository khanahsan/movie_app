

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../model/movie_reponse_model.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../viewmodels/providers/api_repository_provider.dart';
import '../../viewmodels/providers/favorites_provider.dart';

class SearchMoviesScreen extends StatefulWidget {
  final ValueNotifier<String> searchQuery = ValueNotifier<String>('');

  SearchMoviesScreen({super.key});

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void resetSearch() {
    searchQuery.value = '';
  }

  @override
  State<SearchMoviesScreen> createState() => _SearchMoviesScreenState();
}

class _SearchMoviesScreenState extends State<SearchMoviesScreen> with SingleTickerProviderStateMixin {
  List<Movie> filteredMovies = [];
  int currentPage = 1;
  bool isLoadingMore = false;
  bool canFetchMore = true; // Debounce flag for pagination
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounce; // Debounce timer for search
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller for the "No Data Found" message
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final apiRepo = Provider.of<APIRepository>(context, listen: false);
      apiRepo.fetchPopularMovies(page: currentPage, clear: true);
    });

    widget.searchQuery.addListener(() {
      // Debounce the search query updates
      if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 500), _applySearchFilter);
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

  void _applySearchFilter() {
    final apiRepo = Provider.of<APIRepository>(context, listen: false);
    setState(() {
      final query = widget.searchQuery.value.toLowerCase();
      filteredMovies = query.isEmpty
          ? apiRepo.upcomingMovies
          : apiRepo.upcomingMovies
          .where((movie) => movie.title.toLowerCase().contains(query))
          .toList();
    });

    // Trigger the "No Data Found" animation if there are no results
    if (filteredMovies.isEmpty && widget.searchQuery.value.isNotEmpty) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    widget.searchQuery.removeListener(() {
      if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    });
    _scrollController.dispose();
    _searchDebounce?.cancel();
    _animationController.dispose();
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

        final moviesToDisplay = widget.searchQuery.value.isNotEmpty
            ? filteredMovies
            : apiRepo.upcomingMovies;

        return RefreshIndicator(
          onRefresh: () async {
            currentPage = 1;
            final apiRepo = Provider.of<APIRepository>(context, listen: false);

            apiRepo.clearError();

            await apiRepo.fetchPopularMovies(page: currentPage, clear: true);

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
              if (moviesToDisplay.isEmpty && widget.searchQuery.value.isNotEmpty)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Data Found',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.headlineLarge?.color?.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching for another movie',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}