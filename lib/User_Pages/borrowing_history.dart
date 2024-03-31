import 'package:flutter/material.dart';
import 'package:lms/User_Pages/user_menu.dart';

class BorrowHistory extends StatefulWidget {
  const BorrowHistory({super.key});

  @override
  State<BorrowHistory> createState() => _BorrowHistoryState();
}

class _BorrowHistoryState extends State<BorrowHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Borrow History"),
        backgroundColor: Colors.blue[600],
      ),
      drawer: const UserMenu(),
      body: Container(
        child: const Text("List of Books you have borrowed"),
      ),
    );
  }
}