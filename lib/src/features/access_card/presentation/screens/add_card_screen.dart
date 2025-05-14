import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sicpa/src/features/access_card/presentation/providers/qr_scanner_providers.dart';
import 'package:sicpa/src/features/access_card/presentation/providers/totp_list_notifier.dart'; // Assuming this provides totpListProvider

// QROverlayPainter remains the same as you provided
class QROverlayPainter extends CustomPainter {
  final double scanWindowSize;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;

  QROverlayPainter({
    this.scanWindowSize = 250.0,
    this.borderRadius = 12.0,
    this.borderColor = Colors.green,
    this.borderWidth = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()..color = Colors.black.withOpacity(0.5);
    final Rect screenRect = Rect.fromLTWH(0, 0, size.width, size.height);

    final RRect scanWindowRRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: screenRect.center,
        width: scanWindowSize,
        height: scanWindowSize,
      ),
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );

    final Path path = Path.combine(
      PathOperation.difference,
      Path()..addRect(screenRect),
      Path()..addRRect(scanWindowRRect),
    );
    canvas.drawPath(path, backgroundPaint);

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawRRect(scanWindowRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant QROverlayPainter oldDelegate) {
    return oldDelegate.scanWindowSize != scanWindowSize ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}


class AddCardScreen extends ConsumerStatefulWidget {
  const AddCardScreen({super.key});

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final qrScannerController = ref.watch(mobileScannerControllerProvider);
    final qrScannerDisplayState = ref.watch(qrScannerStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Card'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: qrScannerController,
            onDetect: (capture) async {
              if (_isProcessing) return;

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null && code.isNotEmpty) {
                  // Indicate processing has started
                  setState(() {
                    _isProcessing = true;
                  });

                  // Stop the camera to prevent further scans while processing
                  try {
                    await qrScannerController.stop();
                  } catch (e) {
                    print("Error stopping scanner: $e");
                    
                  }

                  ref.read(qrScannerStateProvider.notifier).setQrCode(code);

                  try {
                    // Attempt to add the TOTP
                    await ref.read(totpListProvider.notifier).addTotp(code);

                    if (!mounted) return; // Check if widget is still in the tree

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Card added successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(context).pop(); // Close screen on success

                  } catch (e) { // Handle errors from addTotp
                    if (!mounted) return;

                    String errorMessage = 'Failed to add card.';
                    if (e is FormatException) {
                      errorMessage = 'Invalid QR code format: ${e.message}';
                    } else {
                      errorMessage = 'Error: ${e.toString()}';
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                    Navigator.of(context).pop(); // Close screen on error
                    // Error occurred, allow scanning again
                    if (mounted) {
                      setState(() {
                        _isProcessing = false;
                      });
                      // Restart the scanner so the user can try again
                      try {
                        await qrScannerController.start();
                      } catch (startError) {
                        print("Error restarting scanner: $startError");
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Scanner error. Please go back and try again.'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    }
                  }
                  // Note: _isProcessing is reset only in the error path above.
                  // On success, the screen is popped, so resetting it for this instance isn't necessary.
                }
              }
            },
          ),
          CustomPaint(
            painter: QROverlayPainter(
              scanWindowSize: MediaQuery.of(context).size.width * 0.7,
              borderRadius: 12.0,
              borderColor: _isProcessing ? Colors.grey : Colors.tealAccent, // Visual feedback
              borderWidth: 3.0,
            ),
            child: const SizedBox.expand(),
          ),
          if (_isProcessing) // Show a processing indicator
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 10),
                    Text('Processing...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          if (qrScannerDisplayState != null && qrScannerDisplayState.isNotEmpty && !_isProcessing)
            Positioned(
              // ... (rest of your scanned data display widget)
              bottom: 40,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Scanned: $qrScannerDisplayState',
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}