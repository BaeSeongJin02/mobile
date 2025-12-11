import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import '../sub/question_page.dart'; // 이미 쓰고 있던 페이지

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  // 로컬 JSON만 사용 (Firebase, RemoteConfig, AdMob 전부 제거)
  Future<String> loadAsset() async {
    return await rootBundle.loadString('res/api/list.json');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 상단 제목 (RemoteConfig 대신 고정 텍스트)
            const Text(
              '심리 테스트',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF336699),
              ),
            ),

            const SizedBox(height: 20),

            // 테스트 리스트
            Expanded(
              child: FutureBuilder<String>(
                future: loadAsset(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('JSON 파일을 불러오는 중 오류가 발생했습니다.'),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text('데이터를 불러올 수 없습니다.'),
                    );
                  }

                  final list = jsonDecode(snapshot.data!);

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: list['count'],
                    itemBuilder: (context, index) {
                      final item = list['questions'][index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Card(
                          color: const Color(0xFFE6F0FA),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              item['title'].toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF333333),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF336699),
                              size: 18,
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => QuestionPage(
                                    question: item['file'],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                '인공지능공학부 20214275 배성진',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
