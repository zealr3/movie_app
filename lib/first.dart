import 'package:flutter/material.dart';

class First extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<First> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1), // Duration of the animation
      vsync: this,
    );

    // Animation to reveal the logo
    _animation = Tween<double>(begin: 0.0, end: 150.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF7A9999), // Background color matching your image
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Logo part with circular reveal effect
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: ClipOval(
                    child: Container(
                      width: _animation.value,
                      height: _animation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Removed border property to eliminate the white line
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo1.png', // Your logo image path
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Text(
              'Hello, Welcome!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40),
            // Login button
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login'); // Navigate to LoginPage
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE2C1A4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Sign up button
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup'); // Navigate to SignUpPage
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE2C1A4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
