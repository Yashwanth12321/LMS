import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookListPage extends StatelessWidget {
  const BookListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book List"),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<DocumentSnapshot<Map<String, dynamic>>> books =
                snapshot.data!.docs;
            if (books.isEmpty) {
              return Center(child: const Text('No books found!'));
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        child: ListTile(
          leading: _buildBookThumbnail(photoUrl),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text('Quantity: $quantity'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  await _showEditQuantityDialog(
                    context,
                    title,
                    quantity,
                    docId,
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await _deleteBook(context, docId);
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
}

Widget _buildBookThumbnail(String? photoUrl) {
  if (photoUrl != null && photoUrl.isNotEmpty) {
    return Image.network(photoUrl);
  } else {
    return const Icon(Icons.book); // Placeholder for missing image
  }
}
Future<void> _showEditQuantityDialog(BuildContext context, String title, int currentQuantity, String docId) async {
  int? newQuantity;
  TextEditingController controller = TextEditingController(text: currentQuantity.toString());
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
      title: Text('Confirm Delete'),
      content: Text('Are you sure you want to delete this book?'),
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
  return; 
}

Future<void> _removeFromFirestore(String docId) async {
  try {
    await FirebaseFirestore.instance.collection('books').doc(docId).delete();
    print('Book deleted successfully!');
  } catch (error) {
    print('Error deleting book: $error');
    
  }
}
