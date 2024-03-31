import 'package:flutter/material.dart';
import 'package:lms/User_Pages/user_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: const Text('EzBorrow'),
        actions: [
          IconButton(
            onPressed: () {
              // need to complete for bar-code scanner
            }, 
            icon: const Icon(Icons.qr_code_scanner, size: 24.0, color: Colors.black,)
          ),
        ],
      ),
      drawer: const UserMenu(),
      body: Center(
        child: Container(
          child: const Text("Hello User", style: TextStyle(fontSize: 20),),
        ),
      ),
    );
  }
}
