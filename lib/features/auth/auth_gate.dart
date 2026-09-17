import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../app_home_screen.dart';
import 'staff_login_screen.dart';

/// Root widget: shows [StaffLoginScreen] until PIN login succeeds, then
/// [AppHomeScreen]. Swaps automatically on login/logout since both drive
/// the same [authStateProvider] stream (see providers.dart).
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.when(
      data: (loggedIn) => loggedIn,
      loading: () => false,
      error: (_, _) => false,
    );
    return isLoggedIn ? const AppHomeScreen() : const StaffLoginScreen();
  }
}
