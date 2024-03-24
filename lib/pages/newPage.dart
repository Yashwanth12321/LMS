import 'package:flutter/material.dart';

class NewPage extends StatefulWidget {
  const NewPage({super.key});

  @override
  State<NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('New Page'), // Add a title to the app bar
      ),
      body: const Center(
        child: Text(
          'This is the content of the New Page!',
          style: TextStyle(fontSize: 20), // Adjust font size as desired
        ),
      ),
    );
  }
}
