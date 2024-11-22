import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_app/models/movie.dart'; // Adjust the path to your Movie model file

class WatchlistService {
  final String baseUrl = 'http://192.168.153.195:5000/api/users/watchlist';
  final String token;

  WatchlistService(this.token);

  Future<List<Movie>> getWatchlist() async {
    final response = await http.get(Uri.parse(baseUrl), headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // Map API response to a list of Movie objects
      return data.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch watchlist');
    }
  }

  Future<void> addToWatchlist(int movieId) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'movieId': movieId}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add to watchlist');
    }
  }

  Future<void> removeFromWatchlist(int movieId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$movieId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove from watchlist');
    }
  }
}
