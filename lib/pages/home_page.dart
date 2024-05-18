import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms/User_Pages/user_menu.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomePage extends StatefulWidget {
  final String email;

  const HomePage({required this.email, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _scanResult = "";

  Future<void> scanCode() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to scan';
    }

    if (!mounted) return;

    setState(() {
      _scanResult = barcodeScanRes;
    });

    if (barcodeScanRes != '-1') {
      showConfirmationDialog(barcodeScanRes);
    }
  }

  Future<void> showConfirmationDialog(String bookId) async {
    try {
      final DocumentSnapshot bookDoc =
          await FirebaseFirestore.instance.collection('books').doc(bookId).get();

      if (bookDoc.exists) {
        final bookData = bookDoc.data() as Map<String, dynamic>;

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Borrow'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Book Name: ${bookData['name']}'),
                  Text('Author: ${bookData['author']}'),
                  Text('Quantity: ${bookData['quantity']}'),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    await addBookToUser(bookId, bookData);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Borrow'),
                ),
                TextButton(
                  onPressed: () async {
                    await addBookToWishlist(bookId, bookData);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add to Wishlist'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book not found!')),
        );
      }
    } catch (error) {
      print('Error fetching book details: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch book details.')),
      );
    }
  }

  Future<void> addBookToUser(String bookId, Map<String, dynamic> bookData) async {
    try {
      final usersRef = FirebaseFirestore.instance.collection('users');
      final userDocRef = usersRef.doc(widget.email);

      await userDocRef.collection('borrowed_books').doc(bookId).set({
        'name': bookData['name'],
        'photoUrl': bookData['photoUrl'],
        'borrowedDate': Timestamp.now(),
        'deadlineDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 45))),
      });

      // Update isBorrowed field to 1 in the books collection
      await FirebaseFirestore.instance.collection('books').doc(bookId).update({
        'isBorrowed': 1,
      });

      print('Book added to user successfully!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book "${bookData['name']}" added to your borrowed list!')),
      );
    } catch (error) {
      print('Error adding book to user: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add book to your borrowed list.')),
      );
    }
  }

  Future<void> addBookToWishlist(String bookId, Map<String, dynamic> bookData) async {
  try {
    final usersRef = FirebaseFirestore.instance.collection('users');
    final userDocRef = usersRef.doc(widget.email);

    await userDocRef.collection('wishlist').doc(bookId).set({
      'name': bookData['name'],
      'author': bookData['author'],
      'photoUrl': bookData['photoUrl'], // Adding photo URL to the wishlist
      'addedDate': Timestamp.now(),
    });

    print('Book added to wishlist successfully!');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Book "${bookData['name']}" added to your wishlist!')),
    );
  } catch (error) {
    print('Error adding book to wishlist: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to add book to your wishlist.')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: const Text('EzBorrow'),
        actions: [
          IconButton(
            onPressed: scanCode,
            icon: const Icon(Icons.qr_code_scanner, size: 24.0, color: Colors.black),
          ),
        ],
      ),
      drawer: UserMenu(email: widget.email),
      body: Center(
        child: Container(
          child: const Text(
            "Hello User",
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
