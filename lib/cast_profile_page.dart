import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/moviedetails.dart';
import 'dart:convert';

class CastProfilePage extends StatelessWidget {
  final int actorId;

  CastProfilePage({required this.actorId});

  final String apiKey = '565b880331fb02dfe1fc15149be91f15'; // Replace with your TMDb API Key

  // Function to fetch actor details from TMDb
  Future<Map<String, dynamic>> fetchActorDetails() async {
    final url = 'https://api.themoviedb.org/3/person/$actorId?api_key=$apiKey&append_to_response=movie_credits';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body); // Parse the JSON response
    } else {
      throw Exception('Failed to load actor details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cast Profile'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchActorDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data found'));
          }

          var actor = snapshot.data!;
          var movies = actor['movie_credits']['cast'] as List;

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
                  // Actor's Profile Image
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ClipOval(
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w500${actor['profile_path']}',
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Biography
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      actor['biography'] ?? 'Biography not available.',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  // Known For Section
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Known For:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  // Movies List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      var movie = movies[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigate to MovieDetailsPage when tapping on a movie
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailsPage(movieId: movie['id']),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                          child: Text(
                            movie['title'],
                            style: TextStyle(color: Colors.grey[300], fontSize: 16),
                          ),
                        ),
                      );
                    },
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
