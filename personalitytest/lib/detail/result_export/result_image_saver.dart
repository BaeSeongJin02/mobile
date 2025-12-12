import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class ResultImageSaver {
  /// RepaintBoundary를 이미지로 변환 후 파일로 저장
  static Future<String?> saveWidgetAsImage(
      GlobalKey repaintKey,
      ) async {
    try {
      final boundary =
      repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      /// 해상도 선명하게 (3.0 추천)
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      final byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/result_${DateTime.now().millisecondsSinceEpoch}.png';

      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      return filePath;
    } catch (e) {
      debugPrint('이미지 저장 실패: $e');
      return null;
    }
  }
}
