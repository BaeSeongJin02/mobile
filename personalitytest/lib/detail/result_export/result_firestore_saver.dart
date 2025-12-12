import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ResultFirestoreSaver {
  static Future<void> saveResult({
    required String testName,
    required int resultIndex,
  }) async {
    await FirebaseFirestore.instance
        .collection('test_results')
        .add({
      'testName': testName,
      'resultIndex': resultIndex,
      'platform': kIsWeb ? 'web' : 'android',
      'createdAt': Timestamp.now(),
    });
  }
}
