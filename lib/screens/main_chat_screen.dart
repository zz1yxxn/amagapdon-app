import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Message {
  final String id;
  final String text;
  final String sender; // 'user' or 'ai'
  final DateTime timestamp;
  final String type; // 'text' or 'image'
  final String? imageUrl;

  Message({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    required this.type,
    this.imageUrl,
  });
}

class MainChat extends StatefulWidget {
  final Function(Map<String, dynamic>) onConsultationEnd;

  const MainChat({
    Key? key,
    required this.onConsultationEnd,
  }) : super(key: key);

  @override
  State<MainChat> createState() => _MainChatState();
}

class _MainChatState extends State<MainChat> {
  // API 엔드포인트
  static const String CONTINUE_ENDPOINT = 
      'https://m83p0ic48b.execute-api.ap-northeast-2.amazonaws.com/prod/continue-chat';
  static const String ANALYZE_ENDPOINT = 
      'https://m83p0ic48b.execute-api.ap-northeast-2.amazonaws.com/prod/emotion';

  final List<Message> _messages = [
    Message(
      id: '1',
      text: '안녕하세요! AI 상담가입니다. 오늘 기분은 어떠신가요? 사진을 업로드하시거나 직접 말씀해 주세요.',
      sender: 'ai',
      timestamp: DateTime.now(),
      type: 'text',
    ),
  ];

  // chat_history: OpenAI API 형식
  final List<Map<String, dynamic>> _chatHistory = [
    {
      'role': 'assistant',
      'content': '안녕하세요! AI 상담가입니다. 오늘 기분은 어떠신가요? 사진을 업로드하시거나 직접 말씀해 주세요.',
    },
  ];

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isVoiceMode = false;
  bool _isRecording = false;
  bool _showImageUpload = false;
  bool _isLoading = false; // API 호출 중 로딩 상태

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // API 호출: 대화 이어가기
  Future<String> _callContinueChat(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(CONTINUE_ENDPOINT),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_message': userMessage,
          'chat_history': _chatHistory,
          'model': 'gpt-4o-mini',
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['ai_reply'] ?? '응답을 받지 못했습니다.';
      } else {
        print('API Error: ${response.statusCode}');
        return '죄송합니다. 잠시 후 다시 시도해주세요.';
      }
    } catch (e) {
      print('Network Error: $e');
      return '네트워크 오류가 발생했습니다.';
    }
  }

