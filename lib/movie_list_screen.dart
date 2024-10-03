import 'package:flutter/material.dart';
import 'package:movie_app/services/movie_service.dart';
import 'package:movie_app/models/movie.dart';
import 'moviedetails.dart';

class MovieListScreen extends StatefulWidget {
  final String category;

  MovieListScreen({required this.category});

  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  List<Movie> movies = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMoreMovies = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchMovies();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !isLoading) {
      _fetchMovies(); // Fetch more movies when we reach the bottom of the list
    }
  }

  Future<void> _fetchMovies() async {
    if (!hasMoreMovies) return;

    setState(() {
      isLoading = true;
    });

    List<Movie> fetchedMovies;
    try {
      switch (widget.category) {
        case 'Popular Movies':
          fetchedMovies = await MovieService().fetchPopularMovies(page: currentPage);
          break;
        case 'Top Rated':
          fetchedMovies = await MovieService().fetchTopRatedMovies(page: currentPage);
          break;
        case 'NowPlaying Movies':
          fetchedMovies = await MovieService().fetchNowPlayingMovies(page: currentPage);
          break;
        default:
          throw Exception('Unknown category');
      }

      setState(() {
        if (fetchedMovies.isEmpty) {
          hasMoreMovies = false;
        } else {
          movies.addAll(fetchedMovies);
          currentPage++;
        }
      });
    } catch (e) {
      print("Error fetching movies: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom Header with Back Arrow (Removed "View More" button)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.grey.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 10),
                Text(
                  widget.category,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: movies.isEmpty && isLoading
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: movies.length + 1,
                    itemBuilder: (context, index) {
                      if (index == movies.length) {
                        return isLoading
                            ? Center(child: CircularProgressIndicator())
                            : Container(); // Return an empty container at the bottom
                      }

                      final movie = movies[index];
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                  child: Image.network(
                                    'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.error)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  movie.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
