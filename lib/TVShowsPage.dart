import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/TvSHowDetails.dart';
import 'dart:convert';

//import 'tv_show_details_page.dart'; // Import the details page

class TVShowsPage extends StatelessWidget {
  final String apiKey = '565b880331fb02dfe1fc15149be91f15';

  Future<List<dynamic>> fetchPopularTVShows() async {
    final response = await http.get(Uri.parse('https://api.themoviedb.org/3/tv/popular?api_key=$apiKey&language=en-US'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['results'] ?? [];
    } else {
      throw Exception('Failed to load popular TV shows');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Popular TV Shows",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchPopularTVShows(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No TV Shows found.'));
          } else {
            final tvShows = snapshot.data!;

            return GridView.builder(
              padding: EdgeInsets.all(10.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.7,
              ),
              itemCount: tvShows.length,
              itemBuilder: (context, index) {
                String imageUrl = tvShows[index]['poster_path'] != null
                    ? 'https://image.tmdb.org/t/p/w500${tvShows[index]['poster_path']}'
                    : 'https://via.placeholder.com/500x750?text=No+Image';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TVShowDetailsPage(tvShow: tvShows[index]),
                      ),
                    );
                  },
                  child:Card(
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15.0),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          height: 180,
          width: double.infinity,
        ),
      ),
      Expanded( // Ensures the text and layout stay within bounds
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            tvShows[index]['name'] ?? 'No Name',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            overflow: TextOverflow.ellipsis, // Ensures text doesn't overflow
            maxLines: 2, // Limits the text to 2 lines
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 8.0), // Add bottom padding
        child: Text(
          'Rating: ${tvShows[index]['vote_average']?.toString() ?? 'N/A'}',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    ],
  ),
)


                );
              },
            );
          }
        },
      ),
    );
  }
}
