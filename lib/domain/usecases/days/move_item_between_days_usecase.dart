import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failure.dart';
import '../../entities/day.dart';
import '../../repositories/days_repository.dart';

@injectable
class MoveItemBetweenDaysUseCase {
  final DaysRepository _repository;

  MoveItemBetweenDaysUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String itemId,
    required Day fromDay,
    required Day toDay,
    required int toIndex,
  }) {
    return _repository.moveItemBetweenDays(
      itemId: itemId,
      fromDay: fromDay,
      toDay: toDay,
      toIndex: toIndex,
    );
  }
}
