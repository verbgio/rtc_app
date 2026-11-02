import 'package:flutter_test/flutter_test.dart';
import 'package:rtc_app/main.dart';

void main() {
  testWidgets('App si avvia correttamente', (WidgetTester tester) async {
    await tester.pumpWidget(const RtcApp());
    // Verifica che la barra di navigazione sia presente
    expect(find.text('Live'), findsOneWidget);
  });
}