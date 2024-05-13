import 'dart:io';
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
  int? _quantity;
  String? _bookUrl;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // If book URL is not provided, save an empty string
      if (_bookUrl == null || _bookUrl!.isEmpty) {
        _bookUrl = ''; // Save an empty string as the book URL
      }
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
      // Add book data to Firestore
      await FirebaseFirestore.instance.collection('books').add({
        'name': _bookName,
        'quantity': _quantity,
        'bookUrl': _bookUrl,
      });
      // Clear form fields after submission
      _formKey.currentState!.reset();
      // Show a confirmation snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book added successfully!!!'),
        ),
      );
    }
  }

  Future<String?> _showUrlInputDialog(BuildContext context) async {
    String? enteredUrl;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Book URL'),
        content: TextField(
          onChanged: (value) {
            enteredUrl = value;
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, null);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, enteredUrl);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    return enteredUrl;
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
                    labelText: 'Book Pic URL',
                    contentPadding: EdgeInsets.all(15.0),
                    border: InputBorder.none,
                  ),
                  onSaved: (value) {
                    _bookUrl = value;
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