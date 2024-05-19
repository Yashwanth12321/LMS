import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms/Admin_Pages/admin_menu.dart'; // Import AdminMenu

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
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
        title: const Text("Admin Home Page"),
        backgroundColor: const Color.fromARGB(255, 0, 255, 102),
      ),
      drawer: const AdminMenu(), // Use AdminMenu as the drawer
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<DocumentSnapshot> books = snapshot.data!.docs;
            final Map<String, int> totalQuantityPerBook = {};

            for (var book in books) {
              final title = book['name'];
              final quantity = book['quantity'] as int; // Ensure quantity is treated as an integer

              totalQuantityPerBook[title] = (totalQuantityPerBook[title] ?? 0) + quantity;
            }

            // Now you have a map of total quantities per book, you can use it to display titles and total quantities
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Available Books',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: totalQuantityPerBook.keys.map((title) {
                      final totalQuantity = totalQuantityPerBook[title]!;
                      int borrowedQuantity = 0; // Initialize borrowed quantity

                      // Check if there are any borrowed books
                      for (var book in books) {
                        if (book['name'] == title && book['isBorrowed'] == 1) {
                          borrowedQuantity++; // Increment borrowed quantity
                        }
                      }

                      // Adjust total quantity based on borrowed books
                      final adjustedTotalQuantity = totalQuantity - borrowedQuantity;

                      if (adjustedTotalQuantity < 4) {
                        final imageUrl = books
                            .firstWhere((book) => book['name'] == title)['photoUrl']; // Get the photoUrl for the current book
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 150, // Adjust the width of the container
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 100, // Adjust the width of the image
                                  height: 100, // Adjust the height of the image
                                  child: Image.network(imageUrl),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Total Quantity: $adjustedTotalQuantity',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink(); // Return an empty widget if adjusted total quantity is not less than 4
                      }
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20), // Add space between the two scrollable rows
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Top Borrowed Books',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('books').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final List<DocumentSnapshot> books = snapshot.data!.docs;
                      final Map<String, Map<String, dynamic>> bookBorrowCounts = {};

                      for (var book in books) {
                        final isBorrowed = book['isBorrowed'] as int;
                        final bookName = book['name'] as String;
                        final photoUrl = book['photoUrl'] as String;

                        if (isBorrowed == 1) {
                          if (bookBorrowCounts.containsKey(bookName)) {
                            bookBorrowCounts[bookName]!['count'] = bookBorrowCounts[bookName]!['count'] + 1;
                          } else {
                            bookBorrowCounts[bookName] = {'count': 1, 'photoUrl': photoUrl};
                          }
                        }
                      }

                      final topBorrowedBooks = bookBorrowCounts.entries
                          .toList()
                            ..sort((a, b) => b.value['count'].compareTo(a.value['count']));

                      final top5Books = topBorrowedBooks.take(5).toList();

                      if (top5Books.isEmpty) {
                        return const Center(child: Text('No borrowed books available'));
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: top5Books.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 150, // Adjusted width
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 100, // Adjusted width
                                      height: 100, // Adjusted height
                                      child: Image.network(
                                        entry.value['photoUrl'],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      entry.key, // Book name
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Times Borrowed: ${entry.value['count']}'),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
  // Remaining methods
}
