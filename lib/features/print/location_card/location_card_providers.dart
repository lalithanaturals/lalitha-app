import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/branch.dart';
import '../../../core/providers.dart';

final locationCardBranchesProvider = FutureProvider.autoDispose<List<Branch>>((ref) {
  return ref.watch(branchRepositoryProvider).listActive();
});
