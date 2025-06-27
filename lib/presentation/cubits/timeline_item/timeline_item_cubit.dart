import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../../domain/entities/timeline_item.dart';
import '../../../domain/usecases/timeline_items/get_timeline_item_usecase.dart';
import '../../../domain/usecases/timeline_items/watch_timeline_item_usecase.dart';
import '../../../domain/usecases/timeline_items/update_timeline_item_usecase.dart';
import '../../../domain/usecases/timeline_items/delete_timeline_item_usecase.dart';
import 'timeline_item_state.dart';

class TimelineItemCubit extends Cubit<TimelineItemState> {
  final String itemId;
  final GetTimelineItemUseCase _getTimelineItemUseCase;
  final WatchTimelineItemUseCase _watchTimelineItemUseCase;
  final UpdateTimelineItemUseCase _updateTimelineItemUseCase;
  final DeleteTimelineItemUseCase _deleteTimelineItemUseCase;

  StreamSubscription? _subscription;
  final Stream<TimelineItem>? _itemStream = Stream.empty(broadcast: true);

  TimelineItemCubit({
    required this.itemId,
    required GetTimelineItemUseCase getTimelineItemUseCase,
    required WatchTimelineItemUseCase watchTimelineItemUseCase,
    required UpdateTimelineItemUseCase updateTimelineItemUseCase,
    required DeleteTimelineItemUseCase deleteTimelineItemUseCase,
  }) : _getTimelineItemUseCase = getTimelineItemUseCase,
       _watchTimelineItemUseCase = watchTimelineItemUseCase,
       _updateTimelineItemUseCase = updateTimelineItemUseCase,
       _deleteTimelineItemUseCase = deleteTimelineItemUseCase,
       super(const TimelineItemState.loading()) {
    _initializeItem();
  }

  void _initializeItem() async {
    await _loadInitialItem();
    _startWatching();
  }

  Future<void> _loadInitialItem() async {
    try {
      final result = await _getTimelineItemUseCase(itemId);
      result.fold((failure) => emit(TimelineItemState.error(failure)), (item) => emit(TimelineItemState.loaded(item)));
    } catch (e) {
      emit(TimelineItemState.error(Failure.unknownFailure(message: e.toString())));
    }
  }

  void _startWatching() {
    _watchItem();
  }

  void _watchItem() {
    _subscription = _watchTimelineItemUseCase(itemId).listen((item) {
      emit(TimelineItemState.loaded(item));
    });
  }

  Future<void> updateItem(TimelineItem updatedItem) async {
    emit(TimelineItemState.loaded(updatedItem));
    final result = await _updateTimelineItemUseCase(updatedItem);
    result.fold(
      (failure) => emit(TimelineItemState.error(failure)),
      (_) {}, // Item will be automatically updated through stream
    );
  }

  Future<void> deleteItem() async {
    final result = await _deleteTimelineItemUseCase(itemId);
    result.fold(
      (failure) => emit(TimelineItemState.error(failure)),
      (_) {}, // Item will be automatically removed through stream
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
