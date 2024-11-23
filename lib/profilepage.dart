import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('email') ?? 'a@gmail.com';
      // Extracting the part before "@" from the email to set as username
      userName = userEmail?.split('@')[0] ?? 'Unknown User';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored preferences
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        backgroundColor: const Color(0xFF7A9999),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[800],
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Name: $userName', // Displaying the username extracted from email
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Email: $userEmail', // Displaying the email
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Text(
              'Watchlist',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 0, // Removed the demo watchlist movies
                itemBuilder: (context, index) {
                  return const SizedBox(); // No list items to display
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _logout,
                child: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE2C1A4),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white, // Changed background color to white
    );
  }
}
