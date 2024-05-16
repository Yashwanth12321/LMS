import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms/Admin_Pages/admin_menu.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[600],
        title: const Text('EzBorrow'),
      ),
      drawer: const AdminMenu(),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          print('Connection State: ${snapshot.connectionState}');
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            print("Loading");
            return const CircularProgressIndicator();
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final books = snapshot.data!.docs
                .where((doc) => doc.data().containsKey('TakenBy'))
                .toList();

            if (books.isEmpty) {
              return const Center(
                child: Text(
                  "No books have been borrowed yet",
                  style: TextStyle(fontSize: 20),
                ),
              );
            }

            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index].data();
                final title = book['name'];
                final photoUrl = book['photoUrl'];
                final takenBy = book['TakenBy'];
                final docId = books[index].id;

                // Initialize lists to hold user IDs and borrowed dates
                List<String> userIds = [];
                List<DateTime?> borrowedDates = [];

                if (takenBy != null && takenBy is Map<String, dynamic>) {
                  takenBy.forEach((userId, userDetails) {
                    if (userDetails is Map<String, dynamic> &&
                        userDetails.containsKey('userID') &&
                        userDetails.containsKey('BorrowDate')) {
                      userIds.add(userDetails['userID']);
                      // Attempt to convert Timestamp to DateTime
                      try {
                        DateTime? borrowedDate =
                            userDetails['BorrowDate'].toDate();
                        borrowedDates.add(borrowedDate);
                        print('Borrowed Date: $borrowedDate');
                      } catch (e) {
                        // Log or handle the error appropriately
                        print('Error converting BorrowDate to DateTime: $e');
                      }
                    }
                  });
                }
                // Create a column of list tiles for each user taking the book
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: userIds.map((userId) {
                        // Find the index of the userId in the userIds list
                        int? userIdIndex = userIds.indexOf(userId);

                        // Check if the userIdIndex is valid and corresponds to a DateTime in borrowedDates
                        if (userIdIndex != null &&
                            userIdIndex < borrowedDates.length) {
                          DateTime? borrowedDate = borrowedDates[userIdIndex];

                          return ListTile(
                            leading: _buildBookThumbnail(photoUrl),
                            title: Text(
                              '$title Taken By: $userId',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                                'Borrowed Date: ${borrowedDate?.toLocal().toString().split(' ')[0]}'), // Display only the date
                          );
                        } else {
                          // Handle the case where no corresponding DateTime is found for the userId
                          return ListTile(
                            leading: _buildBookThumbnail(photoUrl),
                            title: Text(
                              '$title Taken By: $userId',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                                'No Borrowed Date Found'), // Indicate that no date was found
                          );
                        }
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
      return const Icon(Icons.book);
    }
  }
}
