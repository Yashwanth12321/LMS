import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BorrowHistory extends StatelessWidget {
  final String email;

  const BorrowHistory({required this.email, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrow History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(email)
            .collection('borrowed_books')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No borrow history found.'));
          }
          var borrowHistory = snapshot.data!.docs;
          return ListView.builder(
            itemCount: borrowHistory.length,
            itemBuilder: (context, index) {
              var history = borrowHistory[index].data() as Map<String, dynamic>;

              // Convert the 'deadlineDate' field to a DateTime
              Timestamp deadlineTimestamp = history['deadlineDate'] as Timestamp;
              DateTime deadlineDateTime = deadlineTimestamp.toDate();

              // Manually format the date string to display only date/month/year
              String formattedDeadline = '${deadlineDateTime.day}/${deadlineDateTime.month}/${deadlineDateTime.year}';

              // Safely handle the display of optional fields
              return ListTile(
                title: Text(history['name'] ?? 'No name'),
                subtitle: Text('Deadline: $formattedDeadline'), // Display formatted date
                leading: history['photoUrl'] != null
                    ? Image.network(history['photoUrl'])
                    : const Icon(Icons.book),
              );
            },
          );
        },
      ),
    );
  }
}
