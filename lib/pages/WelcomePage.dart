import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // Sample user and book data (replace with actual data fetching logic)
  final String currentBook = 'The Lord of the Rings';
  final String espn = '12345678';
  final DateTime deadline =
      DateTime.now().add(const Duration(days: 14)); // Set deadline for demo
  final int borrowedCount = 2; // Example number
  final List<BorrowedBook> borrowHistory = [
    const BorrowedBook(
        title: 'Pride and Prejudice', imageUrl: 'path/to/image.jpg'),
    const BorrowedBook(
        title: 'To Kill a Mockingbird', imageUrl: 'path/to/image2.jpg'),
  ];
  final String userId = 'user123';
  final String userName = 'Avinash Bejjam'; // Add user details

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        centerTitle: true,
        backgroundColor: Colors.teal, // Customize app bar color
      ),
      body: SingleChildScrollView(
        // Allow scrolling for long content
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align content left
            children: [
              // User Information (consider using a Card for separation)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hi, $userName!',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'ID: $userId',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const Divider(thickness: 1), // Add separator

              // Currently Borrowed Book
              const Text(
                'Currently Borrowed:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentBook,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ESP Number: $espn'),
                          Text(
                              'Due: ${deadline.toIso8601String()}'), // Format deadline nicely
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15), // Add some spacing

              // Number of Books Borrowed
              Row(
                children: [
                  const Icon(Icons.book, color: Colors.teal),
                  const SizedBox(width: 10),
                  Text(
                    'Total Borrowed: $borrowedCount',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 15), // Add spacing

              // Borrowed Book History
              const Text(
                'Borrowing History:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true, // Prevent list view from expanding
                physics:
                    const NeverScrollableScrollPhysics(), // Disable scrolling
                itemCount: borrowHistory.length,
                itemBuilder: (context, index) {
                  final book = borrowHistory[index];
                  return Card(
                    elevation: 4,
                    child: ListTile(
                      leading: FadeInImage.assetNetwork(
                        placeholder:
                            'assets/images/placeholder.png', // Placeholder image
                        image: book.imageUrl,
                        fit: BoxFit.cover,
                        width: 60,
                        height: 80,
                      ),
                      title: Text(book.title),
                    ),
                  );
                }, // Add missing closing parenthesis
              ), // Add missing closing parenthesis
            ], // Add missing closing square bracket
          ), // Add missing closing parenthesis
        ), // Add missing closing parenthesis
      ), // Add missing closing parenthesis
    ); // Add missing closing parenthesis
  }
}

class BorrowedBook {
  final String title;
  final String imageUrl;

  const BorrowedBook({required this.title, required this.imageUrl});
}
