import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MovieDetailsPage extends StatelessWidget {
  final int movieId;

  MovieDetailsPage({required this.movieId});

  // Replace with your TMDb API Key
  final String apiKey = '565b880331fb02dfe1fc15149be91f15'; // Ideally use environment variable

  // Function to fetch movie details from TMDb
  Future<Map<String, dynamic>> fetchMovieDetails() async {
    final url = 'https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey&append_to_response=credits';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body); // Parse the JSON response
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchMovieDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Retry fetching movie details
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => MovieDetailsPage(movieId: movieId)),
                      );
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data found'));
          }

          var movie = snapshot.data!;
          var genres = (movie['genres'] as List).map((genre) => genre['name']).toList().join(', ');
          var cast = (movie['credits']['cast'] as List).take(10).toList();

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
                            Navigator.pop(context); // Navigate back
                          },
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Movie Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
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
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
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
                  // Release Date
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Release Date: ${movie['release_date']}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[300]),
                    ),
                  ),
                  // Genres
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Genres: $genres',
                      style: TextStyle(fontSize: 16, color: Colors.grey[300]),
                    ),
                  ),
                  // Rating
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Rating: ${movie['vote_average']}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[300]),
                    ),
                  ),
                  // Runtime
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Runtime: ${movie['runtime']} minutes',
                      style: TextStyle(fontSize: 16, color: Colors.grey[300]),
                    ),
                  ),
                  // Cast Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Cast:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: cast.length,
                      itemBuilder: (context, index) {
                        var actor = cast[index];
                        return Container(
                          width: 80,
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              ClipOval(
                                child: Image.network(
                                  'https://image.tmdb.org/t/p/w500${actor['profile_path'] ?? ''}',
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                actor['name'],
                                style: TextStyle(color: Colors.grey[300], fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Overview
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      movie['overview'],
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  // Download Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Implement download functionality here
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        shadowColor: Colors.grey.shade800,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Download Movie',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
