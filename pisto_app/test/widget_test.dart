import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pisto_app/main.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PistoApp()));
    await tester.pumpAndSettle();

    expect(find.text('Pisto'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
