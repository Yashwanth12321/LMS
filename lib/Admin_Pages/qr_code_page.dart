import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Import the qr_flutter package

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
        child: QrImageView(
          // Use QrImage widget to display the QR code
          data: qrCodeData,
          version: QrVersions.auto,
          size: 200.0,
        ),
      ),
    );
  }
}

// Your IconButton onPressed function remains the same
