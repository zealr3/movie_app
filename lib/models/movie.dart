class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String backdropPath;  // Add this line for backdropPath
  final String overview;
  final String releaseDate;
  final double rating; // Add this line for the movie rating

  // Constructor for initializing movie object
  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.backdropPath,  // Add this line
    required this.overview,
    required this.releaseDate,
    required this.rating, // Add this line
  });

  // Factory method to create a Movie object from JSON
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'] ?? 'Unknown Title',  // Fallback in case the title is null
      posterPath: json['poster_path'] != null
          ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}'  // Full URL for poster
          : 'https://via.placeholder.com/500',  // Fallback image URL for poster
      backdropPath: json['backdrop_path'] != null
          ? 'https://image.tmdb.org/t/p/w500${json['backdrop_path']}'  // Full URL for backdrop
          : 'https://via.placeholder.com/500',  // Fallback image URL for backdrop
      overview: json['overview'] ?? 'No overview available',  // Fallback for overview
      releaseDate: json['release_date'] ?? 'Unknown',  // Fallback in case release date is null
      rating: (json['vote_average'] ?? 0.0).toDouble(), // Assuming 'vote_average' is the key for rating
    );
  }
}
