import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Book {
  final String name;
  final String photoUrl;
  final int quantity;
  final int isBorrowed; // 0 for not borrowed, 1 for borrowed
  final String author;
  final List<String> genres;

  Book({
    required this.name,
    required this.photoUrl,
    required this.quantity,
    this.isBorrowed = 0, // Default to not borrowed (0)
    required this.author,
    required this.genres,
  });

  // Convert Book object to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'photoUrl': photoUrl,
      'quantity': quantity,
      'isBorrowed': isBorrowed,
      'author': author,
      'genres': genres,
    };
  }
}

class BookList extends StatefulWidget {
  const BookList({Key? key}) : super(key: key);

  @override
  State createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  List<Book> books = []; // Modify to hold Book objects
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
  // Fetch books from API and convert them to Book objects
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
          final List<Book> fetchedBooks = data['items'].map<Book>((item) {
            final volumeInfo = item['volumeInfo'];
            final String title = volumeInfo['title'];
            final List<String> authors =
                volumeInfo.containsKey('authors') ? List<String>.from(volumeInfo['authors']) : [];
            final String photoUrl = volumeInfo.containsKey('imageLinks') ? volumeInfo['imageLinks']['thumbnail'] : '';
            final List<String> genres =
                volumeInfo.containsKey('categories') ? List<String>.from(volumeInfo['categories']) : [];

            return Book(
              name: title,
              photoUrl: photoUrl,
              quantity: 0, // Adjust as needed
              author: authors.isNotEmpty ? authors.first : 'Unknown',
              genres: genres,
            );
          }).toList();

          setState(() {
            books.addAll(fetchedBooks);
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

  Future<void> _showQuantityDialog(
  String title, String photoUrl, String author, List<String> genres) async {
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
              _BookListToDatabase(
                title,
                photoUrl,
                quantity!,
                author,
                genres,
              );
            }
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}

  // Add Book to Firestore with author and genre fields
  Future<void> _BookListToDatabase(
    String title, String photoUrl, int quantity, String author, List<String> genres) async {
    const uuid = Uuid();
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
      } else {
        // Add the book if it doesn't exist
        for (int i = 0; i < quantity; i++) {
          await _booksRef.doc().set({
            'name': title,
            'photoUrl': photoUrl,
            'quantity': 1,
            'isBorrowed': 0, // New book is not borrowed by default
            'author': author,
            'genres': genres,
          });
        }
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
            final Book book = books[index];
            

            return ListTile(
              title: Text(book.name),
              subtitle: Text(book.author),
              leading: _buildBookThumbnail(book.photoUrl),
              trailing: 
              IconButton(
              icon: const Icon(Icons.add),
            onPressed: () {
              _showQuantityDialog(book.name, book.photoUrl, book.author, book.genres);
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