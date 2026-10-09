import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// OcrService encapsulates Google ML Kit On-Device Text Recognition.
/// Runs completely offline without cloud dependencies, ensuring user privacy and speed.
class OcrService {
  TextRecognizer? _textRecognizer;

  TextRecognizer get _recognizer {
    _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _textRecognizer!;
  }

  /// Processes local image and returns recognized blocks of text
  Future<RecognizedText> processImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    return await _recognizer.processImage(inputImage);
  }

  /// Releases ML Kit native resources
  void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
  }
}
