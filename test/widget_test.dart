import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qr_code_app/models/qr_code.dart';
import 'package:qr_code_app/screens/qr_screen.dart';

void main() {
  test('QrCode correctly parses API response', () {
    final json = {
      'id': 1,
      'text': 'https://example.com',
      'createdAt': '2026-09-23T01:30:00.000Z',
    };

    final qrCode = QrCode.fromJson(json);

    expect(qrCode.id, 1);
    expect(qrCode.text, 'https://example.com');
    expect(
      qrCode.createdAt,
      DateTime.parse('2026-09-23T01:30:00.000Z'),
    );
  });

  testWidgets('QR screen displays generated content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: QrScreen(
          text: 'https://example.com',
          onToggleTheme: () {},
        ),
      ),
    );

    expect(find.text('QR Code'), findsOneWidget);
    expect(find.text('https://example.com'), findsOneWidget);
  });
}