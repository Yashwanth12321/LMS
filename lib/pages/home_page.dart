import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:lms/User_Pages/user_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  String _scanResult = "";
  @override

  Future<void> scanCode() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to scan';
    }

    setState(() {
      _scanResult = barcodeScanRes;
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: const Text('EzBorrow'),
        actions: [
          IconButton(
            onPressed: () {
              // need to complete for bar-code scanner
              scanCode();
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
