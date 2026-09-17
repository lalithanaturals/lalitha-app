import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/staff.dart';
import '../../core/providers.dart';

/// Every active staff member, for the login screen's "pick your name"
/// picker. Fetchable while logged out — `staff.listRule` is public.
final activeStaffProvider = FutureProvider<List<Staff>>((ref) {
  return ref.watch(staffRepositoryProvider).listAllActive();
});
