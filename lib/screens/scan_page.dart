import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/globals.dart' as globals;

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool scanned = false;
  late final MobileScannerController cameraController;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (scanned || globals.scannedToday) return;
    scanned = true;

    final payload = capture.barcodes.first.rawValue ?? '';

    if (payload == globals.validQrPayload) {
      globals.attendanceCount += 1;
      globals.scannedToday = true;

      cameraController.stop();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/success');
    } else {
      cameraController.stop();
      if (!mounted) return;
      _showInvalidDialog();
    }
  }

  void _showInvalidDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Invalid QR',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Scanned code is not a valid attendance QR. Try again.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              scanned = false;
              cameraController.start();
            },
            child: const Text('Try again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: cameraController,
              onDetect: _onDetect,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Point the camera at the attendance QR code',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
