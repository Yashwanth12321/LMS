import 'package:flutter/material.dart';
import 'package:lms/pages/login_page.dart';
import 'package:lms/pages/signup_page.dart';

class AuthPageUser extends StatelessWidget {
  const AuthPageUser({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EzBorrow', style: TextStyle(
          fontWeight: FontWeight.bold
        ),),
        backgroundColor: Colors.blue[600],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20.0),
              const Text(
                'Welcome to the Library App!',
                style: TextStyle(
                  fontSize: 24.0, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.black
                ),
              ),
              const SizedBox(height: 120.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
    );
  }
}
