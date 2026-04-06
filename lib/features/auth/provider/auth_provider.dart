import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/features/auth/data/auth_repository.dart';

// Repository Provider
final authRepositoryProvider = Provider((ref) => AuthRepository());

// Auth Controller
class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository)
    : super(const AsyncValue.data(null));

  Future<void> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.register(
        name: name, 
        email: email, 
        password: password
      );
      state = AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try{
      await _authRepository.login(
        email: email, 
        password: password
      );
      state = AsyncValue.data(null);

    } catch (e, st) { 
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
  }
}

// StateNotifier Provider
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return AuthController(repo);
});



/*
Firebase auth logic
Firestore user storage
Riverpod state control
Login/Register methods
Auth state stream
*/

// Only performs actions (login/register/logout)
// Does NOT store user state