import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lms/Admin_Pages/book_log.dart';
import 'package:lms/Admin_Pages/add_book.dart';
import 'package:lms/Admin_Pages/book_list.dart';
import 'package:lms/Admin_Pages/return.dart';
import 'package:lms/pages/admin_home.dart';

class AdminMenu extends StatelessWidget {
  const AdminMenu({Key? key}) : super(key: key);

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
          DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/adminhome.jpg'), // Replace 'assets/images/adminhome.jpg' with your actual asset image path
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(1.0), BlendMode.dstATop), // Make the image translucent
              ),
            ),
            child: const Text('Hello Admin', style: TextStyle(fontSize: 28, color: Colors.white)), // Change the text to "Hello Admin"
          ),
          ListTile(
            title: const Text('Home', style: TextStyle(fontSize: 14)),
            leading: const Icon(Icons.home_filled),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminHomePage()),
              );
            },
          ),
          ListTile(
            title: const Text('Books Log', style: TextStyle(fontSize: 14)),
            leading: const Icon(Icons.edit),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookLog()),
              );
            },
          ),
          ListTile(
            title: const Text('Book List', style: TextStyle(fontSize: 14)),
            leading: const Icon(Icons.list),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookList()),
              );
            },
          ),
          ListTile(
            title: const Text('Add Book', style: TextStyle(fontSize: 14)),
            leading: const Icon(Icons.add),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddBook()),
              );
            },
          ),
          ListTile(
            title: const Text('Return ', style: TextStyle(fontSize: 14)),
            leading: const Icon(Icons.reset_tv_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReturnPage()),
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