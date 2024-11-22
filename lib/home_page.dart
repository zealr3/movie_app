import 'package:flutter/material.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/movie_list_screen.dart';
import 'package:movie_app/moviedetails.dart';
import 'package:movie_app/searchPage.dart';
import 'package:movie_app/profilepage.dart';
import 'package:movie_app/services/movie_service.dart';
import 'package:movie_app/tvshowspage.dart';  // Added TV Shows page import

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Movie>> popularMovies;
  late Future<List<Movie>> topRatedMovies;
  late Future<List<Movie>> newMovies;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    popularMovies = MovieService().fetchPopularMovies();
    topRatedMovies = MovieService().fetchTopRatedMovies();
    newMovies = MovieService().fetchNewMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _currentIndex == 0
            ? _buildHomeContent()
            : _currentIndex == 1
                ? TVShowsPage()  // Display TV shows page
                : ProfilePage(),  // Display profile page
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tv),  // Icon for TV Shows
            label: 'TV Shows',     // Label for TV Shows
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchPage()),
                );
              },
              backgroundColor: Colors.black,
              child: Icon(Icons.search, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildCategorySection(
              title: 'Popular Movies',
              moviesFuture: popularMovies,
              onViewMore: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieListScreen(category: 'Popular'),
                  ),
                );
              },
            ),
            _buildCategorySection(
              title: 'Top Rated Movies',
              moviesFuture: topRatedMovies,
              onViewMore: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieListScreen(category: 'Top Rated'),
                  ),
                );
              },
            ),
            _buildCategorySection(
              title: 'New Movies',
              moviesFuture: newMovies,
              onViewMore: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieListScreen(category: 'New Movies'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_movies, color: Colors.white),
          SizedBox(width: 10),
          Text(
            'Movie App',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection({
    required String title,
    required Future<List<Movie>> moviesFuture,
    required VoidCallback onViewMore,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryHeader(title, onViewMore),
        _buildMovieList(moviesFuture),
      ],
    );
  }

  Widget _buildCategoryHeader(String title, VoidCallback onViewMore) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          TextButton(
            onPressed: onViewMore,
            child: Text(
              'View More',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[800],
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieList(Future<List<Movie>> moviesFuture) {
    return FutureBuilder<List<Movie>>(
      future: moviesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No movies found.'));
        }

        return SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final movie = snapshot.data![index];
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
                  child: Container(
                    width: 120,
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          movie.title,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
