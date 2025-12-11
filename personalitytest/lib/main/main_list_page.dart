import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../sub/question_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

// 광고 패키지 추가
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MainPage();
  }
}

class _MainPage extends State<MainPage> {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  String welcomeTitle = '';
  bool bannerUse = false;
  int itemHeight = 50;

  BannerAd? _bannerAd; // 배너 광고 객체

  @override
  void initState() {
    super.initState();
    remoteConfigInit();
    loadBannerAd(); // 광고 로드
  }

  // 🔹 광고 초기화 함수
  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // 테스트 광고 ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print("광고 로드 완료");
          setState(() {});
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print("광고 로드 실패: $error");
          ad.dispose();
        },
      ),
    )..load();
  }

  // 🔹 RemoteConfig 정보 불러오기
  void remoteConfigInit() async {
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
      backgroundColor: const Color(0xFFF0F4F8), // 파스텔 블루 배경
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🔹 상단 제목
            const Text(
              '심리 테스트 종류',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF336699),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 테스트 리스트
            Expanded(
              child: FutureBuilder<String>(
                future: loadAsset(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: Text('No data'));
                  }

                  Map<String, dynamic> list = jsonDecode(snapshot.data!);

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: list['count'],
                    itemBuilder: (context, index) {
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
                              list['questions'][index]['title'].toString(),
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
                            onTap: () async {
                              try {
                                await FirebaseAnalytics.instance.logEvent(
                                  name: 'test_click',
                                  parameters: {
                                    'test_name': list['questions'][index]['title'].toString(),
                                  },
                                );

                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return QuestionPage(
                                        question: list['questions'][index]['file'].toString(),
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
                },
              ),
            ),

            // 🔹 광고 배너 영역
            if (_bannerAd != null)
              SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),

            // 🔹 하단 학번/이름
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
