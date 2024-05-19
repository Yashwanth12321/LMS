import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lms/pages/admin_home.dart';
import 'package:lms/pages/home_page.dart';
import 'package:lms/utils/animations.dart'; // Assuming this is where ShowUpAnimation is defined
import '../utils/text_utils.dart'; // Assuming this is where TextUtil is defined

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> signInWithEmailAndPassword() async {
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

      if (_email.text == "admin@gmail.com") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(email: _email.text)),
        );
      }
    } on FirebaseAuthException {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Invalid Username or Password. Please try again.",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/images/bg1.jpeg', // Fixed to bg2.jpeg
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),
          // Blurred and semi-transparent overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          // Login form
          Center(
            child: Container(
              height: 400,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(15),
                color: Colors.white.withOpacity(0.5), // Changed color to white with opacity
              ),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Center(
                        child: TextUtil(
                          text: "Login",
                          weight: true,
                          size: 30,
                          color: Colors.black, // Text color changed to black
                        ),
                      ),
                      const Spacer(),
                      TextUtil(
                        text: "Email",
                        color: Colors.black, // Text color changed to black
                      ),
                      Container(
                        height: 35,
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.black)),
                        ),
                        child: TextFormField(
                          controller: _email,
                          cursorColor: Colors.black,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            suffixIcon: Icon(
                              Icons.mail,
                              color: Colors.black,
                            ),
                            fillColor: Colors.black,
                            border: InputBorder.none,
                          ),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Email is empty';
                            }
                            return null;
                          },
                        ),
                      ),
                      const Spacer(),
                      TextUtil(
                        text: "Password",
                        color: Colors.black, // Text color changed to black
                      ),
                      Container(
                        height: 35,
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.black)),
                        ),
                        child: TextFormField(
                          controller: _password,
                          cursorColor: Colors.black,
                          obscureText: !_isPasswordVisible,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              child: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.black,
                              ),
                            ),
                            fillColor: Colors.black,
                            border: InputBorder.none,
                          ),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Password is empty';
                            }
                            return null;
                          },
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            signInWithEmailAndPassword();
                          }
                        },
                        child: Container(
                          height: 40,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : TextUtil(
                                  text: "Login",
                                  color: Colors.white,
                                ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}