import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';


@freezed
class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState.initial() = _Initial;

  const factory AuthState.loading() = _Loading;

  const factory AuthState.authenticated() = _Authenticated;

  const factory AuthState.unauthenticated() = _Unauthenticated;

  const factory AuthState.error(String message) = _Error;

  bool get isLoading => this is _Loading;

  bool get isAuthenticated => this is _Authenticated;
}
