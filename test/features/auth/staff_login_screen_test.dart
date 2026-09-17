import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/staff.dart';
import 'package:lalitha_app/core/providers.dart';
import 'package:lalitha_app/core/repositories/auth_repository.dart';
import 'package:lalitha_app/features/auth/login_providers.dart';
import 'package:lalitha_app/features/auth/staff_login_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/localized_test_app.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _staffList = [
  Staff(id: 'staff1', name: 'Admin', branchId: ''),
  Staff(id: 'staff2', name: 'Staff', branchId: 'branch1'),
];

Future<void> _pumpScreen(WidgetTester tester, {required AuthRepository repo}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        activeStaffProvider.overrideWith((ref) async => _staffList),
        authRepositoryProvider.overrideWithValue(repo),
      ],
      child: localizedTestApp(home: const StaffLoginScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectStaff(WidgetTester tester, String name) async {
  await tester.tap(find.byKey(const Key('loginStaffDropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(name).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows an error when submitting without selecting a staff member', (tester) async {
    final repo = _MockAuthRepository();
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('loginErrorText')), findsOneWidget);
    verifyNever(() => repo.loginWithPin(any(), any()));
  });

  testWidgets('successful login calls loginWithPin with the selected staff and PIN', (tester) async {
    final repo = _MockAuthRepository();
    when(() => repo.loginWithPin(any(), any())).thenAnswer((_) async {});
    await _pumpScreen(tester, repo: repo);

    await _selectStaff(tester, 'Admin');
    await tester.enterText(find.byKey(const Key('loginPinField')), '1234');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();

    verify(() => repo.loginWithPin('staff1', '1234')).called(1);
    expect(find.byKey(const Key('loginErrorText')), findsNothing);
  });

  testWidgets('shows an error message when the PIN is rejected', (tester) async {
    final repo = _MockAuthRepository();
    when(() => repo.loginWithPin(any(), any())).thenThrow(Exception('bad pin'));
    await _pumpScreen(tester, repo: repo);

    await _selectStaff(tester, 'Staff');
    await tester.enterText(find.byKey(const Key('loginPinField')), '0000');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('loginErrorText')), findsOneWidget);
  });
}
