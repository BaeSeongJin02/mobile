import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../detail/detail_page.dart';

class QuestionPage extends StatefulWidget {
  final String question;

  const QuestionPage({super.key, required this.question});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  Map<String, dynamic>? questionData;

  @override
  void initState() {
    super.initState();
    loadQuestion();
  }

  Future<void> loadQuestion() async {
    final String jsonString = await rootBundle.loadString('res/api/${widget.question}.json');
    final data = jsonDecode(jsonString);
    setState(() {
      questionData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questionData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(questionData!['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionData!['question'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...List.generate(questionData!['selects'].length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPage(
                            question: questionData!['title'],
                            answer: questionData!['answer'][index],
                            selectedIndex: index,
                            totalOptions: questionData!['selects'].length,
                          ),
                        ),
                      );
                    },
                  child: Card(
                    color: const Color(0xFFE6F0FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.blue.shade100, width: 1),
                    ),
                    elevation: 2,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Text(
                        questionData!['selects'][index],
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
