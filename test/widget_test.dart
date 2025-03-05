import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic widget test', (WidgetTester tester) async {
    // Costruisci un widget MaterialApp semplice per il test
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Outdoor Navigation'),
          ),
          body: const Center(
            child: Text('Test App'),
          ),
        ),
      ),
    );
    
    // Verifica che ci sia il testo corretto
    expect(find.text('Outdoor Navigation'), findsOneWidget);
    expect(find.text('Test App'), findsOneWidget);
  });
}