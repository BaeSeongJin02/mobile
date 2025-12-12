import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import '../sub/question_page.dart';
import '../analytics/app_analytics.dart'; //  Analytics 통합
import 'package:firebase_remote_config/firebase_remote_config.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final FirebaseRemoteConfig remoteConfig =
      FirebaseRemoteConfig.instance;

  String welcomeTitle = '';
  bool bannerUse = false;
  int itemHeight = 50;

  @override
  void initState() {
    super.initState();
    remoteConfigInit();
  }

  Future<void> remoteConfigInit() async {
    await remoteConfig.fetch();
    await remoteConfig.activate();

    welcomeTitle = remoteConfig.getString('welcome');
    bannerUse = remoteConfig.getBool('banner');
    itemHeight = remoteConfig.getInt('item_height');

    setState(() {});
  }

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

            /// 상단 제목
            const Text(
              '심리 테스트 종류',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF336699),
              ),
            ),

            const SizedBox(height: 20),

            /// 테스트 리스트
            Expanded(
              child: FutureBuilder<String>(
                future: loadAsset(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: Text('No data'));
                  }

                  final Map<String, dynamic> list =
                  jsonDecode(snapshot.data!);

                  return ListView.builder(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: list['count'],
                    itemBuilder: (context, index) {
                      final rawTitle =
                      list['questions'][index]['title']
                          .toString();
                      final isNew =
                      rawTitle.contains('[NEW]');
                      final title = rawTitle
                          .replaceAll('[NEW]', '')
                          .trim();

                      return Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 8),
                        child: Card(
                          color: const Color(0xFFE6F0FA),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                if (isNew)
                                  Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4),
                                    margin:
                                    const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.orangeAccent,
                                      borderRadius:
                                      BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'NEW',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    title,
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
                              color: Color(0xFF336699),
                              size: 18,
                            ),

                            /// Analytics: test_start
                            onTap: () async {
                              await AppAnalytics.logTestStart(title);

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => QuestionPage(
                                    question: list['questions'][index]
                                    ['file']
                                        .toString(),
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

            /// 하단 정보
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
