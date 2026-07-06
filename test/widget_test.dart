import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:heartsense/main.dart';
import 'package:heartsense/providers/assessment_provider.dart';

void main() {
  testWidgets('App loads Welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      HeartSenseApp(assessmentProvider: AssessmentProvider()),
    );

    expect(find.text('Start Assessment'), findsOneWidget);
  });
}