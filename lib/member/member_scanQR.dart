import 'package:applanner/member/member_scannedDetails.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class MemberScanQR extends StatefulWidget {
  const MemberScanQR({super.key});

  @override
  State<StatefulWidget> createState() => _MemberScanQRState();
}

class _MemberScanQRState extends State<MemberScanQR> {
  Barcode? _barcode;

  bool _isDetailOpen = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  void _handleBarcode(BarcodeCapture barcodes) async {
    if (mounted) {
      setState(() {
        _barcode = barcodes.barcodes.firstOrNull;
      });

      if (!_isDetailOpen) {
        setState(() {
          _isDetailOpen = !_isDetailOpen;
        });
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MemberScannedDetails(uid: _barcode?.displayValue ?? '',)),
        ).then((value) {
          // print(value);

          if (value == true) {
            setState(() {
              _isDetailOpen = !_isDetailOpen;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan QR")),
      body: Stack(
        children: [
          MobileScanner(onDetect: _handleBarcode),
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Container(
          //     alignment: Alignment.bottomCenter,
          //     height: 100,
          //     color: const Color.fromRGBO(0, 0, 0, 0.4),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //       children: [
          //         Expanded(child: Center(child: _barcodePreview(_barcode))),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
