import 'package:flutter/material.dart';
import 'package:movie_app/services/watchlist_service.dart';
//import 'watchlist_service.dart';

class WatchlistScreen extends StatefulWidget {
  final String token;

  WatchlistScreen(this.token);

  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  late WatchlistService watchlistService;
  late Future<List<dynamic>> watchlist;

  @override
  void initState() {
    super.initState();
    watchlistService = WatchlistService(widget.token);
    watchlist = watchlistService.getWatchlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Watchlist')),
      body: FutureBuilder<List<dynamic>>(
        future: watchlist,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No movies in watchlist.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final movie = snapshot.data![index];
                return ListTile(
                  title: Text('Movie ID: ${movie['movie_id']}'),
                  subtitle: Text('Added: ${movie['added_at']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await watchlistService.removeFromWatchlist(movie['movie_id']);
                      setState(() {
                        watchlist = watchlistService.getWatchlist();
                      });
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
