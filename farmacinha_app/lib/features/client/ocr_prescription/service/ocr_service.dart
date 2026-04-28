import 'dart:io';
import 'dart:ui' as ui;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _textRecognizer;

  OcrService({TextRecognizer? textRecognizer})
    : _textRecognizer =
          textRecognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> extractRawText(String imagePath) async {
    // LGPD: o OCR roda localmente via ML Kit e retorna apenas o texto bruto
    // para uso em memoria durante o fluxo atual, sem persistencia automatica.
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _textRecognizer.processImage(inputImage);

    final buffer = StringBuffer();

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final cleanLine = line.text.trim();
        if (cleanLine.isEmpty) continue;
        buffer.writeln(cleanLine);
      }
    }

    final formattedText = buffer.toString().trim();
    if (formattedText.isNotEmpty) {
      return formattedText;
    }

    return recognizedText.text.trim();
  }

  Future<String> extractRawTextFromFile(File imageFile) {
    return extractRawText(imageFile.path);
  }

  Future<String?> detectPrescriptionColor(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 64);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

    if (byteData == null) {
      return null;
    }

    final pixels = byteData.buffer.asUint8List();
    var totalPixels = 0;
    var blueVotes = 0;
    var yellowVotes = 0;
    var whiteVotes = 0;

    for (var index = 0; index <= pixels.length - 4; index += 16) {
      final red = pixels[index].toDouble();
      final green = pixels[index + 1].toDouble();
      final blue = pixels[index + 2].toDouble();

      final maxValue = [red, green, blue].reduce((a, b) => a > b ? a : b) / 255;
      final minValue = [red, green, blue].reduce((a, b) => a < b ? a : b) / 255;
      final delta = maxValue - minValue;
      final saturation = maxValue == 0 ? 0.0 : delta / maxValue;

      totalPixels++;

      if (maxValue > 0.82 && saturation < 0.18) {
        whiteVotes++;
        continue;
      }

      if (blue > red * 1.08 && blue > green * 1.08 && saturation > 0.18) {
        blueVotes++;
        continue;
      }

      final isYellow = red > 150 &&
          green > 145 &&
          blue < 170 &&
          (red - blue) > 25 &&
          (green - blue) > 20 &&
          saturation > 0.12;

      if (isYellow) {
        yellowVotes++;
      }
    }

    if (totalPixels == 0) {
      return null;
    }

    final whiteRatio = whiteVotes / totalPixels;
    final blueRatio = blueVotes / totalPixels;
    final yellowRatio = yellowVotes / totalPixels;

    if (yellowRatio >= 0.12 && yellowRatio > blueRatio) {
      return 'Amarela';
    }

    if (blueRatio >= 0.12) {
      return 'Azul';
    }

    if (whiteRatio >= 0.45) {
      return 'Branca';
    }

    return null;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
