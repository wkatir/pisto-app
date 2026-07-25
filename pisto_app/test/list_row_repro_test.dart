import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pisto_app/config/app_theme.dart';
import 'package:pisto_app/shared/widgets/list_row.dart';

void main() {
  testWidgets('taps across the row all fire', (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: FinancialListRow(
          title: 'FAC-001',
          subtitleParts: const ['01 jul 2026'],
          trailingValue: '\$100.00',
          onTap: () => taps++,
        ),
      ),
    ));
    final box = tester.getRect(find.byType(FinancialListRow));
    await tester.tapAt(Offset(box.left + 10, box.center.dy));
    await tester.tapAt(box.center);
    await tester.tapAt(Offset(box.right - 10, box.center.dy));
    await tester.pump();
    debugPrint('taps fired: $taps');

    final semantics = tester.getSemantics(find.text('\$100.00'));
    debugPrint('semantics on money text: $semantics');
  });
}
