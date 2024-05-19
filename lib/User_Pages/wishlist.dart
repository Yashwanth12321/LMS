import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms/User_Pages/user_menu.dart';

class WishList extends StatefulWidget {
  final String email;

  const WishList({required this.email, Key? key}) : super(key: key);

  @override
  State<WishList> createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  List<Map<String, dynamic>> uniqueWishlist = [];

  static const List<Color> COLORS = [
    Color(0xFFEF7A85),
    Color.fromARGB(255, 78, 226, 226),
    Color(0xFFFFC2E2),
    Color.fromARGB(255, 227, 217, 79),
    Color(0xFFB892FF)
  ];
  
  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    try {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(widget.email);
      final wishlistSnapshot = await userDocRef.collection('wishlist').get();

      final Map<String, Map<String, dynamic>> bookMap = {};

      for (var doc in wishlistSnapshot.docs) {
        final bookName = doc['name'];
        final bookAuthor = doc['author'];
        final bookPhoto = doc['photoUrl']; // Assume photoUrl field exists

        if (bookMap.containsKey(bookName)) {
          bookMap[bookName]!['quantity'] += 1;
        } else {
          bookMap[bookName] = {
            'name': bookName,
            'author': bookAuthor,
            'photoUrl': bookPhoto,
            'quantity': 1,
          };
        }
      }

      setState(() {
        uniqueWishlist = bookMap.values.toList();
      });
    } catch (error) {
      print('Error fetching wishlist: $error');
    }
  }

  Future<void> removeFromWishlist(String bookName) async {
    try {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(widget.email);
      final wishlistDocRef = userDocRef.collection('wishlist').where('name', isEqualTo: bookName);
      
      // Get all documents that match the book name
      final querySnapshot = await wishlistDocRef.get();
      
      // Loop through all documents and delete them
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      // Update the user's wishlist field
      await _updateUserWishlistField(bookName);

      // Update the UI by removing the book from the list
      setState(() {
        uniqueWishlist.removeWhere((book) => book['name'] == bookName);
      });
    } catch (error) {
      print('Error removing book from wishlist: $error');
    }
  }

  Future<void> _updateUserWishlistField(String bookName) async {
    try {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(widget.email);
      final userDoc = await userDocRef.get();
      final List<dynamic> currentWishlist = userDoc.get('wishlist');

      // Remove the book from the current wishlist
      currentWishlist.removeWhere((book) => book == bookName);

      // Update the wishlist field in the user's document
      await userDocRef.update({'wishlist': currentWishlist});
    } catch (error) {
      print('Error updating user wishlist field: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          "Wishlist Page",
          style: TextStyle(color: Colors.black),
        ),
      ),
      drawer: UserMenu(email: widget.email),
      body: Stack(
        children: <Widget>[
          Transform.translate(
            offset: Offset(0.0, MediaQuery.of(context).size.height * 0.1050),
            child: ListView.builder(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.1050,
                bottom: 100.0, // Adjust this value as needed
              ),
              scrollDirection: Axis.vertical,
              primary: true,
              itemCount: uniqueWishlist.length,
              itemBuilder: (BuildContext content, int index) {
                final book = uniqueWishlist[index];
                return Dismissible(
                  key: Key(book['name']),
                  onDismissed: (direction) {
                    removeFromWishlist(book['name']);
                  },
                  child: AwesomeListItem(
                    title: book["name"],
                    content: book["author"],
                    color: COLORS[Random().nextInt(COLORS.length)],
                    image: book["photoUrl"],
                  ),
                );
              },
            ),
          ),
          Transform.translate(
            offset: Offset(0.0, -56.0),
            child: Container(
              child: ClipPath(
                clipper: MyClipper(),
                child: Stack(
                  children: [
                    Image.asset('assets/images/image.png', fit: BoxFit.cover),
                    Opacity(
                      opacity: 0.2,
                      child: Container(color: COLORS[0]),
                    ),
                    Transform.translate(
                      offset: Offset(0.0, 50.0),
                      child: ListTile(
                        title: Text(
                          "",
                          style: TextStyle(
                              color: Color.fromARGB(255, 249, 248, 246),
                              fontSize: 32.0,
                              letterSpacing: 2.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = Path();
    p.lineTo(size.width, 0.0);
    p.lineTo(size.width, size.height / 4.75);
    p.lineTo(0.0, size.height / 3.75);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class AwesomeListItem extends StatelessWidget {
  final String title;
  final String content;
  final Color color;
  final String image;

  const AwesomeListItem({
    required this.title,
    required this.content,
    required this.color,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(width: 10.0, height: 190.0, color: color),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    content,
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 150.0,
          width: 150.0,
          color: Colors.white,
          child: Stack(
            children: <Widget>[
              Transform.translate(
                offset: Offset(50.0, 0.0),
                child: Container(
                  height: 100.0,
                  width: 100.0,
                  color: color,
                ),
              ),
              Transform.translate(
                offset: Offset(10.0, 20.0),
                child: Card(
                  elevation: 20.0,
                  child: Container(
                    height: 120.0,
                    width: 120.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          width: 10.0,
                          color: Colors.white,
                          style: BorderStyle.solid),
                      image: DecorationImage(
                        image: NetworkImage(image),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}