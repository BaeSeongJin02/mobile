import 'package:flutter/material.dart';
import '../main/main_list_page.dart'; // 메인 페이지로 돌아가기 위해 필요

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
    double percentage = (1 / totalOptions) * 100; // 임의로 고른 선택 비중

    return Scaffold(
      appBar: AppBar(
        title: Text('$question 결과'),
        backgroundColor: const Color(0xFFA7C7E7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              '결과',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              answer,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Text(
              '당신과 같은 선택을 한 사람의 비중 (가상): ${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainPage()),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA7C7E7),
              ),
              child: const Text('메인으로 돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}
