import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pisto_app/config/app_theme.dart';
import 'package:pisto_app/features/sales/models/lookups.dart';
import 'package:pisto_app/features/sales/providers/sales_providers.dart';
import 'package:pisto_app/features/sales/screens/create_sale_screen.dart';

void main() {
  final data = SaleFormData(
    products: const [
      ProductRef(id: 'p1', name: 'Producto uno', sku: 'SKU1', salePrice: '10.00'),
      ProductRef(id: 'p2', name: 'Producto dos', salePrice: '5.50'),
    ],
    warehouses: const [WarehouseRef(id: 'w1', name: 'Central')],
    customers: const [],
    paymentMethods: const [PaymentMethod(id: 'm1', name: 'Efectivo')],
    documentTypes: const [DocumentType(id: 'd1', name: 'Factura', code: 'FAC')],
    taxes: const [Tax(id: 't1', name: 'IVA', rate: '13.00')],
  );

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [saleFormDataProvider.overrideWith((ref) async => data)],
        child: MaterialApp(theme: AppTheme.light, home: const CreateSaleScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Enter on still-focused button while picker open stacks dialogs',
      (tester) async {
    await pump(tester);
    // Focus + activate via keyboard like a web user tabbing/clicking
    final button = find.widgetWithText(OutlinedButton, 'Agregar');
    Focus.of(tester.element(find.text('Agregar'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Seleccionar producto'), findsOneWidget);

    // Dialog is open; background button may still have focus -> Enter again
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    debugPrint('pickers open: ${find.text('Seleccionar producto').evaluate().length}');

    // Escape on barrierDismissible:false dialog
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    debugPrint('pickers after escape: ${find.text('Seleccionar producto').evaluate().length}');
    expect(button, findsOneWidget);
  });

  testWidgets('double tap on add button stacks two pickers', (tester) async {
    await pump(tester);
    // Two taps land before the first dialog's barrier is built (web double-click)
    await tester.tap(find.widgetWithText(OutlinedButton, 'Agregar'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Agregar'));
    await tester.pumpAndSettle();
    debugPrint('pickers open after double activation: ${find.text('Seleccionar producto').evaluate().length}');
  });
}
