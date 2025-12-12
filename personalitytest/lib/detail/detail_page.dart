import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb

import '../animations/fade_slide.dart';
import '../animations/confetti_burst.dart';
import 'result_export/result_image_saver.dart';
import 'result_export/result_image_sharer.dart';
import 'result_export/result_firestore_saver.dart';
import '../analytics/app_analytics.dart';

class DetailPage extends StatelessWidget {
  final String question;
  final String answer;
  final int selectedIndex;
  final int totalOptions;

  DetailPage({
    super.key,
    required this.question,
    required this.answer,
    required this.selectedIndex,
    required this.totalOptions,
  });

  final GlobalKey _repaintKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final double percent = (1 / totalOptions) * 100;

    /// 결과별 색상 테마
    final List<Color> resultColors = [
      const Color(0xFFE8F0FF),
      const Color(0xFFFFF0E6),
      const Color(0xFFE6FFF3),
      const Color(0xFFF3E6FF),
    ];
    final Color cardColor =
    resultColors[selectedIndex % resultColors.length];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text("$question 결과"),
        backgroundColor: const Color(0xFFBFD5E8),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          const ConfettiBurst(),

          /// 저장 대상 영역
          RepaintBoundary(
            key: _repaintKey,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FadeSlide(
                offsetY: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    const Text(
                      "결과",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        answer.trim(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.55,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      "당신과 같은 선택 비중 (가상): ${percent.toStringAsFixed(1)}%",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percent / 100,
                        minHeight: 12,
                        backgroundColor: Colors.black12,
                        color: const Color(0xFF7BA6C7),
                      ),
                    ),

                    const Spacer(),

                    ///  카카오톡 공유
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.chat),
                        label: const Text("카카오톡으로 공유하기"),
                        style: OutlinedButton.styleFrom(
                          padding:
                          const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: Colors.black,
                          backgroundColor:
                          const Color(0xFFFEE500),
                          side: const BorderSide(
                              color: Color(0xFFFEE500)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () async {
                          ///  1. Firestore 저장 (항상 실행)
                          await ResultFirestoreSaver.saveResult(
                            testName: question,
                            resultIndex: selectedIndex,
                          );

                          ///  Analytics
                          await AppAnalytics.logResultShared(question);

                          /// Web이면 여기서 종료
                          if (kIsWeb) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "결과가 데이터베이스에 저장되었습니다"),
                                ),
                              );
                            }
                            return;
                          }

                          /// 모바일에서 이미지 공유
                          final path =
                          await ResultImageSaver
                              .saveWidgetAsImage(_repaintKey);

                          if (path != null && context.mounted) {
                            await ResultImageSharer.shareImage(path);
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// 이미지 저장
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text("결과 이미지 저장"),
                        style: OutlinedButton.styleFrom(
                          padding:
                          const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor:
                          const Color(0xFF4A6FA5),
                          side: const BorderSide(
                              color: Color(0xFF4A6FA5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () async {
                          /// 1. Firestore 저장
                          await ResultFirestoreSaver.saveResult(
                            testName: question,
                            resultIndex: selectedIndex,
                          );

                          ///  Analytics
                          await AppAnalytics.logResultSaved(question);

                          ///  Web 처리
                          if (kIsWeb) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "결과가 데이터베이스에 저장되었습니다"),
                                ),
                              );
                            }
                            return;
                          }

                          ///  모바일에서 이미지 저장
                          final path =
                          await ResultImageSaver
                              .saveWidgetAsImage(_repaintKey);

                          if (path != null && context.mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content:
                                Text("결과 이미지가 저장되었습니다"),
                              ),
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    ///  메인으로 돌아가기
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFFB6CDE2),
                          foregroundColor: Colors.white,
                          padding:
                          const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 3,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "메인으로 돌아가기",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
