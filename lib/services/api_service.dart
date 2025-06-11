import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:movie_app/models/movie.dart'; // Add the movie model here

class ApiService {
  static const String baseUrl = 'http://192.168.130.195:5000';
  static const String apiPath = '/api/users';
  static const String signupPath = '$apiPath/signup';
  static const String loginPath = '$apiPath/login';
  //static const String watchlistPath = '/watchlist';  // Path for the watchlist

  static String? _authToken;

  // Login user
  static Future<bool> loginUser(String email, String password, String name) async {
    try {
      final uri = Uri.parse('$baseUrl$loginPath');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', 
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          _authToken = data['token'];
          await _saveToken(_authToken!);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Signup user
  static Future<bool> signupUser(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl$signupPath');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone_number': phone,
        }),
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          _authToken = data['token'];
          await _saveToken(_authToken!);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }

  // Add movie to watchlist
  // static Future<bool> addToWatchlist(int movieId) async {
  //   try {
  //     final uri = Uri.parse('$baseUrl$watchlistPath');
  //     final response = await http.post(
  //       uri,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer $_authToken',
  //       },
  //       body: jsonEncode({'movie_id': movieId}),
  //     ).timeout(Duration(seconds: 30));

  //     if (response.statusCode == 200) {
  //       return true;
  //     } else {
  //       print('Failed to add to watchlist');
  //       return false;
  //     }
  //   } catch (e) {
  //     print('Error adding to watchlist: $e');
  //     return false;
  //   }
  // }

  
  // Save token to shared preferences
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  // Load token from shared preferences
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('authToken');
  }

  // Logout and clear token
  static Future<void> logout() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
