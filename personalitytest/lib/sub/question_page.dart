import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../detail/detail_page.dart';
import '../animations/scale_tap.dart';

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

    double progress = (currentStep + 1) / totalSteps;

    return Scaffold(
      appBar: AppBar(
        title: Text(data!["title"]),
        leading: currentStep > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (currentStep > 0) {
              setState(() {
                currentStep--;
                selectedScores.removeLast(); // 이전 선택 제거
              });
            }
          },
        )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///  진행률
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              color: const Color(0xFF7BA6C7),
              backgroundColor: Colors.black12,
            ),
            const SizedBox(height: 20),

            ///  AnimatedSwitcher로 Fade 애니메이션 추가
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },

              /// AnimatedSwitcher는 child의 key가 달라야 애니메이션을 적용함
              child: Column(
                key: ValueKey(currentStep),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///  질문
                  Text(
                    currentQuestion["question"],
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  ///  선택지
                  ...List.generate(currentQuestion["selects"].length, (index) {
                    final item = currentQuestion["selects"][index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ScaleTap(
                        onTap: () {
                          selectedScores.add(item["score"]);

                          if (currentStep == totalSteps - 1) {
                            /// 최종 결과 계산
                            int finalScore = (selectedScores.reduce((a, b) => a + b) /
                                totalSteps)
                                .round();

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailPage(
                                  question: data!["title"],
                                  answer: data!["results"][finalScore],
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
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.blue.shade100,
                              width: 1.2,
                            ),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                            child: Text(
                              item["text"],
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    );
                  })
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
