import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/services/watchlist_service.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package

class MovieDetailsPage extends StatefulWidget {
  final int movieId;

  MovieDetailsPage({required this.movieId});

  @override
  _MovieDetailsPageState createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  late Future<Map<String, dynamic>> movieDetailsFuture;
  bool isInWatchlist = false; // Track if the movie is in the watchlist

  // Initialize the future with the movie details
  @override
  void initState() {
    super.initState();
    movieDetailsFuture = fetchMovieDetails();
  }

  Future<Map<String, dynamic>> fetchMovieDetails() async {
    final url =
        'https://api.themoviedb.org/3/movie/${widget.movieId}?api_key=YOUR_API_KEY&append_to_response=credits';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  // Handle adding/removing from watchlist
  void toggleWatchlist(int movieId) async {
    try {
      if (isInWatchlist) {
        // Call WatchlistService to remove from watchlist
        await WatchlistService('your_token').removeFromWatchlist(movieId);
      } else {
        // Call WatchlistService to add to watchlist
        await WatchlistService('your_token').addToWatchlist(movieId);
      }

      setState(() {
        isInWatchlist = !isInWatchlist; // Toggle the watchlist state
      });
    } catch (error) {
      // Handle any errors here
      print('Error updating watchlist: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: movieDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data found'));
          }
        
          var movie = snapshot.data!;
          var genres = (movie['genres'] as List).map((genre) => genre['name']).toList().join(', ');
          var cast = (movie['credits']['cast'] as List).take(5).toList();
          var releaseDate = movie['release_date'] ?? 'Unknown Release Date';
          var rating = movie['vote_average'] != null ? movie['vote_average'].toString() : 'N/A';
          var overview = movie['overview'] ?? 'No overview available.';

          // Build the movie's TMDb page URL
          final tmdbUrl = 'https://www.themoviedb.org/movie/${widget.movieId}';

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.grey[900]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar with back arrow and title
                  Container(
                    padding: EdgeInsets.only(top: 40, left: 20, right: 20),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Movie Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Movie Poster
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: movie['poster_path'] != null
                          ? Image.network(
                              'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                              height: 300,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 300,
                              width: double.infinity,
                              color: Colors.grey[800],
                              child: Center(
                                child: Text(
                                  'No Image Available',
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                ),
                              ),
                            ),
                    ),
                  ),
                  // Movie Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      movie['title'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Release Date & Rating
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    child: Row(
                      children: [
                        Text(
                          'Release Date: $releaseDate',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Rating: $rating',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  // Genres
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    child: Text(
                      genres.isNotEmpty ? 'Genres: $genres' : 'Genres not available',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                  // Add to Watchlist Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        toggleWatchlist(widget.movieId); // Handle adding/removing from watchlist
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        backgroundColor: isInWatchlist ? Colors.red : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.white), // Icon for adding/removing
                          SizedBox(width: 10),
                          Text(
                            isInWatchlist ? 'Remove from Watchlist' : 'Add to Watchlist',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Overview
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      overview,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  // More Info Button (Redirect to TMDb)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (await canLaunch(tmdbUrl)) {
                          await launch(tmdbUrl);
                        } else {
                          throw 'Could not launch $tmdbUrl';
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info, color: Colors.white), // Info icon
                          SizedBox(width: 10),
                          Text(
                            'More Info',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
