import 'package:flutter/material.dart';
import '../animations/fade_slide.dart';
import '../animations/confetti_burst.dart';

class DetailPage extends StatelessWidget {
  final String question;
  final String answer;
  final int selectedIndex;
  final int totalOptions;

  const DetailPage({
    super.key,
    required this.question,
    required this.answer,
    required this.selectedIndex,
    required this.totalOptions,
  });

  @override
  Widget build(BuildContext context) {
    double percent = (1 / totalOptions) * 100;

    /// 선택한 결과에 따른 색상 테마
    final List<Color> resultColors = [
      const Color(0xFFE8F0FF), // 0번
      const Color(0xFFFFF0E6), // 1번
      const Color(0xFFE6FFF3), // 2번
      const Color(0xFFF3E6FF), // 3번
    ];
    final Color cardColor = resultColors[selectedIndex % resultColors.length];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text("$question 결과"),
        backgroundColor: const Color(0xFFBFD5E8),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          /// 🎉 Confetti 애니메이션 (animations/confetti_burst.dart)
          const ConfettiBurst(),

          /// 메인 내용
          Padding(
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

                  const SizedBox(height: 40),

                  Text(
                    "당신과 같은 선택을 한 사람의 비중 (가상) : ${percent.toStringAsFixed(1)}%",
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

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB6CDE2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 40,
                      ),
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

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
