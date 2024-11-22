import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TVShowDetailsPage extends StatelessWidget {
  final dynamic tvShow; // Pass the TV show data to this page

  TVShowDetailsPage({required this.tvShow});

  @override
  Widget build(BuildContext context) {
    String imageUrl = tvShow['poster_path'] != null
        ? 'https://image.tmdb.org/t/p/w500${tvShow['poster_path']}'
        : 'https://via.placeholder.com/500x750?text=No+Image';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tvShow['name'] ?? 'Details',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white), // Set arrow icon color to white
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display poster image
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 300,
            ),
            SizedBox(height: 16.0),
            // Display title
            Text(
              tvShow['name'] ?? 'No Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            // Display release date
            Text(
              'First Air Date: ${tvShow['first_air_date'] ?? 'N/A'}',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8.0),
            // Display rating
            Row(
              children: [
                Icon(Icons.star, color: Colors.yellow, size: 20),
                SizedBox(width: 5),
                Text(
                  tvShow['vote_average']?.toString() ?? 'N/A',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            // Display genres if available
            if (tvShow['genre_ids'] != null && tvShow['genre_ids'].isNotEmpty)
              Wrap(
                spacing: 8.0,
                children: (tvShow['genre_ids'] as List<dynamic>)
                    .map((genreId) => Chip(
                          label: Text(genreId.toString()), // Replace with genre names if available
                          backgroundColor: Colors.grey[200],
                        ))
                    .toList(),
              ),
            SizedBox(height: 16.0),
            // Display overview
            Text(
              'Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              tvShow['overview'] ?? 'No description available.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            // Display a "More Information" button (optional)
            ElevatedButton(
              onPressed: () async {
                final url = tvShow['homepage'] ?? 'https://www.themoviedb.org/tv/${tvShow['id']}';
                final uri = Uri.parse(url);

                try {
                  // Check if the URL can be launched and launch it
                  if (await canLaunch(uri.toString())) {
                    await launch(uri.toString());
                  } else {
                    // Show SnackBar if URL can't be launched
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not launch $url')),
                    );
                  }
                } catch (e) {
                  // Handle any other errors
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: Text('More Information'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Button background color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
