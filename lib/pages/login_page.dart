import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lms/pages/admin_home.dart'; 
import 'package:lms/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  signInWithEmailAndPassword() async {
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );
      setState(() {
        isLoading = false;
      });

      // Check if the entered email is admin's email
      if (_email.text == "admin@gmail.com") {
        // Navigate to AdminHomePage if the email is admin's email
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomePage()),
        );
      } else {
        // Navigate to regular HomePage for non-admin users
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException {
      setState(() {
        isLoading = false;
      });
      String errorMessage = "Invalid Username or Password. Please try again.";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } catch (e) {
      // Handle other non-FirebaseAuth exceptions (optional)
      // print("Error: $e"); // Log more detailed error for debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _email,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Email is empty';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Password is empty';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: "Password"),
                ),
                const SizedBox(height: 20.0),
                const Text("\n"),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      signInWithEmailAndPassword();
                    }
                  },
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : const Text("Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
