import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../model/movie_reponse_model.dart';
import '../../viewmodels/providers/api_repository_provider.dart';
import '../../viewmodels/providers/favorites_provider.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {

  @override
  void initState() {
    super.initState();
  }

  String formatReleaseDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final formatter = DateFormat('MMMM dd, yyyy');
    return formatter.format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {

    final movie = widget.movie;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 2,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Hero(
                      tag: movie.tag,
                      child: CachedNetworkImage(
                        imageUrl: 'https://image.tmdb.org/t/p/original/${movie.posterPath}',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 10,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            context.pop();
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Popular Movies',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                      bottom: 140,
                      child: Text(
                        'In Theaters ${formatReleaseDate(movie.releaseDate)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )),
                  Positioned(
                    bottom: 70,
                    child: Column(
                      children: [

                        SizedBox(
                          width: 200, // Use the same fixed width here
                          child: OutlinedButton.icon(
                            onPressed: () {
                              APIRepository().fetchTrailer(context, movie.id);
                            },
                            icon: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Watch Trailer',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              side: const BorderSide(
                                color: Colors.lightBlueAccent,
                                width: 2.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          Expanded(
              child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: movie.voteAverage / 2, // Convert 0-10 scale to 0-5
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 30.0,
                        unratedColor: Colors.grey[300],
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${movie.voteAverage.toStringAsFixed(1)}/10',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Overview',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    movie.overview ?? 'No description available',
                    style: const TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10,),
                  Consumer<FavoritesProvider>(
                    builder: (context, favoritesProvider, child) {
                      final isFavorite = favoritesProvider.favoriteMovies.contains(movie);
                      return SizedBox(
                        width: double.infinity, // Make the button full-width
                        child: OutlinedButton.icon(
                          onPressed: () {
                            favoritesProvider.toggleFavorite(movie);
                          },
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                          label: Text(
                            isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                            style: TextStyle(
                              color: isFavorite ? Colors.red : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isFavorite ? Colors.red.withOpacity(0.1) : Colors.transparent,
                            side: BorderSide(
                              color: isFavorite ? Colors.red : Colors.grey,
                              width: 2.0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}
