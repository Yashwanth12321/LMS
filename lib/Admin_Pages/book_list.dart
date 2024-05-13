import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String name;
  final String photoUrl;
  final int quantity;

  Book({
    required this.name,
    required this.photoUrl,
    required this.quantity,
  });

  // Convert Book object to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'photoUrl': photoUrl,
      'quantity': quantity,
    };
  }
}

class BookList extends StatefulWidget {
  const BookList({Key? key}) : super(key: key);

  @override
  State createState() => _BookListState();
}

class _BookListState extends State
{
  List<dynamic> books = [];
  int startIndex = 0;
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  final CollectionReference _booksRef =
      FirebaseFirestore.instance.collection('books');

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    fetchBooks();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!isLoading) {
        fetchBooks();
      }
    }
  }

  Future<void> fetchBooks() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(
          'https://www.googleapis.com/books/v1/volumes?q=flutter&startIndex=$startIndex&maxResults=20'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('items')) {
          setState(() {
            books.addAll(data['items']);
            startIndex += 20;
            isLoading = false;
          });
        }
      } else {
        print('Failed to fetch books: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error fetching books: $error');
    }
  }

  Future<void> _showQuantityDialog(String title, String photoUrl) async {
    int? quantity;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Quantity for "$title"'),
        content: TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) {
            quantity = int.tryParse(value);
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (quantity != null && quantity! > 0) {
                _BookListToDatabase(title, photoUrl, quantity!);
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _BookListToDatabase(
    String title, String photoUrl, int quantity) async {
    try {
      // Check if the book already exists in the collection
      final QuerySnapshot existingBooks = await _booksRef
          .where('name', isEqualTo: title)
          .limit(1)
          .get();

      if (existingBooks.docs.isNotEmpty) {
        // Update the quantity if the book exists
        final DocumentSnapshot doc = existingBooks.docs.first;
        final int currentQuantity = doc['quantity'] ?? 0;
        await doc.reference.update({'quantity': currentQuantity + quantity});
        print('Book quantity updated successfully!');
      } else {
        // Add the book if it doesn't exist
        await _booksRef.add({
          'name': title,
          'photoUrl': photoUrl,
          'quantity': quantity,
        });
        print('Book added successfully!');
      }
    } catch (error) {
      print('Error updating/adding book: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Book Admin"),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: books.length + 1,
        itemBuilder: (context, index) {
          if (index == books.length) {
            return _buildLoadingIndicator();
          } else {
            final book = books[index];
            final title = book['volumeInfo']['title'];
            final author = book['volumeInfo']['authors']?.join(', ') ?? 'Unknown';
            final photoUrl = book.containsKey('volumeInfo') &&
                    book['volumeInfo'].containsKey('imageLinks')
                ? book['volumeInfo']['imageLinks']['thumbnail']
                : '';

            return ListTile(
              title: Text(title),
              subtitle: Text(author),
              leading: _buildBookThumbnail(photoUrl),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  _showQuantityDialog(title, photoUrl);
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildBookThumbnail(String? photoUrl) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Image.network(
        photoUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    } else {
      return const SizedBox(
        width: 50,
        height: 50,
        child: Icon(Icons.book),
      );
    }
  }
}