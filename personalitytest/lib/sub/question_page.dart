import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../detail/detail_page.dart';
import '../animations/scale_tap.dart';
import '../analytics/app_analytics.dart'; // Analytics 추가

class QuestionPage extends StatefulWidget {
  final String question;

  const QuestionPage({super.key, required this.question});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  Map<String, dynamic>? data;
  int currentStep = 0;
  List<int> selectedScores = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final String jsonString =
    await rootBundle.loadString('res/api/${widget.question}.json');
    final jsonData = jsonDecode(jsonString);

    setState(() {
      data = jsonData;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final questions = data!["questions"];
    final totalSteps = questions.length;
    final currentQuestion = questions[currentStep];
    final double progress = (currentStep + 1) / totalSteps;

    return Scaffold(
      appBar: AppBar(
        title: Text(data!["title"]),
        leading: currentStep > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              currentStep--;
              selectedScores.removeLast();
            });
          },
        )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 진행률 바
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              color: const Color(0xFF7BA6C7),
              backgroundColor: Colors.black12,
            ),
            const SizedBox(height: 20),

            /// 질문 Fade 애니메이션
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: Column(
                key: ValueKey(currentStep),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 질문 텍스트
                  Text(
                    currentQuestion["question"],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// 선택지 목록
                  ...List.generate(
                    currentQuestion["selects"].length,
                        (index) {
                      final item = currentQuestion["selects"][index];

                      return Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 8),
                        child: ScaleTap(
                          onTap: () async {
                            final score = item["score"];
                            selectedScores.add(score);

                            /// Analytics: 질문 선택
                            await AppAnalytics.logQuestionAnswered(
                              testName: data!["title"],
                              step: currentStep + 1,
                              selectedScore: score,
                            );

                            if (currentStep == totalSteps - 1) {
                              /// 최종 점수 계산
                              final int finalScore =
                              (selectedScores.reduce((a, b) => a + b) /
                                  totalSteps)
                                  .round();

                              /// Analytics: 테스트 완료
                              await AppAnalytics.logTestCompleted(
                                testName: data!["title"],
                                resultIndex: finalScore,
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailPage(
                                    question: data!["title"],
                                    answer:
                                    data!["results"][finalScore],
                                    selectedIndex: finalScore,
                                    totalOptions: 4,
                                  ),
                                ),
                              );
                            } else {
                              setState(() {
                                currentStep++;
                              });
                            }
                          },
                          child: Card(
                            color: const Color(0xFFE6F0FA),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.blue.shade100,
                                width: 1.2,
                              ),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding:
                              const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                              child: Text(
                                item["text"],
                                style:
                                const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