// API 호출: 감정 분석
Future<Map<String, dynamic>> _callEmotionAnalysis() async {
  try {
    final response = await http.post(
      Uri.parse(ANALYZE_ENDPOINT),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'chat_history': _chatHistory,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      
      var emotionResult = data['emotion_result'];
      
      // 👇 여기부터 수정!
      
      // 1단계: 문자열이면 파싱
      if (emotionResult is String) {
        emotionResult = emotionResult
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        
        try {
          emotionResult = jsonDecode(emotionResult);
        } catch (e) {
          print('JSON 파싱 실패: $e');
          return _getMockAnalysisData();
        }
      }

      // 2단계: Map이 아니면 에러
      if (emotionResult is! Map) {
        print('emotionResult가 Map이 아닙니다: $emotionResult');
        return _getMockAnalysisData();
      }

      // 🔥 3단계: raw_text 키가 있으면 한번 더 파싱!
      if (emotionResult.containsKey('raw_text')) {
        var rawText = emotionResult['raw_text'];
        
        if (rawText is String) {
          rawText = rawText
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();
          
          try {
            emotionResult = jsonDecode(rawText);
          } catch (e) {
            print('raw_text JSON 파싱 실패: $e');
            return _getMockAnalysisData();
          }
        }
      }

      // 4단계: 다시 한번 Map 확인
      if (emotionResult is! Map) {
        print('최종 emotionResult가 Map이 아닙니다: $emotionResult');
        return _getMockAnalysisData();
      }

      // 5단계: 모든 값을 int로 변환
      final Map<String, dynamic> emotions = {};
      emotionResult.forEach((key, value) {
        // raw_text 같은 이상한 키는 제외
        if (key == 'raw_text') return;
        
        if (value is int) {
          emotions[key] = value;
        } else if (value is double) {
          emotions[key] = value.toInt();
        } else if (value is String) {
          try {
            emotions[key] = int.parse(value);
          } catch (e) {
            emotions[key] = 0;
          }
        } else {
          emotions[key] = 0;
        }
      });

      // 감정 데이터가 비어있으면 Mock 데이터
      if (emotions.isEmpty) {
        print('감정 데이터가 비어있습니다');
        return _getMockAnalysisData();
      }

      return {
        'emotions': emotions,
        'summary': '오늘 상담에서는 다양한 감정을 표현하셨습니다.',
        'recommendations': '규칙적인 운동과 충분한 휴식을 권장드리며, 가족이나 친구들과의 소통을 늘려보시기 바랍니다.',
        'messages': _messages,
      };
    } else {
      print('Emotion API Error: ${response.statusCode}');
      return _getMockAnalysisData();
    }
  } catch (e) {
    print('Emotion Analysis Error: $e');
    return _getMockAnalysisData();
  }
}

  // 백업용 Mock 데이터
  Map<String, dynamic> _getMockAnalysisData() {
    return {
      'emotions': {
        '기쁨': 15,
        '슬픔': 35,
        '분노': 10,
        '두려움': 20,
        '놀람': 8,
        '평온': 12,
      },
      'summary': '오늘 상담에서는 주로 슬픔과 불안한 감정을 표현하셨습니다.',
      'recommendations': '규칙적인 운동과 충분한 휴식을 권장드리며, 가족이나 친구들과의 소통을 늘려보시기 바랍니다.',
      'messages': _messages,
    };
  }

  void _handleSendMessage() async {
    if (_textController.text.trim().isEmpty || _isLoading) return;

    final userText = _textController.text.trim();
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: userText,
      sender: 'user',
      timestamp: DateTime.now(),
      type: 'text',
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });
    _textController.clear();

    // chat_history에 사용자 메시지 추가
    _chatHistory.add({'role': 'user', 'content': userText});

    // 스크롤 아래로
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // API 호출
    final aiReply = await _callContinueChat(userText);

    // AI 응답 메시지 추가
    final aiMessage = Message(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      text: aiReply,
      sender: 'ai',
      timestamp: DateTime.now(),
      type: 'text',
    );

    // chat_history에 AI 응답 추가
    _chatHistory.add({'role': 'assistant', 'content': aiReply});

    setState(() {
      _messages.add(aiMessage);
      _isLoading = false;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleImageUpload(String imageUrl) {
    final imageMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '사진을 업로드했습니다.',
      sender: 'user',
      timestamp: DateTime.now(),
      type: 'image',
      imageUrl: imageUrl,
    );

    setState(() {
      _messages.add(imageMessage);
      _showImageUpload = false;
    });

    // AI 응답
    Future.delayed(const Duration(milliseconds: 1500), () {
      final aiResponse = Message(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: '사진을 잘 보았습니다. 이 사진과 관련해서 어떤 이야기를 나누고 싶으신가요?',
        sender: 'ai',
        timestamp: DateTime.now(),
        type: 'text',
      );

      setState(() {
        _messages.add(aiResponse);
      });
    });
  }

  void _handleEndConsultation() async {
    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // 감정 분석 API 호출
    final analysisData = await _callEmotionAnalysis();

    // 로딩 닫기
    if (mounted) {
      Navigator.of(context).pop();
      widget.onConsultationEnd(analysisData);
    }
  }

  Widget _buildMessageBubble(Message message) {
    final isUser = message.sender == 'user';
    final timeString = '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[500] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isUser ? null : Border.all(color: Colors.grey[300]!),
                boxShadow: isUser
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.type == 'image' && message.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        message.imageUrl!,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (message.type == 'image' && message.imageUrl != null)
                    const SizedBox(height: 12),
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
              child: Text(
                timeString,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Text(
                    'AI 회상 상담',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '오래 기억하고 싶은 순간을 알려주세요.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // 채팅 영역
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isLoading && index == _messages.length) {
                      // 로딩 인디케이터
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: const SizedBox(
                            width: 40,
                            height: 20,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                      );
                    }
                    return _buildMessageBubble(_messages[index]);
                  },
                ),
              ),
            ),

            // 음성 모드 컨트롤
            if (_isVoiceMode)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          _isRecording ? '녹음 중입니다...' : '음성 상담 준비',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isRecording = !_isRecording;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _isRecording ? Colors.red[500] : Colors.blue[500],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _isRecording ? '일시정지' : '시작',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isVoiceMode = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[500],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                '종료',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 이미지 업로드
            if (_showImageUpload)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text('이미지 업로드 기능'),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // 실제 구현에서는 image_picker 패키지 사용
                                _handleImageUpload('https://example.com/image.jpg');
                              },
                              child: const Text('이미지 선택'),
                            ),
                            const SizedBox(width: 16),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showImageUpload = false;
                                });
                              },
                              child: const Text('취소'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 하단 컨트롤 영역
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 사진 업로드 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showImageUpload = !_showImageUpload;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[500],
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '사진 올리기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 상담 종료 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleEndConsultation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '상담종료',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 입력 모드 선택
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isVoiceMode = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isVoiceMode
                                ? Colors.blue[600]
                                : Colors.grey[100],
                            foregroundColor: _isVoiceMode
                                ? Colors.white
                                : Colors.grey[700],
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '음성 상담',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isVoiceMode = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !_isVoiceMode
                                ? Colors.blue[600]
                                : Colors.grey[100],
                            foregroundColor: !_isVoiceMode
                                ? Colors.white
                                : Colors.grey[700],
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '채팅 상담',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 텍스트 입력 영역
                  if (!_isVoiceMode)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              enabled: !_isLoading,
                              decoration: InputDecoration(
                                hintText: '메시지를 입력하세요',
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                              onSubmitted: (_) => _handleSendMessage(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleSendMessage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              '전송',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
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
    );
  }
}