import 'package:flutter/material.dart';
import 'package:lms/User_Pages/user_menu.dart';

class WishList extends StatefulWidget {
  const WishList({super.key});

  @override
  State<WishList> createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wishlist Page", 
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.orange[900],
      ),
      drawer: const UserMenu(),
    );
  }
}