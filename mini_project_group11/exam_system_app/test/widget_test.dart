import 'package:flutter_test/flutter_test.dart';

import 'package:exam_system_app/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OnlineExamApp());
    expect(find.text('Online Exam Portal'), findsWidgets);
  });
}
