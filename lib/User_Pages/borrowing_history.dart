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
              var history =
                  borrowHistory[index].data() as Map<String, dynamic>;
              
              // Assign borrowedDateTime as null if the 'deadline' field is null
              DateTime? borrowedDateTime;
              if (history['deadline'] != null) {
                Timestamp borrowedDate = history['deadline'];
                borrowedDateTime = borrowedDate.toDate();
              }

              // Manually format the date string to display only date/month/year
              String formattedDeadline = borrowedDateTime != null
                  ? '${borrowedDateTime.day}/${borrowedDateTime.month}/${borrowedDateTime.year}'
                  : 'Not specified';

              return ListTile(
                title: Text(history['name']),
                subtitle: Text('Deadline: $formattedDeadline'), // Display formatted date
                leading: Image.network(history['photoUrl']),
              );
            },
          );
        },
      ),
    );
  }
}
