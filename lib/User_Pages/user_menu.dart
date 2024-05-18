import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lms/User_Pages/borrowing_history.dart';
import 'package:lms/User_Pages/wishlist.dart';
import 'package:lms/pages/home_page.dart';

class UserMenu extends StatefulWidget {
  final String email;

  const UserMenu({required this.email, Key? key}) : super(key: key);

  @override
  _UserMenuState createState() => _UserMenuState();
}

class _UserMenuState extends State<UserMenu> {
  Future<void> _confirmSignOut(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Handle logout logic here (e.g., sign out with Firebase)
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Menu Bar', style: TextStyle(fontSize: 28)),
          ),
          ListTile(
            title: const Text('Home', style: TextStyle(fontSize: 14)),
            leading: const Icon(Icons.home_filled),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage(email: widget.email)),
              );
            },
          ),
          ListTile(
            title: const Text('Borrow History', style: TextStyle(fontSize: 14)),
            leading: const Icon(Icons.grading_sharp),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BorrowHistory(email: widget.email)),
              );
            },
          ),
          ListTile(
            title: const Text('Wishlist', style: TextStyle(fontSize: 14)),
            leading: const Icon(Icons.favorite),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WishList(email: widget.email,)),
              );
            },
          ),
          ListTile(
            title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
            leading: const Icon(Icons.logout),
            onTap: () async {
              await _confirmSignOut(context);
            },
          ),
        ],
      ),
    );
  }
}
