import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// ── OCR Service ───────────────────────────────────────────────────────────────

class OcrService {
  final TextRecognizer _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> recognizeText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    try {
      final recognizedText = await _recognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      throw OcrException('Failed to recognize text: $e');
    }
  }

  void dispose() {
    _recognizer.close();
  }
}

class OcrException implements Exception {
  final String message;
  OcrException(this.message);

  @override
  String toString() => 'OcrException: $message';
}

// ── Scan State ────────────────────────────────────────────────────────────────

enum ScanStatus {
  idle,
  capturing,
  processing,
  done,
  error,
}

class ScanState {
  final ScanStatus status;
  final String? capturedImagePath;
  final String? recognizedText;
  final String? errorMessage;

  const ScanState({
    this.status = ScanStatus.idle,
    this.capturedImagePath,
    this.recognizedText,
    this.errorMessage,
  });

  ScanState copyWith({
    ScanStatus? status,
    String? capturedImagePath,
    String? recognizedText,
    String? errorMessage,
  }) {
    return ScanState(
      status: status ?? this.status,
      capturedImagePath: capturedImagePath ?? this.capturedImagePath,
      recognizedText: recognizedText ?? this.recognizedText,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading =>
      status == ScanStatus.capturing || status == ScanStatus.processing;
}

// ── Scan Notifier ─────────────────────────────────────────────────────────────

class ScanNotifier extends StateNotifier<ScanState> {
  final OcrService _ocrService;

  ScanNotifier(this._ocrService) : super(const ScanState());

  Future<String?> processImage(String imagePath) async {
    state = state.copyWith(
      status: ScanStatus.processing,
      capturedImagePath: imagePath,
    );

    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        state = state.copyWith(
          status: ScanStatus.error,
          errorMessage: 'Image file not found.',
        );
        return null;
      }

      final text = await _ocrService.recognizeText(file);

      state = state.copyWith(
        status: ScanStatus.done,
        recognizedText: text,
        capturedImagePath: imagePath,
      );

      return text;
    } catch (e) {
      state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  void reset() {
    state = const ScanState();
  }

  void setCapturing() {
    state = state.copyWith(status: ScanStatus.capturing);
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = OcrService();
  ref.onDispose(service.dispose);
  return service;
});

final scanStateProvider =
    StateNotifierProvider.autoDispose<ScanNotifier, ScanState>((ref) {
  final ocrService = ref.watch(ocrServiceProvider);
  return ScanNotifier(ocrService);
});
