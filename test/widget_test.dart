import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:rsvp_reader/providers/reader_provider.dart';
import 'package:rsvp_reader/screens/input_screen.dart';

void main() {
  testWidgets('InputScreen renders with header and text field', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ReaderProvider(),
        child: const MaterialApp(
          home: InputScreen(),
        ),
      ),
    );

    // Verify the app title renders
    expect(find.text('Grasp'), findsOneWidget);

    // Verify the subtitle renders
    expect(find.text('RSVP SPEED READER'), findsOneWidget);

    // Verify the text input hint is present
    expect(
      find.text('Paste any text here and start speed reading...'),
      findsOneWidget,
    );

    // Verify the file upload section is present
    expect(find.text('Upload a file'), findsOneWidget);
  });
}
