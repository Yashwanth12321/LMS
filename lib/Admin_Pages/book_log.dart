import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms/Admin_Pages/qr_code_page.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BookLog extends StatefulWidget {
  const BookLog({Key? key}) : super(key: key);

  @override
  _BookLogState createState() => _BookLogState();
}

class _BookLogState extends State<BookLog> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteAllBooks() async {
    final confirmation = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete All'),
        content: const Text('Are you sure you want to delete all books?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      final QuerySnapshot<Map<String, dynamic>> booksSnapshot =
          await FirebaseFirestore.instance.collection('books').get();
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      for (final DocumentSnapshot<Map<String, dynamic>> book
          in booksSnapshot.docs) {
        batch.delete(book.reference);
      }
      await batch.commit();
      print('All books deleted successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Log"),
        backgroundColor: const Color.fromARGB(255, 0, 255, 102),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: BookSearchDelegate());
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _deleteAllBooks,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('books')
            .where('isBorrowed', isEqualTo: 0)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<DocumentSnapshot<Map<String, dynamic>>> books =
                snapshot.data!.docs;
            if (books.isEmpty) {
              return const Center(child: Text('No books found!'));
            }
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index].data()!;
                final title = book['name'];
                final photoUrl = book['photoUrl'];
                final quantity = book['quantity'];
                final docId = books[index].id;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    elevation: 3,
                    child: ListTile(
                      leading: _buildBookThumbnail(photoUrl),
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('Quantity: $quantity'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              await _showEditQuantityDialog(
                                  context, title, quantity, docId);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await _deleteBook(context, docId);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.qr_code),
                            onPressed: () async {
                              final qrCodeData = docId;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      QRCodePage(qrCodeData: qrCodeData),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildBookThumbnail(String? photoUrl) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Image.network(photoUrl);
    } else {
      return const Icon(Icons.book); // Placeholder for missing image
    }
  }

  Future<void> _showEditQuantityDialog(BuildContext context, String title,
      int currentQuantity, String docId) async {
    int? newQuantity;
    TextEditingController controller =
        TextEditingController(text: currentQuantity.toString());
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Quantity for "$title"'),
        content: TextField(
          keyboardType: TextInputType.number,
          controller: controller,
          onChanged: (value) => newQuantity = int.tryParse(value),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (newQuantity != null && newQuantity! > 0) {
                _updateBookQuantity(docId, newQuantity!);
              }
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateBookQuantity(String docId, int newQuantity) async {
    try {
      await FirebaseFirestore.instance.collection('books').doc(docId).update({
        'quantity': newQuantity,
      });
      print('Book quantity updated successfully!');
    } catch (error) {
      print('Error updating book quantity: $error');
    }
  }

  Future<void> _deleteBook(BuildContext context, String docId) async {
    final confirmation = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      await _removeFromFirestore(docId);
    }
  }

  Future<void> _removeFromFirestore(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('books').doc(docId).delete();
      print('Book deleted successfully!');
    } catch (error) {
      print('Error deleting book: $error');
    }
  }
}

class BookSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('books')
          .where('name', isEqualTo: query)
          .where('isBorrowed', isEqualTo: 0)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final List<DocumentSnapshot<Map<String, dynamic>>> books =
              snapshot.data!.docs;
          if (books.isEmpty) {
            return Center(child: Text('No books found for "$query"'));
          } else {
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index].data()!;
                final title = book['name'];
                final photoUrl = book['photoUrl'];
                final quantity = book['quantity'];
                final docId = books[index].id;

                return ListTile(
                  title: Text(title),
                  subtitle: Text('Quantity: $quantity'),
                  leading: _buildBookThumbnail(photoUrl),
                  onTap: () {
                    query = title;
                    showResults(context);
                  },
                );
              },
            );
          }
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('books')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('isBorrowed', isEqualTo: 0)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final List<DocumentSnapshot<Map<String, dynamic>>> books =
              snapshot.data!.docs;
          if (books.isEmpty) {
            return Center(child: Text('No books found for "$query"'));
          } else {
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index].data()!;
                final title = book['name'];
                final photoUrl = book['photoUrl'];
                final quantity = book['quantity'];
                // final docId = books[index].id;

                return ListTile(
                  title: Text(title),
                  subtitle: Text('Quantity: $quantity'),
                  leading: _buildBookThumbnail(photoUrl),
                  onTap: () {
                    query = title;
                    showResults(context);
                  },
                );
              },
            );
          }
        }
      },
    );
  }

  Widget _buildBookThumbnail(String? photoUrl) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Image.network(photoUrl);
    } else {
      return const Icon(Icons.book); // Placeholder for missing image
    }
  }
}

void main() {
  runApp(const MaterialApp(
    home: BookLog(),
  ));
}
