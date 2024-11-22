import 'package:flutter/material.dart';
import 'package:movie_app/services/watchlist_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_app/models/movie.dart'; // Assuming this is defined

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userEmail;
  String? userName;
  List<Movie>? watchlist;
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _fetchWatchlist();
  }

  // Fetch user info from SharedPreferences
  Future<void> _getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        userEmail = prefs.getString('email');
        userName = prefs.getString('name');
      });
    } catch (e) {
      print('Error retrieving user info: $e');
      setState(() {
        isError = true;
      });
    }
  }

  // Fetch watchlist from your service
Future<void> _fetchWatchlist() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final watchlistService = WatchlistService(token);

    final fetchedWatchlist = await watchlistService.getWatchlist();
    setState(() {
      watchlist = fetchedWatchlist;
    });
  } catch (e) {
    print('Error fetching watchlist: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load watchlist')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show a loading indicator while fetching data
          : isError
              ? Center(child: Text('Error loading profile data', style: TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // User Info Section
                        Text(
                          userName ?? 'Name not available',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          userEmail ?? 'Email not available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 30),

                        // Watchlist Section
                        Text(
                          'Watchlist',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        watchlist == null
                            ? Center(child: CircularProgressIndicator()) // Loading state for watchlist
                            : watchlist!.isEmpty
                                ? Text(
                                    'Your watchlist is empty.',
                                    style: TextStyle(color: Colors.white70),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: watchlist!.length,
                                    itemBuilder: (context, index) {
                                      final movie = watchlist![index];
                                      return ListTile(
                                        title: Text(
                                          movie.title,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        subtitle: Text(
                                          movie.releaseDate,
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                        trailing: Icon(
                                          Icons.movie,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
