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
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(widget.email);
      final wishlistSnapshot = await userDocRef.collection('wishlist').get();

      final Map<String, Map<String, dynamic>> bookMap = {};

      for (var doc in wishlistSnapshot.docs) {
        final bookName = doc['name'];
        final bookAuthor = doc['author'];
        final bookPhoto = doc['photoUrl']; // Assume photoUrl field exists

        if (bookMap.containsKey(bookName)) {
          bookMap[bookName]!['quantity'] += 1;
        } else {
          bookMap[bookName] = {
            'name': bookName,
            'author': bookAuthor,
            'photoUrl': bookPhoto,
            'quantity': 1,
          };
        }
      }

      setState(() {
        uniqueWishlist = bookMap.values.toList();
      });
    } catch (error) {
      print('Error fetching wishlist: $error');
    }
  }

  Future<void> removeFromWishlist(String bookName) async {
    try {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(widget.email);
      final wishlistDocRef = userDocRef.collection('wishlist').where('name', isEqualTo: bookName);
      
      // Get all documents that match the book name
      final querySnapshot = await wishlistDocRef.get();
      
      // Loop through all documents and delete them
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      // Update the user's wishlist field
      await _updateUserWishlistField(bookName);

      // Update the UI by removing the book from the list
      setState(() {
        uniqueWishlist.removeWhere((book) => book['name'] == bookName);
      });
    } catch (error) {
      print('Error removing book from wishlist: $error');
    }
  }

  Future<void> _updateUserWishlistField(String bookName) async {
    try {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(widget.email);
      final userDoc = await userDocRef.get();
      final List<dynamic> currentWishlist = userDoc.get('wishlist');

      // Remove the book from the current wishlist
      currentWishlist.removeWhere((book) => book == bookName);

      // Update the wishlist field in the user's document
      await userDocRef.update({'wishlist': currentWishlist});
    } catch (error) {
      print('Error updating user wishlist field: $error');
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
          ? Center(
              child: uniqueWishlist.isEmpty
                  ? const Text('Your wishlist is currently empty.')
                  : const CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: uniqueWishlist.length,
              itemBuilder: (context, index) {
                final book = uniqueWishlist[index];
                return ListTile(
                  leading: Image.network(
                    book['photoUrl'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.broken_image);
                    },
                  ),
                  title: Text(book['name']),
                  subtitle: Text('Author: ${book['author']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.favorite, color: Colors.red), // Heart icon
                    onPressed: () {
                      removeFromWishlist(book['name']);
                    },
                  ),
                );
              },
            ),
    );
  }
}