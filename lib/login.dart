import 'package:flutter/material.dart';
import 'package:movie_app/services/api_service.dart'; // Import the ApiService class
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_app/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(); // Controller for the name
  bool _isLoading = false;
  String? _errorMessage;

  // Function to handle login
  Future<void> _login() async {
  setState(() {
    _errorMessage = null; // Clear previous error
  });

  // Validate if fields are not empty
  if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
    setState(() {
      _errorMessage = 'Please fill in both fields.';
    });
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final success = await ApiService.loginUser(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
    );

    if (mounted) {
      if (success) {
        // Save user information using SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('email', _emailController.text.trim());
        
        // Only save the name after signup, or retrieve it from SharedPreferences
        // If name was not saved earlier, you can try to fetch it from an API if available
        String userName = _nameController.text.trim(); // Use the name entered in sign-up (if any)
        if (userName.isEmpty) {
          userName = prefs.getString('name') ?? ''; // Fallback to saved name
        }
        prefs.setString('name', userName); // Save the username

        // Navigate to home page after login success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        setState(() {
          _errorMessage = 'Login failed. Please check your credentials.';
        });
      }
      setState(() {
        _isLoading = false;
      });
    }
  } catch (error) {
    setState(() {
      _isLoading = false;
      _errorMessage = 'An error occurred. Please try again later.';
    });
  }
}

  // Retrieve the username from SharedPreferences on page load
  Future<void> _loadUserInfo() async {
  final prefs = await SharedPreferences.getInstance();
  String? savedUsername = prefs.getString('name');
  if (savedUsername != null && savedUsername.isNotEmpty) {
    _nameController.text = savedUsername; // Set the username in the controller
  }
}

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // Load the saved user information when the page is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log In'),
        backgroundColor: Color(0xFF7A9999),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock,
                    isPassword: true,
                  ),
                  SizedBox(height: 20),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 40,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Log In',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE2C1A4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/signup');
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(color: Color(0xFFE2C1A4)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      backgroundColor: Color(0xFF7A9999),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFFE2C1A4)),
        ),
      ),
      style: TextStyle(color: Colors.white),
      obscureText: isPassword,
      keyboardType: keyboardType,
      enabled: !_isLoading,
    );
  }
}