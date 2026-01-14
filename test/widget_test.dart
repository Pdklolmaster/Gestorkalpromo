// Teste básico do aplicativo Gestor Financeiro

import 'package:flutter_test/flutter_test.dart';

import 'package:kaloferta_gestor/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(FinanceApp());

    // Verify the app title is shown
    expect(find.text('Gestor 50/30/20'), findsOneWidget);
  });
}
