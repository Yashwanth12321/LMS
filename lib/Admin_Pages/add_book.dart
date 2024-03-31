import 'package:flutter/material.dart';
import 'package:lms/Admin_Pages/admin_menu.dart';

class AddBook extends StatefulWidget {
  const AddBook({super.key});

  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Book Admin"),
      ),
      drawer: const AdminMenu(),
    );
  }
}