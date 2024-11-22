import 'package:movie_app/models/movie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MovieService {
  final String apiKey = '565b880331fb02dfe1fc15149be91f15'; // Replace with your TMDB API key

  

  // Fetch popular movies
  Future<List<Movie>> fetchPopularMovies({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&page=$page'),
      ).timeout(Duration(seconds: 10)); // Adding a timeout

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null) {
          return (data['results'] as List)
              .map((movieJson) => Movie.fromJson(movieJson))
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to load popular movies: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching popular movies: $e');
    }
  }

  

  // Fetch top-rated movies
  Future<List<Movie>> fetchTopRatedMovies({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.themoviedb.org/3/movie/top_rated?api_key=$apiKey&page=$page'),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null) {
          return (data['results'] as List)
              .map((movieJson) => Movie.fromJson(movieJson))
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to load top-rated movies: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching top-rated movies: $e');
    }
  }

  // Fetch new movies
  Future<List<Movie>> fetchNewMovies({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.themoviedb.org/3/movie/now_playing?api_key=$apiKey&page=$page'),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null) {
          return (data['results'] as List)
              .map((movieJson) => Movie.fromJson(movieJson))
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to load new movies: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching new movies: $e');
    }
  }

  // Search for movies
  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query'),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null) {
          return (data['results'] as List)
              .map((movieJson) => Movie.fromJson(movieJson))
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to search movies: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error searching for movies: $e');
    }
  }
}
