import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/exchange_record.dart';
import 'package:lalitha_app/features/scrap/receipt/receipt_screen.dart';

import '../../support/localized_test_app.dart';

void main() {
  testWidgets('shows customer info, display id, and status', (tester) async {
    const record = ExchangeRecord(
      id: 'rec1',
      displayId: 'EX-1',
      branchId: 'branch1',
      customerName: 'Ravi Kumar',
      customerPhone: '9999900000',
      status: ExchangeStatus.order,
      alWeights: [10],
      alHandles: 1,
    );
    await tester.pumpWidget(localizedTestApp(home: const ReceiptScreen(record: record)));
    await tester.pumpAndSettle();

    expect(find.text('ID: EX-1'), findsOneWidget);
    expect(find.text('Customer: Ravi Kumar'), findsOneWidget);
    expect(find.text('9999900000'), findsOneWidget);
    expect(find.text('Order'), findsOneWidget);
  });

  testWidgets('only shows a material section for materials with entered weights', (tester) async {
    const record = ExchangeRecord(
      branchId: 'branch1',
      alWeights: [10],
      stWeights: [],
    );
    await tester.pumpWidget(localizedTestApp(home: const ReceiptScreen(record: record)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('receiptMaterialSection_al')), findsOneWidget);
    expect(find.byKey(const Key('receiptMaterialSection_st')), findsNothing);
  });

  testWidgets('shows correct per-material cost and grand total', (tester) async {
    const record = ExchangeRecord(
      branchId: 'branch1',
      alWeights: [10],
      alHandles: 0,
      stWeights: [20],
      stHandles: 0,
    );
    await tester.pumpWidget(localizedTestApp(home: const ReceiptScreen(record: record)));
    await tester.pumpAndSettle();

    // al: 10kg * ₹150 = 1500; st: 20kg * ₹50 = 1000; grand total 2500
    final alCost = tester.widget<Text>(find.byKey(const Key('receiptMaterialCost_al')));
    expect(alCost.data, contains('1500.00'));
    final stCost = tester.widget<Text>(find.byKey(const Key('receiptMaterialCost_st')));
    expect(stCost.data, contains('1000.00'));
    expect(find.text('Grand Total: ₹2500.00'), findsOneWidget);
  });
}
