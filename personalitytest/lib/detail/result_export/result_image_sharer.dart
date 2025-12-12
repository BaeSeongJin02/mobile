import 'dart:io';
import 'package:share_plus/share_plus.dart';

class ResultImageSharer {
  static Future<void> shareImage(String imagePath) async {
    final file = File(imagePath);

    if (await file.exists()) {
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: '내 심리테스트 결과!',
      );
    }
  }
}
