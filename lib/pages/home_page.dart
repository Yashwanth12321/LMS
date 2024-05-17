import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms/User_Pages/user_menu.dart';

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
      addBookToUser(barcodeScanRes);
    }
  }

  Future<void> addBookToUser(String bookId) async {
    try {
      // Reference to Firestore collections
      final booksRef = FirebaseFirestore.instance.collection('books');
      final usersRef = FirebaseFirestore.instance.collection('users');

      // Fetch book details using bookId
      final DocumentSnapshot bookDoc = await booksRef.doc(bookId).get();

      if (bookDoc.exists) {
        // Get book data
        final bookData = bookDoc.data() as Map<String, dynamic>;

        // Get user's document reference
        final userDocRef = usersRef.doc(widget.email);

        // Add the book to user's collection
        await userDocRef.collection('borrowed_books').doc(bookId).set({
          'name': bookData['name'],
          'photoUrl': bookData['photoUrl'],
          'borrowedDate': Timestamp.now(),
        });

        print('Book added to user successfully!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Book "${bookData['name']}" added to your borrowed list!')),
        );
      } else {
        print('Book not found!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Book not found!')),
        );
      }
    } catch (error) {
      print('Error adding book to user: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add book to your borrowed list.')),
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
