import 'package:flutter/material.dart';
import 'package:lms/pages/login_page.dart';
import 'package:lms/pages/signUp.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'), // Set the app bar title
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          children: <Widget>[
            const Text(
              'Welcome to the Library App!',
              style: TextStyle(fontSize: 24.0), // Set title text size
            ),
            const SizedBox(height: 20.0), // Add some spacing
            ElevatedButton(
              onPressed: () {
                // Handle Login button press
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 10.0), // Add a little gap between buttons
            ElevatedButton(
              onPressed: () {
                // Handle Sign Up button press
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}


