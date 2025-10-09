import 'package:flutter/material.dart';
import '../models/consultation_record.dart';

class ConsultationHistoryScreen extends StatefulWidget {
  const ConsultationHistoryScreen({super.key});

  @override
  State<ConsultationHistoryScreen> createState() => _ConsultationHistoryScreenState();
}

class _ConsultationHistoryScreenState extends State<ConsultationHistoryScreen> {
  ConsultationRecord? _selectedRecord;

  // 모든 상담 기록 (예시 데이터)
  final List<ConsultationRecord> _consultationRecords = [
    ConsultationRecord(
      id: '1',
      date: '2024년 10월 7일',
      time: '14:30',
      duration: '25분',
      mainEmotion: '슬픔',
      summary: '최근 가족 관계에서의 어려움에 대해 이야기했습니다. 소외감과 외로움을 많이 느끼고 계시는 상황입니다.',
      emotionScore: 35,
    ),
    ConsultationRecord(
      id: '2',
      date: '2024년 10월 5일',
      time: '10:15',
      duration: '30분',
      mainEmotion: '기쁨',
      summary: '손자들과의 즐거운 시간에 대한 이야기를 나누었습니다. 가족들과의 좋은 추억을 많이 가지고 계십니다.',
      emotionScore: 78,
    ),
    ConsultationRecord(
      id: '3',
      date: '2024년 10월 2일',
      time: '16:45',
      duration: '35분',
      mainEmotion: '불안',
      summary: '건강에 대한 걱정과 미래에 대한 불안감을 표현하셨습니다. 정기 검진 결과를 기다리는 상황입니다.',
      emotionScore: 28,
    ),
    ConsultationRecord(
      id: '4',
      date: '2024년 9월 28일',
      time: '11:20',
      duration: '20분',
      mainEmotion: '중립',
      summary: '일상적인 대화를 나누었습니다. 평범한 하루 일과와 취미 활동에 대해 이야기했습니다.',
      emotionScore: 52,
    ),
    ConsultationRecord(
      id: '5',
      date: '2024년 9월 25일',
      time: '15:10',
      duration: '40분',
      mainEmotion: '분노',
      summary: '이웃과의 갈등 상황에 대한 분노와 억울함을 표현하셨습니다.',
      emotionScore: 18,
    ),
  ];

  Color _getEmotionColor(String emotion) {
    switch (emotion) {
      case '기쁨':
        return Colors.yellow[100]!;
      case '슬픔':
        return Colors.blue[100]!;
      case '분노':
        return Colors.red[100]!;
      case '불안':
        return Colors.purple[100]!;
      case '놀라움':
        return Colors.green[100]!;
      case '중립':
        return Colors.grey[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getEmotionTextColor(String emotion) {
    switch (emotion) {
      case '기쁨':
        return Colors.yellow[800]!;
      case '슬픔':
        return Colors.blue[800]!;
      case '분노':
        return Colors.red[800]!;
      case '불안':
        return Colors.purple[800]!;
      case '놀라움':
        return Colors.green[800]!;
      case '중립':
        return Colors.grey[800]!;
      default:
        return Colors.grey[800]!;
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 40) return Colors.green[600]!;
    if (score >= 25) return Colors.yellow[700]!;
    return Colors.red[600]!;
  }

  String _getScoreMessage(int score) {
    if (score >= 40) return '좋은 상태입니다';
    if (score >= 25) return '보통 상태입니다';
    return '관심이 필요한 상태입니다';
  }

  void _goBack() {
    if (_selectedRecord != null) {
      setState(() {
        _selectedRecord = null;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedRecord != null) {
      // 상세 뷰
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.blue[50]!],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // 헤더
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton(
                          onPressed: _goBack,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            foregroundColor: Colors.grey[700],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '← 뒤로가기',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '상담 기록 상세',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedRecord!.date,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // 내용
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // 정보 그리드
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.5,
                          children: [
                            _buildInfoCard(
                              '날짜',
                              _selectedRecord!.date,
                              Colors.blue[50]!,
                              Colors.blue[200]!,
                            ),
                            _buildInfoCard(
                              '시간',
                              _selectedRecord!.time,
                              Colors.green[50]!,
                              Colors.green[200]!,
                            ),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.purple[50],
                                border: Border.all(color: Colors.purple[200]!),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '주요 감정',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getEmotionColor(_selectedRecord!.mainEmotion),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      _selectedRecord!.mainEmotion,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _getEmotionTextColor(_selectedRecord!.mainEmotion),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildInfoCard(
                              '상담 시간',
                              _selectedRecord!.duration,
                              Colors.orange[50]!,
                              Colors.orange[200]!,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 상담 요약
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border.all(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '상담 요약',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _selectedRecord!.summary,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 감정 점수
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            border: Border.all(color: Colors.blue[200]!),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '감정 점수',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: _selectedRecord!.emotionScore / 100,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blue[500],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '${_selectedRecord!.emotionScore}점',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _getScoreColor(_selectedRecord!.emotionScore),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _getScoreMessage(_selectedRecord!.emotionScore),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 목록 뷰
    final avgScore = _consultationRecords.fold<int>(
          0,
          (sum, record) => sum + record.emotionScore,
        ) ~/
        _consultationRecords.length;
    final totalMinutes = _consultationRecords.fold<int>(
      0,
      (sum, record) => sum + int.parse(record.duration.replaceAll('분', '')),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.blue[50]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 헤더
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: _goBack,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          foregroundColor: Colors.grey[700],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '← 뒤로가기',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '이전 상담 기록',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '총 ${_consultationRecords.length}회의 상담 기록',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // 상담 기록 목록
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _consultationRecords.length,
                  itemBuilder: (context, index) {
                    final record = _consultationRecords[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedRecord = record;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[200]!),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      record.date,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getEmotionColor(record.mainEmotion),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        record.mainEmotion,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _getEmotionTextColor(record.mainEmotion),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      record.time,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      record.duration,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      '${record.emotionScore}점',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _getScoreColor(record.emotionScore),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  record.summary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 통계 요약
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${_consultationRecords.length}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '총 상담 횟수',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '$avgScore',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '평균 점수',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '$totalMinutes분',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '총 상담 시간',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
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

  Widget _buildInfoCard(String label, String value, Color bgColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
