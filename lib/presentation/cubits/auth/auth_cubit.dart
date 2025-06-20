import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/services/auth_service.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(const AuthState.initial());

  /// Sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    emit(const AuthState.loading());
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(const AuthState.authenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  /// Create user with email and password
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    emit(const AuthState.loading());
    try {
      await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(const AuthState.authenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    emit(const AuthState.loading());
    try {
      await _authService.signInWithGoogle();
      emit(const AuthState.authenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  /// Sign out
  Future<void> signOut() async {
    emit(const AuthState.loading());
    try {
      await _authService.signOut();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  /// Check authentication status
  void checkAuthStatus() {
    if (_authService.isAuthenticated) {
      emit(const AuthState.authenticated());
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  /// Clear error state
  void clearError() {
    emit(const AuthState.initial());
  }
}
