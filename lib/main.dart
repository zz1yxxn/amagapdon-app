import 'package:flutter/material.dart';
import 'screens/main_chat_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/analysis_page.dart';
import 'screens/consultation_history_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Samo - AI 회상 상담',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/main': (context) => const HomeScreen(),
        '/history': (context) => const ConsultationHistoryScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showResult = false;
  Map<String, dynamic>? _analysisData;

  void _handleConsultationEnd(Map<String, dynamic> data) {
    setState(() {
      _analysisData = data;
      _showResult = true;
    });
  }

  void _handleStartNewConsultation() {
    setState(() {
      _showResult = false;
      _analysisData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult && _analysisData != null) {
      return ResultScreen(
        analysisData: _analysisData!,
        onStartNew: _handleStartNewConsultation,
      );
    }

    return MainChat(
      onConsultationEnd: _handleConsultationEnd,
    );
  }
}

// 결과 화면
class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> analysisData;
  final VoidCallback onStartNew;

  const ResultScreen({
    Key? key,
    required this.analysisData,
    required this.onStartNew,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emotions = analysisData['emotions'] as Map<String, dynamic>;
    final summary = analysisData['summary'] as String;
    final recommendations = analysisData['recommendations'] as String;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    Text(
                      '상담 분석 결과',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '오늘 상담 내용을 분석했습니다',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '감정 분석',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: emotions.entries.map((entry) {
                            final value = _parseEmotionValue(entry.value);
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: value / 100,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: _getEmotionColor(entry.key),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '$value',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '상담 요약',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          summary,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '권장사항',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          recommendations,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/history');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '이전 기록 보기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onStartNew,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '새 상담 시작하기',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _parseEmotionValue(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  Color _getEmotionColor(String key) {
    switch (key) {
      case '기쁨':
      case 'joy':
        return Colors.yellow[600]!;
      case '행복':
      case 'happiness':
        return Colors.orange[400]!;
      case '슬픔':
      case 'sadness':
        return Colors.blue[500]!;
      case '분노':
      case 'anger':
        return Colors.red[500]!;
      case '두려움':
      case 'fear':
        return Colors.purple[500]!;
      case '놀람':
      case 'surprise':
        return Colors.orange[500]!;
      case '평온':
      case 'neutral':
        return Colors.green[500]!;
      case '그리움':
        return Colors.indigo[400]!;
      case '설렘':
        return Colors.pink[400]!;
      case '감사':
        return Colors.teal[400]!;
      case '사랑':
        return Colors.red[300]!;
      case '외로움':
        return Colors.blueGrey[500]!;
      case '미안함':
        return Colors.amber[700]!;
      case '후회':
        return Colors.brown[400]!;
      case '걱정':
        return Colors.deepPurple[400]!;
      default:
        return Colors.grey[500]!;
    }
  }
}