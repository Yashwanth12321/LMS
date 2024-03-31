import 'package:flutter/material.dart';
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
      body: Center(
        child: Container(
          child: const Text("Admin Lobby", style: TextStyle(fontSize: 20),),
        ),
      ),
    );
  }
}
