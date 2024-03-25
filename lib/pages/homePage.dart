import 'package:flutter/material.dart';
import 'package:lms/pages/Login.dart';
import 'package:lms/pages/SignUp.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'), // Set the app bar title
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center content vertically
          children: <Widget>[
            const Text(
              'Welcome to the Library App!',
              style: TextStyle(fontSize: 24.0), // Set title text size
            ),
            const SizedBox(height: 40.0), // Add more spacing
            ElevatedButton(
              onPressed: () {
                // Handle Login button press
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Login'),
            ),
            const SizedBox(height: 20.0), // Add a little gap between buttons
            ElevatedButton(
              onPressed: () {
                // Handle Sign Up button press
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
