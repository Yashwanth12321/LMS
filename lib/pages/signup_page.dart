import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lms/pages/home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  signUpWithEmailAndPassword() async {
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      setState(() {
        isLoading = false;
      });


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage(email: '',)),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      String errorMessage = "Failed to sign up: ${e.message}";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } catch (e) {
      print("Error: $e"); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
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
                const Text(
                  'Create an Account\n',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _emailController,
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
                  controller: _passwordController,
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
                      signUpWithEmailAndPassword();
                    }
                  },
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : const Text("Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
