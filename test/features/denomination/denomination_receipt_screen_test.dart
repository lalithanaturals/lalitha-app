import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/audit_register.dart';
import 'package:lalitha_app/features/denomination/receipt/denomination_receipt_screen.dart';

import '../../support/localized_test_app.dart';

void main() {
  testWidgets('shows date, status, denomination breakdown, and totals', (tester) async {
    final register = AuditRegister(
      date: DateTime.utc(2026, 9, 17),
      branchId: 'branch1',
      openingBalance: 4851,
      closingBalance: 1200,
      denominationCounts: const {500: 4, 100: 2},
      cashTotal: 2200,
      status: AuditRegisterStatus.committed,
    );
    await tester.pumpWidget(localizedTestApp(
      home: DenominationReceiptScreen(register: register, lineItems: const []),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Date: 2026-09-17'), findsOneWidget);
    expect(find.text('Committed'), findsOneWidget);
    expect(find.text('₹500 × 4'), findsOneWidget);
    expect(find.text('₹100 × 2'), findsOneWidget);
    expect(find.text('Cash Total: ₹2200.00'), findsOneWidget);
    expect(find.text('Closing Balance: ₹1200.00'), findsOneWidget);
  });

  testWidgets('omits denominations with a zero count', (tester) async {
    final register = AuditRegister(
      date: DateTime.utc(2026, 9, 17),
      branchId: 'branch1',
      denominationCounts: const {500: 2, 100: 0},
    );
    await tester.pumpWidget(localizedTestApp(
      home: DenominationReceiptScreen(register: register, lineItems: const []),
    ));
    await tester.pumpAndSettle();

    expect(find.text('₹500 × 2'), findsOneWidget);
    expect(find.textContaining('₹100 ×'), findsNothing);
  });

  testWidgets('groups line items by category', (tester) async {
    final register = AuditRegister(date: DateTime.utc(2026, 9, 17), branchId: 'branch1');
    const items = [
      AuditLineItem(category: AuditLineCategory.expense, name: 'Electricity', amount: 450),
      AuditLineItem(category: AuditLineCategory.ownerBill, name: 'Rent', amount: 5000),
    ];
    await tester.pumpWidget(localizedTestApp(
      home: DenominationReceiptScreen(register: register, lineItems: items),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Electricity'), findsOneWidget);
    expect(find.text('Owner Bills'), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
    expect(find.text('Vendor Bills'), findsNothing);
  });
}
