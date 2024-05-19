import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms/Admin_Pages/qr_code_page.dart';

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
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
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

            // Group books by title and calculate total quantity
            final Map<String, List<Map<String, dynamic>>> groupedBooks = {};
            for (var book in books) {
              final title = book['name'];
              final quantity = book['quantity'];
              final photoUrl = book['photoUrl'];
              final isBorrowed = book['isBorrowed'];
              final docId = book.id;
              if (!groupedBooks.containsKey(title)) {
                groupedBooks[title] = [];
              }
              groupedBooks[title]!.add({
                'quantity': quantity,
                'photoUrl': photoUrl,
                'isBorrowed': isBorrowed,
                'docId': docId,
              });
            }

            final List<String> sortedTitles = groupedBooks.keys.toList()..sort();

            return ListView.builder(
              itemCount: sortedTitles.length,
              itemBuilder: (context, index) {
                final title = sortedTitles[index];
                final books = groupedBooks[title]!;
                final totalQuantity = books.fold<int>(
                    0, (sum, book) => sum + (book['quantity'] as int));

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    elevation: 3,
                    child: ExpansionTile(
                      leading: _buildBookThumbnail(books.first['photoUrl']),
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('Total Quantity: $totalQuantity'),
                      children: books.map((book) {
                        final docId = book['docId'];
                        final quantity = book['quantity'];
                        final photoUrl = book['photoUrl'];
                        final isBorrowed = book['isBorrowed'];
                        return ListTile(
                          leading: _buildBookThumbnail(photoUrl),
                          title: Text('Quantity: $quantity'),
                          subtitle: isBorrowed == 1
                              ? const Text('Status: Issued', style: TextStyle(fontWeight: FontWeight.bold))
                              : const Text('Status: Available', style: TextStyle(fontWeight: FontWeight.bold),),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // IconButton(
                              //   icon: const Icon(Icons.edit),
                              //   onPressed: () async {
                              //     await BookSearchDelegate
                              //         ._showEditQuantityDialog(
                              //       context,
                              //       title,
                              //       quantity,
                              //       docId,
                              //     );
                              //   },
                              // ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await BookSearchDelegate._deleteBook(
                                      context, docId, 'userId');
                                },
                              ),
                              // isBorrowed == 0 
                              // ? 
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
                                )
                              // :IconButton(
                              //   icon: const Icon(Icons.qr_code),
                              //   onPressed: ()  {},
                              // ) ,
                            ],
                          ),
                        );
                      }).toList(),
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
          .where('name', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('name', isLessThan: '${query.toLowerCase()}z')
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
              final book = books[index];
              final title = book['name'];
              final quantity = book['quantity'];
              final photoUrl = book['photoUrl'];
              final docId = book.id;

              return ListTile(
                leading: _buildBookThumbnail(photoUrl),
                title: Text(title),
                subtitle: Text('Quantity: $quantity'),
                onTap: () async {
                  // Handle tapping on the book item
                  await BookSearchDelegate._showEditQuantityDialog(
                      context, title, quantity, docId);
                },
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('books').snapshots(),
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
          }

          final List<DocumentSnapshot<Map<String, dynamic>>> filteredBooks =
              books.where((book) {
            final name = book['name'].toString().toLowerCase();
            return name.contains(query.toLowerCase());
          }).toList();

          if (filteredBooks.isEmpty) {
            return Center(child: Text('No books found for "$query"'));
          }

          // Group books by title and calculate total quantity
          final Map<String, List<Map<String, dynamic>>> groupedBooks = {};
          for (var book in filteredBooks) {
            final title = book['name'];
            final quantity = book['quantity'];
            final photoUrl = book['photoUrl'];
            final isBorrowed = book['isBorrowed'];
            final docId = book.id;
            if (!groupedBooks.containsKey(title)) {
              groupedBooks[title] = [];
            }
            groupedBooks[title]!.add({
              'quantity': quantity,
              'photoUrl': photoUrl,
              'isBorrowed': isBorrowed,
              'docId': docId,
            });
          }

          final List<String> sortedTitles = groupedBooks.keys.toList()..sort();

          return ListView.builder(
            itemCount: sortedTitles.length,
            itemBuilder: (context, index) {
              final title = sortedTitles[index];
              final books = groupedBooks[title]!;
              final totalQuantity = books.fold<int>(
                  0, (sum, book) => sum + (book['quantity'] as int));

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  elevation: 3,
                  child: ExpansionTile(
                    leading: _buildBookThumbnail(books.first['photoUrl']),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text('Total Quantity: $totalQuantity'),
                    children: books.map((book) {
                      final docId = book['docId'];
                      final quantity = book['quantity'];
                      final photoUrl = book['photoUrl'];
                      final isBorrowed = book['isBorrowed'];
                      return ListTile(
                        leading: _buildBookThumbnail(photoUrl),
                        title: Text('Quantity: $quantity'),
                        subtitle: isBorrowed == 1
                            ? const Text('Status: Issued')
                            : const Text('Status: Available'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                await BookSearchDelegate
                                    ._showEditQuantityDialog(
                                  context,
                                  title,
                                  quantity,
                                  docId,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await BookSearchDelegate._deleteBook(
                                    context, docId, 'userId');
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
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  static Future<void> _showEditQuantityDialog(BuildContext context,
      String title, int currentQuantity, String docId) async {
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
                // Call a function to update quantity in Firestore
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

  static Future<void> _updateBookQuantity(String docId, int newQuantity) async {
    try {
      await FirebaseFirestore.instance.collection('books').doc(docId).update({
        'quantity': newQuantity,
      });
      print('Book quantity updated successfully!');
    } catch (error) {
      print('Error updating book quantity: $error');
    }
  }

  static Future<void> _deleteBook(BuildContext context, String docId, String userId) async {
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
      // Implement logic to add the book to the user's account here
      // For example:
      // await _addToUserAccount(userId, docId);
    }
  }

  static Future<void> _removeFromFirestore(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('books').doc(docId).delete();
      print('Book deleted successfully!');
    } catch (error) {
      print('Error deleting book: $error');
    }
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