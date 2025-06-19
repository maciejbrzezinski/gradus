import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
abstract class Failure with _$Failure {
  const factory Failure.serverFailure({
    required String message,
  }) = ServerFailure;

  const factory Failure.cacheFailure({
    required String message,
  }) = CacheFailure;

  const factory Failure.networkFailure({
    required String message,
  }) = NetworkFailure;

  const factory Failure.authFailure({
    required String message,
  }) = AuthFailure;

  const factory Failure.validationFailure({
    required String message,
  }) = ValidationFailure;

  const factory Failure.unknownFailure({
    required String message,
  }) = UnknownFailure;
}