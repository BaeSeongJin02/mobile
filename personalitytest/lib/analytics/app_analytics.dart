import 'package:firebase_analytics/firebase_analytics.dart';

class AppAnalytics {
  static final FirebaseAnalytics _analytics =
      FirebaseAnalytics.instance;

  /// 테스트 시작
  static Future<void> logTestStart(String testName) async {
    await _analytics.logEvent(
      name: 'test_start',
      parameters: {
        'test_name': testName,
      },
    );
  }

  /// 질문 선택
  static Future<void> logQuestionAnswered({
    required String testName,
    required int step,
    required int selectedScore,
  }) async {
    await _analytics.logEvent(
      name: 'question_answered',
      parameters: {
        'test_name': testName,
        'step': step,
        'score': selectedScore,
      },
    );
  }

  /// 테스트 완료 (결과 페이지 진입)
  static Future<void> logTestCompleted({
    required String testName,
    required int resultIndex,
  }) async {
    await _analytics.logEvent(
      name: 'test_completed',
      parameters: {
        'test_name': testName,
        'result_index': resultIndex,
      },
    );
  }

  /// 결과 저장
  static Future<void> logResultSaved(String testName) async {
    await _analytics.logEvent(
      name: 'result_saved',
      parameters: {
        'test_name': testName,
      },
    );
  }

  /// 결과 공유
  static Future<void> logResultShared(String testName) async {
    await _analytics.logEvent(
      name: 'result_shared',
      parameters: {
        'test_name': testName,
      },
    );
  }
}
