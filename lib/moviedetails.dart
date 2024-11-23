import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/cast_profile_page.dart';
import 'package:movie_app/services/watchlist_service.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher package

class MovieDetailsPage extends StatefulWidget {
  final int movieId;

  MovieDetailsPage({required this.movieId});

  @override
  _MovieDetailsPageState createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  late Future<Map<String, dynamic>> movieDetailsFuture;
  bool isInWatchlist = false;

  @override
  void initState() {
    super.initState();
    movieDetailsFuture = fetchMovieDetails();
  }

  Future<Map<String, dynamic>> fetchMovieDetails() async {
    final url =
        'https://api.themoviedb.org/3/movie/${widget.movieId}?api_key=565b880331fb02dfe1fc15149be91f15&append_to_response=credits';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  void toggleWatchlist(int movieId) async {
    try {
      if (isInWatchlist) {
        await WatchlistService('your_token').removeFromWatchlist(movieId);
      } else {
        await WatchlistService('your_token').addToWatchlist(movieId);
      }

      setState(() {
        isInWatchlist = !isInWatchlist;
      });
    } catch (error) {
      print('Error updating watchlist: $error');
    }
  }

  // Method to launch the TMDB URL
  void _launchTMDBPage(int movieId) async {
    final url = 'https://www.themoviedb.org/movie/$movieId';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
          var releaseDate = movie['release_date'] ?? 'Unknown Release Date';
          var rating = movie['vote_average'] != null ? movie['vote_average'].toString() : 'N/A';
          var overview = movie['overview'] ?? 'No overview available.';
          
          var cast = (movie['credits']['cast'] as List).take(5).toList();

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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    child: Text(
                      genres.isNotEmpty ? 'Genres: $genres' : 'Genres not available',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
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
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cast',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        cast.isEmpty
                            ? Text(
                                'No cast information available.',
                                style: TextStyle(color: Colors.white70),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: cast.length,
                                itemBuilder: (context, index) {
                                  var actor = cast[index];
                                  return ListTile(
                                    leading: actor['profile_path'] != null
                                        ? ClipOval(
                                            child: Image.network(
                                              'https://image.tmdb.org/t/p/w500${actor['profile_path']}',
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : CircleAvatar(
                                            backgroundColor: Colors.grey,
                                            child: Icon(Icons.person, color: Colors.white),
                                          ),
                                    title: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CastProfilePage(actorId: actor['id']),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        actor['name'],
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    subtitle: Text(
                                      actor['character'] ?? 'Character not available',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  );
                                },
                              ),
                        SizedBox(height: 20),
                        Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
  child: ElevatedButton(
    onPressed: () => _launchTMDBPage(widget.movieId), // Launch TMDB page
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      backgroundColor: Colors.blue, // Button color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.info_outline, color: Colors.white), // Added info icon
        SizedBox(width: 10),
        Text(
          'More Info',
          style: TextStyle(fontSize: 18, color: Colors.white), // Updated text style
        ),
      ],
    ),
  ),
),

                      ],
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
