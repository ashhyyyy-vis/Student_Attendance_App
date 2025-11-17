import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:async'; // Required for the Timer used in debouncing
import '../service/qr_auth_service.dart'; // Assuming this service exists in your project

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
  
  // State for zoom scale (User-friendly scale: 0.5 to 5.0)
  // 0.5 is the new logical minimum (fully zoomed out)
  double _zoomScale = 0.5; 
  
  // ADDED: Local state to track torch status, as _controller.torchState is unavailable
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

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    // We only process the first detected barcode
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {      
      // Submit QR token for authentication
      _handleQRSubmission(barcodes.first.rawValue!);
    }
  }

  // Handle QR submission with proper async/await
  void _handleQRSubmission(String qrCode) async {
    //_controller.stop();
    
    try {
      
      final result = await QRAuthService.submitQRToken(qrCode);

      if (result['success'] == true) {
       Navigator.pushNamed(context, '/success');
        
      } else {
        _showErrorSnackBar((result['message'] as String?) ?? 'Authentication failed');
        _controller.start();
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
      _controller.start();
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        // Positioning the SnackBar at the top
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10, // Below status bar
          left: 16, 
          right: 16
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  // Helper for success snackbar (using the existing error format for simplicity)
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16, 
          right: 16
        ),
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
    // NOTE: This newScale is the logical zoom value (0.5 to 5.0)
    setState(() {
      _zoomScale = newScale;
    });

    // 3. Start a new timer
    _debounceTimer = Timer(_debounceDuration, () async {
      // 4. Normalize the 0.5-5.0 logical range to the 0.0-1.0 camera range
      // Range is 4.5 (5.0 - 0.5)
      double normalizedZoom = (newScale - 0.5) / 4.5;
      
      // 5. Clamp ensures we never go below 0.0 or above 1.0 (camera limits)
      normalizedZoom = normalizedZoom.clamp(0.0, 1.0); 

      // 6. Send the command to the camera
      await _controller.setZoomScale(normalizedZoom);
      print('Zoom Set to: $newScale (Normalized Camera Scale: $normalizedZoom)');
    });
  }
  
  void _onZoomChanged(double value) {
     // Use the debounced function instead of direct call
    _debouncedSetZoom(value);
  }

  void _resetZoom() {
    _debouncedSetZoom(0.5); // Resets the zoom to the new logical minimum
  }

  // Logic to toggle local state and camera torch
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
            // Use local state to determine the icon
            icon: Icon(
              _isTorchOn
                  ? Icons.flash_on
                  : Icons.flash_off,
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
          
          // Scanning frame (styled with corner boxes)
          Center(
            child: SizedBox(
              width: 200, // Increased size for better target visibility
              height: 200,
              child: Stack(
                children: [
                  // Corner markers
                  ..._buildCornerMarker(Alignment.topLeft),
                  ..._buildCornerMarker(Alignment.topRight),
                  ..._buildCornerMarker(Alignment.bottomLeft),
                  ..._buildCornerMarker(Alignment.bottomRight),
                  // Center icon (optional, for visual guide)
                ],
              ),
            ),
          ),
          
          // Reset zoom button (only visible when zoomed in)
          if (_zoomScale > 0.5 + 0.1) // 0.1 buffer to hide when close to min
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
                quarterTurns: 1, // Rotates 90 degrees clockwise (Top=Max, Bottom=Min)
                child: Slider(
                  // REVERSAL FIX: Use the new constant 5.5 (5.0 + 0.5)
                  // When _zoomScale (logical zoom) is 0.5 (Zoom Out), Slider.value is 5.0 (Visual Top).
                  value: 5.5 - _zoomScale, 
                  min: 0.5, // New minimum
                  max: 5.0,
                  divisions: 45, // 5.0 - 0.5 = 4.5 -> 45 divisions (for 0.1 increments)
                  // The onChanged value is the visual position (5.0 at top, 0.5 at bottom).
                  onChanged: (visualValue) {
                    // Reverse the visual value back to the logical zoom scale (0.5 to 5.0).
                    final logicalScale = 5.5 - visualValue; // New reversal constant
                    _onZoomChanged(logicalScale); 
                  }, 
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

  // Helper function to build the corner markers for the scanning frame
  List<Widget> _buildCornerMarker(Alignment alignment) {
    const double markerSize = 25.0;
    const double markerThickness = 3.0;
    const Color markerColor = Colors.lightBlue;
    const double cornerRadius = 8.0; // Radius for rounded corners

    // Use Align to position the markers relative to the SizedBox bounds
    return [
      // Horizontal line with rounded end
      Positioned(
        left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft
            ? 0
            : null,
        right: alignment == Alignment.topRight || alignment == Alignment.bottomRight
            ? 0
            : null,
        top: alignment == Alignment.topLeft || alignment == Alignment.topRight
            ? 0
            : null,
        bottom: alignment == Alignment.bottomLeft ||
                alignment == Alignment.bottomRight
            ? 0
            : null,
        child: Container(
          width: markerSize,
          height: markerThickness,
          decoration: BoxDecoration(
            color: markerColor,
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(
                (alignment == Alignment.topLeft || alignment == Alignment.bottomLeft) 
                    ? cornerRadius 
                    : 0.0
              ),
              right: Radius.circular(
                (alignment == Alignment.topRight || alignment == Alignment.bottomRight) 
                    ? cornerRadius 
                    : 0.0
              ),
            ),
          ),
        ),
      ),
      // Vertical line with rounded end
      Positioned(
        left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft
            ? 0
            : null,
        right: alignment == Alignment.topRight || alignment == Alignment.bottomRight
            ? 0
            : null,
        top: alignment == Alignment.topLeft || alignment == Alignment.topRight
            ? 0
            : null,
        bottom: alignment == Alignment.bottomLeft ||
                alignment == Alignment.bottomRight
            ? 0
            : null,
        child: Container(
          width: markerThickness,
          height: markerSize,
          decoration: BoxDecoration(
            color: markerColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                (alignment == Alignment.topLeft || alignment == Alignment.topRight) 
                    ? cornerRadius 
                    : 0.0
              ),
              bottom: Radius.circular(
                (alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight) 
                    ? cornerRadius 
                    : 0.0
              ),
            ),
          ),
        ),
      ),
    ];
  }
}