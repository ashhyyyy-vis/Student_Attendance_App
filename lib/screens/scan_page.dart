import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:async'; // Required for the Timer used in debouncing
import '../service/qr_auth_service.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // Controller setup
  final MobileScannerController _controller = MobileScannerController(
    torchEnabled: false,
    autoStart: true,
  );
  
  // State for zoom scale (User-friendly scale: 1.0 to 5.0)
  double _zoomScale = 1.0; 
  
  // State for torch
  bool _isTorchOn = false;

  // Debouncing setup
  Timer? _debounceTimer; 
  static const Duration _debounceDuration = Duration(milliseconds: 75);

  @override
  void dispose() {
    // Cancel timer and dispose of controller
    _debounceTimer?.cancel(); 
    _controller.dispose();
    super.dispose();
  }

  // --- SCANNING & AUTHENTICATION ---
  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        // Stop scanning while processing
        _controller.stop();
        
        // Submit QR token for authentication and handle result
        _handleQRSubmission(barcode.rawValue!);
      }
    }
  }

  // Handle QR submission with proper async/await
  void _handleQRSubmission(String qrCode) async {
    try {
      final result = await QRAuthService.submitQRToken(qrCode);
      
      if (result['success'] == true) {
        // Success: Navigate to result page
        Navigator.pushNamed(context, '/success');

      } else {
        // Failure: Show error popup and resume scanning
        _showErrorSnackBar(result['message'] ?? 'Authentication failed');
        _controller.start();
      }
    } catch (e) {
      // Exception: Show error popup and resume scanning
      _showErrorSnackBar('Error: ${e.toString()}');
      _controller.start();
    }
  }

  // Show error snackbar at the top of the screen
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 50, left: 16, right: 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- DEBOUNCED ZOOM LOGIC ---
  void _debouncedSetZoom(double newScale) {
    // 1. Cancel the previous timer to reset the debounce window
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    
    // 2. Update the local UI state immediately for smooth slider feedback
    setState(() {
      _zoomScale = newScale;
    });

    // 3. Start a new timer
    _debounceTimer = Timer(_debounceDuration, () async {
      // 4. FIX: Normalize the 1.0-5.0 slider range to the 0.0-1.0 camera range
      // (value - min) / (max - min) => (newScale - 1.0) / 4.0
      double normalizedZoom = (newScale - 1.0) / 4.0;
      normalizedZoom = normalizedZoom.clamp(0.0, 1.0); // Ensure it's within bounds

      // 5. Send the command to the camera
      await _controller.setZoomScale(normalizedZoom);
      print('Zoom Set to: $newScale (Normalized Camera Scale: $normalizedZoom)');
    });
  }
  
  void _onZoomChanged(double value) {
     // Use the debounced function for smooth performance
    _debouncedSetZoom(value);
  }

  void _resetZoom() {
    // Resets the zoom through the debounced function
    _debouncedSetZoom(1.0); 
  }

  // --- TORCH LOGIC ---
  void _toggleTorch() {
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
    _controller.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          // Flash/Torch Toggle Button
          IconButton(
            onPressed: _toggleTorch,
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            tooltip: 'Toggle Flash',
          ),
        ],
      ),
      body: Stack(
        children: [
          // QR Scanner view
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            fit: BoxFit.cover,
          ),
          // Scanning frame
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                children: [
                  // Top-left corner
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.white, width: 3),
                          left: BorderSide(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  ),
                  // Top-right corner
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.white, width: 3),
                          right: BorderSide(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  ),
                  // Bottom-left corner
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white, width: 3),
                          left: BorderSide(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  ),
                  // Bottom-right corner
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white, width: 3),
                          right: BorderSide(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.center_focus_weak,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Reset zoom button (only visible when zoomed in)
          if (_zoomScale > 1.0 + 0.1) // 0.1 buffer to hide when close to min
            Positioned(
              bottom: 50,
              right: 20,
              child: FloatingActionButton.small(
                onPressed: _resetZoom,
                backgroundColor: Colors.redAccent,
                heroTag: 'resetZoomBtn',
                child: const Icon(
                  Icons.center_focus_strong,
                  color: Colors.white,
                ),
              ),
            ),

          // Vertical zoom slider
          Positioned(
            right: 0,
            top: MediaQuery.of(context).size.height * 0.2,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              height: MediaQuery.of(context).size.height * 0.5,
              width: 60,
              child: RotatedBox(
                quarterTurns: 1,
                child: Slider(
                  value: _zoomScale,
                  min: 1.0,
                  max: 5.0,
                  divisions: 40,
                  onChanged: _onZoomChanged,
                  activeColor: Colors.blueAccent,
                  inactiveColor: Colors.white54,
                  thumbColor: Colors.lightBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}