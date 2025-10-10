import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class Message {
  final String id;
  final String text;
  final String sender; // 'user' or 'ai'
  final DateTime timestamp;
  final String type; // 'text' or 'image'
  final String? imageUrl;
  final File? imageFile; // 로컬 이미지 파일

  Message({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    required this.type,
    this.imageUrl,
    this.imageFile,
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
  bool _isLoading = false;
  
  // 이미지 선택기
  final ImagePicker _picker = ImagePicker();
  
  // 음성 인식
  late stt.SpeechToText _speech;
  bool _speechAvailable = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  // 음성 인식 초기화
  Future<void> _initSpeech() async {
    _speech = stt.SpeechToText();
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isRecording = false;
          });
        }
      },
      onError: (error) {
        print('Speech error: $error');
        setState(() {
          _isRecording = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('음성 인식 오류: $error')),
        );
      },
    );
    
    setState(() {
      _speechAvailable = available;
    });
  }

  // 음성 녹음 시작
  Future<void> _startListening() async {
    // 마이크 권한 확인
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('마이크 권한이 필요합니다')),
      );
      return;
    }

    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('음성 인식을 사용할 수 없습니다')),
      );
      return;
    }

    setState(() {
      _recognizedText = '';
      _isRecording = true;
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
          _textController.text = _recognizedText;
        });
      },
      localeId: 'ko_KR', // 한국어 설정
    );
  }

  // 음성 녹음 중지
  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isRecording = false;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _speech.cancel();
    super.dispose();
  }

  // 이미지 선택 (갤러리 또는 카메라)
  Future<void> _pickImage(ImageSource source) async {
    try {
      // 권한 확인
      if (source == ImageSource.camera) {
        var status = await Permission.camera.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('카메라 권한이 필요합니다')),
          );
          return;
        }
      } else {
        var status = await Permission.photos.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('사진 접근 권한이 필요합니다')),
          );
          return;
        }
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        File imageFile = File(image.path);
        _handleImageUpload(imageFile);
      }
    } catch (e) {
      print('Image pick error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지를 선택할 수 없습니다: $e')),
      );
    }
  }

  // 이미지 선택 다이얼로그 (화면 중앙)
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '사진 선택',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              // 갤러리 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[500],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                  label: const Text(
                    '갤러리에서 선택',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 카메라 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[500],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: const Text(
                    '카메라로 촬영',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 취소 버튼
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    '취소',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 이미지를 base64로 인코딩
  Future<String> _encodeImageToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  // API 호출: 대화 이어가기
  Future<String> _callContinueChat(String userMessage, {String? imageBase64}) async {
    try {
      Map<String, dynamic> requestBody = {
        'user_message': userMessage,
        'chat_history': _chatHistory,
        'model': 'gpt-4o-mini',
        'temperature': 0.7,
      };

      // 이미지가 있으면 추가
      if (imageBase64 != null) {
        requestBody['image'] = imageBase64;
      }

      final response = await http.post(
        Uri.parse(CONTINUE_ENDPOINT),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
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

        // 3단계: raw_text 키가 있으면 한번 더 파싱!
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

  void _handleImageUpload(File imageFile) async {
    setState(() {
      _showImageUpload = false;
      _isLoading = true;
    });

    // 이미지 메시지 추가
    final imageMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '사진을 업로드했습니다.',
      sender: 'user',
      timestamp: DateTime.now(),
      type: 'image',
      imageFile: imageFile,
    );

    setState(() {
      _messages.add(imageMessage);
    });

    // 스크롤 아래로
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // 이미지를 base64로 인코딩
    String imageBase64 = await _encodeImageToBase64(imageFile);

    // chat_history에 이미지 메시지 추가
    _chatHistory.add({
      'role': 'user',
      'content': '사진을 공유했습니다.',
    });

    // API 호출 (이미지 포함)
    final aiReply = await _callContinueChat(
      '사진을 보았습니다. 이 사진과 관련해서 어떤 이야기를 나누고 싶으신가요?',
      imageBase64: imageBase64,
    );

    // AI 응답 추가
    final aiResponse = Message(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      text: aiReply,
      sender: 'ai',
      timestamp: DateTime.now(),
      type: 'text',
    );

    _chatHistory.add({'role': 'assistant', 'content': aiReply});

    setState(() {
      _messages.add(aiResponse);
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

  void _handleEndConsultation() async {
    // 로딩 표시 (화면 정중앙)
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
                  if (message.type == 'image' && message.imageFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        message.imageFile!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (message.type == 'image' && message.imageFile != null)
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
      resizeToAvoidBottomInset: true, // 키보드 대응
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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

            // 음성 녹음 중 표시
            if (_isRecording)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _recognizedText.isEmpty ? '듣고 있습니다...' : _recognizedText,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 하단 컨트롤 영역 (3/4 크기)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 사진 업로드 & 상담 종료 버튼 (3/4 크기)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _showImageSourceDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[500],
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.photo_camera, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                '사진',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleEndConsultation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '상담종료',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // 텍스트 입력 영역 + 마이크 버튼 (3/4 크기)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          enabled: !_isLoading,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: '메시지 입력',
                            hintStyle: const TextStyle(fontSize: 13),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _handleSendMessage(),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // 마이크 버튼 (3/4 크기)
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_isRecording) {
                                    _stopListening();
                                  } else {
                                    _startListening();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isRecording ? Colors.red[500] : Colors.orange[500],
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // 전송 버튼 (3/4 크기)
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSendMessage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
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