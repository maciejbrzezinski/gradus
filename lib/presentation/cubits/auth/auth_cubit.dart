import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../core/services/auth_service.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  StreamSubscription? _authStateSubscription;

  AuthCubit(this._authService) : super(const AuthState.initial()) {
    _listenToAuthChanges();
  }

  /// Sign in with email and password
  Future<void> signInWithEmailAndPassword({required String email, required String password}) async {
    emit(const AuthState.loading());
    try {
      await _authService.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  /// Create user with email and password
  Future<void> createUserWithEmailAndPassword({required String email, required String password}) async {
    emit(const AuthState.loading());
    try {
      await _authService.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    emit(const AuthState.loading());
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  /// Sign out
  Future<void> signOut() async {
    emit(const AuthState.loading());
    try {
      await _authService.signOut();
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

  /// Listen to Firebase auth state changes
  void _listenToAuthChanges() {
    _authStateSubscription = _authService.authStateChanges.listen((user) {
      if (user != null) {
        emit(const AuthState.authenticated());
      } else {
        emit(const AuthState.unauthenticated());
      }
    });
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
