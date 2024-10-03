import 'package:flutter/material.dart';
import 'package:movie_app/first.dart';
import 'package:movie_app/home_page.dart';
import 'package:movie_app/login.dart';
import 'package:movie_app/movie_list_screen.dart';
import 'package:movie_app/signup.dart';

void main() {
  runApp(MovieApp());
}

class MovieApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: First(), // Initial route is the First screen
      routes: {
        '/signup': (context) => SignUpPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        // Define the route for MovieListScreen that accepts parameters
        '/movielist': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return MovieListScreen(category: args['category']!);
        },
      },
    );
  }
}
