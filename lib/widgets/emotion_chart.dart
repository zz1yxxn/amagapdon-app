import 'package:flutter/material.dart';

class EmotionChart extends StatelessWidget {
  final Map<String, int> emotions;

  const EmotionChart({
    super.key,
    required this.emotions,
  });

  Color _getEmotionColor(String key) {
    switch (key) {
      case 'joy':
      case '기쁨':
        return Colors.yellow[600]!;
      case '행복':
      case 'happiness':
        return Colors.orange[400]!;
      case 'sadness':
      case '슬픔':
        return Colors.blue[400]!;
      case 'anger':
      case '분노':
        return Colors.red[400]!;
      case 'fear':
      case '두려움':
      case '불안':
      case '걱정':
        return Colors.purple[400]!;
      case 'surprise':
      case '놀람':
        return Colors.green[400]!;
      case 'neutral':
      case '중립':
      case '평온':
        return Colors.grey[400]!;
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
      default:
        return Colors.grey[400]!;
    }
  }

  String _getEmotionLabel(String key) {
    switch (key) {
      case 'joy':
        return '기쁨';
      case 'sadness':
        return '슬픔';
      case 'anger':
        return '분노';
      case 'fear':
        return '두려움';
      case 'surprise':
        return '놀람';
      case 'neutral':
        return '평온';
      // 한글은 그대로 반환
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 감정 데이터를 리스트로 변환하고 정렬
    final emotionList = emotions.entries.map((entry) {
      return {
        'key': entry.key,
        'label': _getEmotionLabel(entry.key),
        'value': entry.value,
        'color': _getEmotionColor(entry.key),
      };
    }).toList()
      ..sort((a, b) => (b['value'] as int).compareTo(a['value'] as int));

    final maxEmotion = emotionList.first;

    return Column(
      children: [
        // 감정 막대 그래프
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                '감정 분포',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 24),
              
              // 각 감정별 막대 그래프
              ...emotionList.map((emotion) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            emotion['label'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '${emotion['value']}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (emotion['value'] as int) / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: emotion['color'] as Color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 가장 많이 표현된 감정 하이라이트
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue[50]!, Colors.blue[100]!],
            ),
            border: Border.all(color: Colors.blue[200]!),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                '주요 감정',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: maxEmotion['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        maxEmotion['label'] as String,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${maxEmotion['value']}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '가장 많이 표현된 감정',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}