import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  String _error = '';
  bool _success = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String value) {
    // 숫자만 추출
    final numbers = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // 010-1234-5678 형식으로 자동 포맷팅
    if (numbers.length <= 3) {
      return numbers;
    } else if (numbers.length <= 7) {
      return '${numbers.substring(0, 3)}-${numbers.substring(3)}';
    } else if (numbers.length <= 11) {  // 👈 이 부분 수정!
      return '${numbers.substring(0, 3)}-${numbers.substring(3, 7)}-${numbers.substring(7)}';
    } else {
      // 11자리 넘으면 11자리까지만
      return '${numbers.substring(0, 3)}-${numbers.substring(3, 7)}-${numbers.substring(7, 11)}';
    }
  }
  void _handleSignup() {
    final phoneNumbers = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // 입력 검증
    if (_phoneController.text.trim().isEmpty) {
      setState(() {
        _error = '전화번호를 입력해주세요';
      });
      return;
    }
    if (phoneNumbers.length != 11) {
      setState(() {
        _error = '올바른 전화번호를 입력해주세요 (11자리)';
      });
      return;
    }
    if (_usernameController.text.trim().isEmpty) {
      setState(() {
        _error = '아이디를 입력해주세요';
      });
      return;
    }
    if (_usernameController.text.length < 4) {
      setState(() {
        _error = '아이디는 4자 이상이어야 합니다';
      });
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _error = '비밀번호를 입력해주세요';
      });
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() {
        _error = '비밀번호는 6자 이상이어야 합니다';
      });
      return;
    }
    if (_passwordController.text != _passwordConfirmController.text) {
      setState(() {
        _error = '비밀번호가 일치하지 않습니다';
      });
      return;
    }

    // 회원가입 성공
    setState(() {
      _error = '';
      _success = true;
    });

    // 2초 후 로그인 페이지로 이동
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 60,
                      color: Colors.green[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '회원가입 완료!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '로그인 화면으로 이동합니다',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
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
                ],
              ),
            ),
            
            // 스크롤 가능한 컨텐츠
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      children: [
                        // 타이틀
                        const SizedBox(height: 32),
                        Text(
                          '회원가입',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '정보를 입력하고 계정을 만드세요',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // 회원가입 폼
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 전화번호 입력
                              Text(
                                '전화번호',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(13),
                                ],
                                onChanged: (value) {
                                  final formatted = _formatPhoneNumber(value);
                                  if (formatted != value) {
                                    _phoneController.value = TextEditingValue(
                                      text: formatted,
                                      selection: TextSelection.collapsed(
                                        offset: formatted.length,
                                      ),
                                    );
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: '010-0000-0000',
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[200]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[200]!),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 24,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '* 하이픈(-) 없이 숫자만 입력하세요',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // 아이디 입력
                              Text(
                                '아이디',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  hintText: '아이디 (4자 이상)',
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[200]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[200]!),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 24,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 18),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // 비밀번호 입력
                              Text(
                                '비밀번호',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: '비밀번호 (6자 이상)',
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[200]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[200]!),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 24,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 18),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // 비밀번호 확인
                              Text(
                                '비밀번호 확인',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _passwordConfirmController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: '비밀번호를 다시 입력하세요',
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[200]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[200]!),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 24,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 18),
                                onSubmitted: (_) => _handleSignup(),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // 에러 메시지
                              if (_error.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    border: Border.all(color: Colors.red[200]!),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _error,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.red[600],
                                      ),
                                    ),
                                  ),
                                ),
                              
                              if (_error.isNotEmpty) const SizedBox(height: 24),
                              
                              // 회원가입 버튼
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: _handleSignup,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[600],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    '회원가입',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 안내 사항
                        Container(
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
                                '회원가입 안내',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '• 전화번호는 본인 확인용으로 사용됩니다',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  height: 1.8,
                                ),
                              ),
                              Text(
                                '• 아이디는 4자 이상이어야 합니다',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  height: 1.8,
                                ),
                              ),
                              Text(
                                '• 비밀번호는 6자 이상이어야 합니다',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  height: 1.8,
                                ),
                              ),
                              Text(
                                '• 입력하신 정보는 안전하게 보관됩니다',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  height: 1.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
