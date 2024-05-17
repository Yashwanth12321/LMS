import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Import the qr_flutter package
import 'package:barcode_widget/barcode_widget.dart'; // Import the barcode_widget package

class QRCodePage extends StatelessWidget {
  final String qrCodeData;

  const QRCodePage({Key? key, required this.qrCodeData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code'),
      ),
      body: Center(
        child: BarcodeWidget(
          // Use BarcodeWidget to display the barcode
          barcode: Barcode.code128(),
          data: qrCodeData,
          width: 200.0,
          height: 100.0,
        ),
      ),
    );
  }
}

// Your IconButton onPressed function remains the same
