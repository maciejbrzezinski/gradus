import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failure.dart';
import '../../entities/day.dart';
import '../../repositories/days_repository.dart';

@injectable
class AddItemToDayUseCase {
  final DaysRepository _repository;

  AddItemToDayUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String itemId,
    required Day day,
  }) {
    final updatedDay = day.copyWith(
      itemIds: [...day.itemIds, itemId],
    );
    
    return _repository.updateDay(updatedDay).then((result) {
      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(unit),
      );
    });
  }
}
