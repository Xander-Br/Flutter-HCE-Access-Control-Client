import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerProviders extends StateNotifier<String?> {
  QrScannerProviders() : super(null);

  void setQrCode(String? qrCode) {
    state = qrCode;
  }

  void clearQrCode() {
    state = null;
  }
}

final qrScannerProvider =
    StateNotifierProvider<QrScannerProviders, String?>((ref) {
  return QrScannerProviders();
});

final mobileScannerControllerProvider = Provider.autoDispose<MobileScannerController>((ref) {
  final controller = MobileScannerController(
    // detectionSpeed: DetectionSpeed.noDuplicates, 
    // facing: CameraFacing.back,
    // torchEnabled: false,
  );

  ref.onDispose(() {
    print("Disposing MobileScannerController"); 
    controller.dispose();
  });

  

  return controller;
});