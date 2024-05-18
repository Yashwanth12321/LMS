import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms/User_Pages/user_menu.dart';


class WishList extends StatefulWidget {
  final String email;

  const WishList({required this.email, Key? key}) : super(key: key);

  @override
  State<WishList> createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  List<Map<String, dynamic>> uniqueWishlist = [];

  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    try {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(widget.email);
      final wishlistSnapshot = await userDocRef.collection('wishlist').get();

      final List<Map<String, dynamic>> wishlist = wishlistSnapshot.docs.map((doc) {
        return {
          'name': doc['name'],
          'author': doc['author'],
        };
      }).toList();

      final Set<Map<String, dynamic>> uniqueWishlistSet = {};
      for (var book in wishlist) {
        uniqueWishlistSet.add(book);
      }

      setState(() {
        uniqueWishlist = uniqueWishlistSet.toList();
      });
    } catch (error) {
      print('Error fetching wishlist: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Wishlist Page",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.orange[900],
      ),
      drawer: UserMenu(email: widget.email),
      body: uniqueWishlist.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: uniqueWishlist.length,
              itemBuilder: (context, index) {
                final book = uniqueWishlist[index];
                return ListTile(
                  title: Text(book['name']),
                  subtitle: Text(book['author']),
                );
              },
            ),
    );
  }
}
