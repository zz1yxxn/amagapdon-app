import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:samo/main.dart' as app;

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Figma to Flutter 앱을 빌드하고 프레임을 트리거합니다.
    app.main();
    await tester.pumpAndSettle();

    // 앱이 정상적으로 초기화되었는지 확인합니다.
    expect(find.text('Figma to Flutter initialized!'), findsOneWidget);
  });
}