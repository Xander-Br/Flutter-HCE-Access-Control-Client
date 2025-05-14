import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sicpa/src/features/access_card/presentation/providers/qr_scanner_providers.dart';

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

class AddCardScreen extends ConsumerWidget {
  const AddCardScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrScannerController = ref.watch(mobileScannerControllerProvider);
    final qrScannerState = ref.watch(qrScannerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Card'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: qrScannerController, 
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null && code.isNotEmpty) {
                  ref.read(qrScannerProvider.notifier).setQrCode(code);
                }
              }
            },
          ),
          // QR Code Scanner Overlay
          CustomPaint(
            painter: QROverlayPainter(
              scanWindowSize: MediaQuery.of(context).size.width * 0.7, 
              borderRadius: 12.0,
              borderColor: Colors.tealAccent,
              borderWidth: 3.0,
            ),
            child: SizedBox.expand(), 
          ),
          if (qrScannerState != null && qrScannerState.isNotEmpty)
            Positioned(
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
                  'Scanned Code: $qrScannerState',
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