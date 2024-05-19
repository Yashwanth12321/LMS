import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReturnPage extends StatefulWidget {
  @override
  _ReturnPageState createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> {
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
      handleReturn(barcodeScanRes);
    }
  }

  Future<void> handleReturn(String bookId) async {
    try {
      final usersRef = FirebaseFirestore.instance.collection('users');
      final bookRef = FirebaseFirestore.instance.collection('books');
      final booksSnapshots = await bookRef.get();

      String borrowedUser = '';
      for (QueryDocumentSnapshot bookDoc in booksSnapshots.docs) {
        if (bookDoc.id == bookId) {
          Map<String, dynamic> bookData = bookDoc.data() as Map<String, dynamic>; // Ensure data is cast to the correct type
          if (bookData['isBorrowed'] == 0) {
            // If book is already returned, show a Snackbar and break
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Book is not issued yet.'),
              ),
            );
            break;
          } else {
            // If book is borrowed, update the attributes and show a Snackbar
            borrowedUser = bookData['taken_by'];
            await bookDoc.reference.update({'isBorrowed': 0, 'taken_by': ''});
            print('Attribute updated to 0 for book $bookId');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Book has been returned by $borrowedUser'),
              ),
            );

            // Call method to handle user collections
            await handleUserCollections(usersRef, borrowedUser, bookId);
            break;
          }
        }
      }
    } catch (e) {
      print('Error returning book: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while processing the return: $e'),
        ),
      );
    }
  }

  Future<void> handleUserCollections(CollectionReference usersRef, String borrowedUser, String bookId) async {
    final userDocRef = usersRef.doc(borrowedUser);
    final borrowedBooksCollection = userDocRef.collection('borrowed_books');
    final borrowedBooksSnapshot = await borrowedBooksCollection.get();
    int borrowedBooksSize = borrowedBooksSnapshot.size;
    print('Size of borrowed books collection: $borrowedBooksSize');

    for (QueryDocumentSnapshot borrowedBookDoc in borrowedBooksSnapshot.docs) {
      final borrowedBookId = borrowedBookDoc.id;
      print('- Book ID: $borrowedBookId');

      if (borrowedBookId == bookId) {
        print('Book $bookId found in user\'s borrowed books');
        // Step 3: Delete the document with docId same as bookId from borrowed_books
        await borrowedBookDoc.reference.delete();
        print('  Document with docId $bookId deleted from user ${userDocRef.id}\'s borrowed books');

        break; // Break out of the loop once the document is added to returned_books and deleted from borrowed_books
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Return Book'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: scanCode,
          child: Text('Scan Book Barcode'),
        ),
      ),
    );
  }
}
