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
    // Extract the username from the email
    String username = widget.email.split('@')[0];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5), // Translucent black color
                  BlendMode.srcOver,
                ),
                image: const AssetImage('assets/images/hiuser.jpg'),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  left: 16,
                  child: Text(
                    'Hello $username',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_filled),
            title: const Text('Home', style: TextStyle(fontSize: 14)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage(email: widget.email)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.grading_sharp),
            title: const Text('Borrow History', style: TextStyle(fontSize: 14)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BorrowHistory(email: widget.email)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Wishlist', style: TextStyle(fontSize: 14)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WishList(email: widget.email)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () async {
              await _confirmSignOut(context);
            },
          ),
        ],
      ),
    );
  }
}