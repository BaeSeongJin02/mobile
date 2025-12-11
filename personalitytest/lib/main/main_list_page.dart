import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../sub/question_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart'; // 추가
import 'package:firebase_remote_config/firebase_remote_config.dart'; // 추가

class MainPage extends StatefulWidget{
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState(){
    return _MainPage();
  }
}

class _MainPage extends State<MainPage> {

  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance; // 추가

  String welcomeTitle = ''; // 추가
  bool bannerUse = false; // 추가
  int itemHeight = 50; // 추가

  @override
  void initState() {
    super.initState();
    remoteConfigInit();
  }

  void remoteConfigInit() async {
    await remoteConfig.fetch();
    await remoteConfig.activate(); // activate()를 명시적으로 호출하기

    welcomeTitle = remoteConfig.getString('welcome');
    bannerUse = remoteConfig.getBool('banner');
    itemHeight = remoteConfig.getInt('item_height');

    setState(() {}); // 값 변경 후 UI 업데이트
  }

  Future<String> loadAsset() async {
    return await rootBundle.loadString('res/api/list.json');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // 전체 배경 파스텔 블루
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 상단 제목 텍스트
            const Text(
              '심리 테스트 종류',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF336699), // 진한 파란색 텍스트
              ),
            ),

            const SizedBox(height: 20),

            // 테스트 리스트 (가운데 정렬)
            Expanded(
              child: FutureBuilder<String>(
                future: loadAsset(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Center(child: CircularProgressIndicator());
                    case ConnectionState.done:
                      if (snapshot.hasData) {
                        Map<String, dynamic> list = jsonDecode(snapshot.data!);
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: list['count'],
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Card(
                                color: const Color(0xFFE6F0FA), // 파스텔 카드
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      if (list['questions'][index]['title'].toString().contains("[NEW]"))
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          margin: const EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.orangeAccent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            "NEW",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                      Expanded(
                                        child: Text(
                                          list['questions'][index]['title']
                                              .toString()
                                              .replaceAll("[NEW]", "")
                                              .trim(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF333333),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Color(0xFF336699), // 아이콘 컬러
                                    size: 18,
                                  ),
                                  onTap: () async {
                                    try {
                                      await FirebaseAnalytics.instance.logEvent(
                                        name: 'test_click',
                                        parameters: {
                                          'test_name': list['questions'][index]['title']
                                              .toString(),
                                        },
                                      );
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return QuestionPage(
                                              question: list['questions'][index]['file']
                                                  .toString(),
                                            );
                                          },
                                        ),
                                      );
                                    } catch (e) {
                                      print('Failed to log event: $e');
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(child: Text('No data'));
                      }
                    default:
                      return const Center(child: Text('No data'));
                  }
                },
              ),
            ),

            // 하단 학번/이름 표시
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                '인공지능공학부 20214275 배성진',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999), // 연한 회색
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}