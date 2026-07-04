import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:heartsense/main.dart';

void main() {
  testWidgets('App loads Welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const HeartSenseApp());

    expect(find.text('Start Assessment'), findsOneWidget);
  });
}