import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddBook extends StatefulWidget {
  const AddBook({Key? key}) : super(key: key);

  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final _formKey = GlobalKey<FormState>();
  String? _bookName;
  String? _author;
  int? _quantity;
  String? _bookUrl = ''; // Default photo URL
  List<String>? _genres = []; // List to store genres
  int? _isBorrowed;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // If book URL is not provided, save a default photo URL
      if (_bookUrl == null || _bookUrl!.isEmpty) {
        _bookUrl = 'https://picsum.photos/200/300.jpg';
      }
      try {
        // Check if a book with the same name already exists
        final querySnapshot = await FirebaseFirestore.instance
            .collection('books')
            .where('name', isEqualTo: _bookName)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          // Book with the same name already exists, show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A book with the same name already exists!'),
            ),
          );
          return; // Exit the method
        }

        final List<Map<String, dynamic>> booksToAdd = List.generate(
          _quantity!,
          (index) => {
            'name': _bookName,
            'author': _author,
            'quantity': 1, // Each book starts with a quantity of 1
            'photoUrl': _bookUrl,
            'genres': _genres, // Add genres to book data
            'isBorrowed': 0, // New book is not borrowed by default
          },
        );

        // Add book data to Firestore for each item in the booksToAdd list
        final batch = FirebaseFirestore.instance.batch();
        for (var bookData in booksToAdd) {
          batch.set(
            FirebaseFirestore.instance.collection('books').doc(),
            bookData,
          );
        }
        await batch.commit();

        // Clear form fields after submission
        _formKey.currentState!.reset();
        // Show a confirmation snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Books added successfully!!!'),
          ),
        );
      } catch (error) {
        print('Error adding book: $error');
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add books. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Book',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 94, 0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Enter Book Details",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Book Name',
                    contentPadding: EdgeInsets.all(15.0),
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the book name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _bookName = value;
                  },
                ),
              ),
              const SizedBox(height: 25),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Author',
                    contentPadding: EdgeInsets.all(15.0),
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the author name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _author = value;
                  },
                ),
              ),
              const SizedBox(height: 25),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    contentPadding: EdgeInsets.all(15.0),
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the quantity';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _quantity = int.tryParse(value!);
                  },
                ),
              ),
              const SizedBox(height: 25),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Book Pic URL',
                    contentPadding: EdgeInsets.all(15.0),
                    border: InputBorder.none,
                  ),
                  onSaved: (value) {
                    _bookUrl = value;
                  },
                ),
              ),
              const SizedBox(height: 25),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Genres (comma-separated)',
                    contentPadding: EdgeInsets.all(15.0),
                    border: InputBorder.none,
                  ),
                  onSaved: (value) {
                    _genres = value!.split(',').map((genre) => genre.trim()).toList();
                  },
                ),
              ),
              const SizedBox(height: 50),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}