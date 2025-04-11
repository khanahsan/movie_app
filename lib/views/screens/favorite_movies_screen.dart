import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/providers/favorites_provider.dart';

import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class FavoriteMoviesScreen extends StatefulWidget {
  const FavoriteMoviesScreen({super.key});

  @override
  State<FavoriteMoviesScreen> createState() => _FavoriteMoviesScreenState();
}

class _FavoriteMoviesScreenState extends State<FavoriteMoviesScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        return Scaffold(
          body: favoritesProvider.favoriteMovies.isEmpty
              ? const Center(child: Text('No favorite movies yet!'))
              : ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: favoritesProvider.favoriteMovies.length,
            itemBuilder: (context, index) {
              final movie = favoritesProvider.favoriteMovies[index];
              final tag = 'movie_poster_${movie.id}'; // Unique tag for Hero animation
              return GestureDetector(
                onTap: () {
                  // Navigate to MovieDetailScreen when the movie item is tapped
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
                      // Movie Poster with Hero animation
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
                      // Movie Title and Year
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
                              movie.releaseDate.isNotEmpty
                                  ? DateTime.parse(movie.releaseDate).year.toString()
                                  : 'N/A',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Favorite Button to Remove from Favorites
                      IconButton(
                        onPressed: () {
                          favoritesProvider.toggleFavorite(movie);
                        },
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red, // Always red since this is the favorites screen
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}