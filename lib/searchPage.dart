import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Add flutter_spinkit package
import 'package:movie_app/moviedetails.dart';
import 'package:movie_app/services/movie_service.dart';
import 'package:movie_app/models/movie.dart';
import 'dart:async';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<Movie>>? _searchResults;
  Timer? _debounce;

  // Set a limit for the number of results to show
  final int _resultLimit = 10;
  
  // Debounce the search input to avoid firing multiple API requests
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _searchMovies();
      } else {
        setState(() {
          _searchResults = null; // Clear results if search is empty
        });
      }
    });
  }

  // Clear the search input and results
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = null;
    });
  }

  // Search movies using the MovieService
  void _searchMovies() {
    setState(() {
      _searchResults = MovieService().searchMovies(_searchController.text).catchError((error) {
        print("Error fetching movies: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching movies. Please try again.')),
        );
        return <Movie>[]; // Return an empty list on error
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged); // Listen to text field changes
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Clean up the debounce timer
    _searchController.dispose(); // Dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Movies'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200], // Light background
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded edges
                  borderSide: BorderSide.none,
                ),
                labelText: 'Search Movies',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
              ),
              onSubmitted: (_) => _searchMovies(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: _searchResults,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: SpinKitFadingCircle(color: Colors.black), // Custom loading spinner
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error occurred: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  final movies = snapshot.data!;
                  if (movies.isEmpty) {
                    return _buildEmptyState(); // Show when no results
                  }

                  // Limit the results to the specified number
                  final limitedMovies = movies.take(_resultLimit).toList();

                  return ListView.builder(
                    itemCount: limitedMovies.length,
                    itemBuilder: (context, index) {
                      final movie = limitedMovies[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailsPage(movieId: movie.id),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: movie.posterPath != null
                                  ? Image.network(
                                      'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                      width: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 50,
                                      color: Colors.grey,
                                      child: Icon(Icons.image_not_supported),
                                    ),
                            ),
                            title: Text(
                              movie.title,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text('Start typing to search for movies.'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build the empty state when no results are found
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.movie, size: 80, color: Colors.grey),
        SizedBox(height: 10),
        Text(
          'No results found.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ],
    );
  }
}
