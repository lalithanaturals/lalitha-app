import 'package:pocketbase/pocketbase.dart';

/// Staff PIN login against the custom `/api/staff-login` route (see
/// lalitha-backend's pb_hooks/main.pb.js) — every other collection requires
/// an authenticated user, so this has to succeed before the app can show
/// anything. The route returns the same {token, record} shape as
/// authWithPassword, so [RecordAuth.fromJson] parses it directly.
class AuthRepository {
  AuthRepository(this._pb);

  final PocketBase _pb;

  bool get isLoggedIn => _pb.authStore.isValid;

  String? get loggedInStaffId => _pb.authStore.record?.data['staff'] as String?;

  Future<void> loginWithPin(String staffId, String pin) async {
    final json = await _pb.send<Map<String, dynamic>>(
      '/api/staff-login',
      method: 'POST',
      body: {'staff_id': staffId, 'pin': pin},
    );
    final auth = RecordAuth.fromJson(json);
    _pb.authStore.save(auth.token, auth.record);
  }

  void logout() => _pb.authStore.clear();
}
