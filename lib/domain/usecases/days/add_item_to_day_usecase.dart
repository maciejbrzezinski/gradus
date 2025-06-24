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
    int? index,
  }) {
    final List<String> newItemIds = List.from(day.itemIds);
    
    if (index != null && index >= 0 && index <= newItemIds.length) {
      // Insert at specific index
      newItemIds.insert(index, itemId);
    } else {
      // Append to end (default behavior)
      newItemIds.add(itemId);
    }
    
    final updatedDay = day.copyWith(itemIds: newItemIds);
    
    return _repository.updateDay(updatedDay).then((result) {
      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(unit),
      );
    });
  }
}
