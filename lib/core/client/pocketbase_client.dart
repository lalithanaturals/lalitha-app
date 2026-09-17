import 'package:pocketbase/pocketbase.dart';

/// Central place that owns the single [PocketBase] client instance used
/// across the whole app. Kept separate from Riverpod providers so it can be
/// constructed directly in tests without pulling in the widget tree.
class AppPocketBaseClient {
  AppPocketBaseClient(this.baseUrl, {PocketBase? client})
      : pb = client ?? PocketBase(baseUrl);

  /// e.g. `http://printmanager.local:8090` on the shop LAN, or the cloud
  /// deployment's URL — see PROJECT_PLAN.md in lalitha-api for the
  /// hosting options.
  final String baseUrl;

  final PocketBase pb;

  bool get isAuthenticated => pb.authStore.isValid;

  String? get currentUserId => pb.authStore.record?.id;

  Future<RecordAuth> loginWithPassword(String email, String password) {
    return pb.collection('users').authWithPassword(email, password);
  }

  void logout() => pb.authStore.clear();
}
