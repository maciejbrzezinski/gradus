// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:gradus/core/di/firebase_module.dart' as _i145;
import 'package:gradus/core/services/auth_service.dart' as _i91;
import 'package:gradus/core/services/editing/navigation_service.dart' as _i431;
import 'package:gradus/core/services/editing/text_input_service.dart' as _i583;
import 'package:gradus/core/services/editing/timeline_item_editing_controller.dart'
    as _i54;
import 'package:gradus/core/services/editing/type_selector_service.dart'
    as _i87;
import 'package:gradus/core/services/logger_service.dart' as _i327;
import 'package:gradus/core/services/optimistic_sync_service.dart' as _i136;
import 'package:gradus/data/datasources/days_datasource.dart' as _i861;
import 'package:gradus/data/datasources/projects_datasource.dart' as _i511;
import 'package:gradus/data/datasources/timeline_items_datasource.dart'
    as _i506;
import 'package:gradus/data/repositories/days_repository_impl.dart' as _i776;
import 'package:gradus/data/repositories/projects_repository_impl.dart'
    as _i720;
import 'package:gradus/data/repositories/timeline_items_repository_impl.dart'
    as _i277;
import 'package:gradus/domain/repositories/days_repository.dart' as _i755;
import 'package:gradus/domain/repositories/projects_repository.dart' as _i111;
import 'package:gradus/domain/repositories/timeline_items_repository.dart'
    as _i348;
import 'package:gradus/domain/usecases/days/add_item_to_day_usecase.dart'
    as _i468;
import 'package:gradus/domain/usecases/days/get_days_usecase.dart' as _i214;
import 'package:gradus/domain/usecases/days/move_item_between_days_usecase.dart'
    as _i913;
import 'package:gradus/domain/usecases/days/remove_item_from_day_usecase.dart'
    as _i811;
import 'package:gradus/domain/usecases/days/watch_days_usecase.dart' as _i956;
import 'package:gradus/domain/usecases/projects/get_project_by_id_usecase.dart'
    as _i654;
import 'package:gradus/domain/usecases/projects/get_projects_usecase.dart'
    as _i903;
import 'package:gradus/domain/usecases/projects/watch_projects_usecase.dart'
    as _i68;
import 'package:gradus/domain/usecases/timeline_items/create_timeline_item_usecase.dart'
    as _i939;
import 'package:gradus/domain/usecases/timeline_items/delete_timeline_item_usecase.dart'
    as _i431;
import 'package:gradus/domain/usecases/timeline_items/get_timeline_item_usecase.dart'
    as _i172;
import 'package:gradus/domain/usecases/timeline_items/update_timeline_item_usecase.dart'
    as _i1003;
import 'package:gradus/domain/usecases/timeline_items/watch_timeline_item_usecase.dart'
    as _i484;
import 'package:gradus/presentation/cubits/auth/auth_cubit.dart' as _i858;
import 'package:gradus/presentation/cubits/focus/focus_cubit.dart' as _i837;
import 'package:gradus/presentation/cubits/timeline/timeline_cubit.dart'
    as _i293;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final firebaseModule = _$FirebaseModule();
    gh.factory<_i837.FocusCubit>(() => _i837.FocusCubit());
    gh.factory<_i431.NavigationService>(() => _i431.NavigationService());
    gh.factory<_i583.TextInputService>(() => _i583.TextInputService());
    gh.factory<_i87.TypeSelectorService>(() => _i87.TypeSelectorService());
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(
      () => firebaseModule.firebaseFirestore,
    );
    gh.lazySingleton<_i116.GoogleSignIn>(() => firebaseModule.googleSignIn);
    gh.lazySingleton<_i327.LoggerService>(() => _i327.LoggerService());
    gh.factory<_i91.AuthService>(
      () => _i91.AuthService(gh<_i59.FirebaseAuth>(), gh<_i116.GoogleSignIn>()),
    );
    gh.factory<_i54.TimelineItemEditingController>(
      () => _i54.TimelineItemEditingController(
        gh<_i583.TextInputService>(),
        gh<_i87.TypeSelectorService>(),
        gh<_i431.NavigationService>(),
      ),
    );
    gh.factory<_i506.TimelineItemsDataSource>(
      () => _i506.TimelineItemsDataSource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i91.AuthService>(),
        gh<_i327.LoggerService>(),
      ),
    );
    gh.factory<_i861.DaysDataSource>(
      () => _i861.DaysDataSource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i91.AuthService>(),
        gh<_i327.LoggerService>(),
      ),
    );
    gh.factory<_i511.ProjectsDataSource>(
      () => _i511.ProjectsDataSource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i91.AuthService>(),
        gh<_i327.LoggerService>(),
      ),
    );
    gh.lazySingleton<_i111.ProjectsRepository>(
      () => _i720.ProjectsRepositoryImpl(gh<_i511.ProjectsDataSource>()),
    );
    gh.factory<_i654.GetProjectByIdUseCase>(
      () => _i654.GetProjectByIdUseCase(gh<_i111.ProjectsRepository>()),
    );
    gh.factory<_i903.GetProjectsUseCase>(
      () => _i903.GetProjectsUseCase(gh<_i111.ProjectsRepository>()),
    );
    gh.factory<_i68.WatchProjectsUseCase>(
      () => _i68.WatchProjectsUseCase(gh<_i111.ProjectsRepository>()),
    );
    gh.lazySingleton<_i348.TimelineItemsRepository>(
      () => _i277.TimelineItemsRepositoryImpl(
        gh<_i506.TimelineItemsDataSource>(),
      ),
    );
    gh.lazySingleton<_i755.DaysRepository>(
      () => _i776.DaysRepositoryImpl(gh<_i861.DaysDataSource>()),
    );
    gh.factory<_i468.AddItemToDayUseCase>(
      () => _i468.AddItemToDayUseCase(gh<_i755.DaysRepository>()),
    );
    gh.factory<_i913.MoveItemBetweenDaysUseCase>(
      () => _i913.MoveItemBetweenDaysUseCase(gh<_i755.DaysRepository>()),
    );
    gh.factory<_i811.RemoveItemFromDayUseCase>(
      () => _i811.RemoveItemFromDayUseCase(gh<_i755.DaysRepository>()),
    );
    gh.factory<_i956.WatchDaysUseCase>(
      () => _i956.WatchDaysUseCase(gh<_i755.DaysRepository>()),
    );
    gh.factory<_i214.GetDaysUseCase>(
      () => _i214.GetDaysUseCase(gh<_i755.DaysRepository>()),
    );
    gh.factory<_i858.AuthCubit>(() => _i858.AuthCubit(gh<_i91.AuthService>()));
    gh.factory<_i431.DeleteTimelineItemUseCase>(
      () =>
          _i431.DeleteTimelineItemUseCase(gh<_i348.TimelineItemsRepository>()),
    );
    gh.factory<_i939.CreateTimelineItemUseCase>(
      () =>
          _i939.CreateTimelineItemUseCase(gh<_i348.TimelineItemsRepository>()),
    );
    gh.factory<_i1003.UpdateTimelineItemUseCase>(
      () =>
          _i1003.UpdateTimelineItemUseCase(gh<_i348.TimelineItemsRepository>()),
    );
    gh.factory<_i172.GetTimelineItemUseCase>(
      () => _i172.GetTimelineItemUseCase(gh<_i348.TimelineItemsRepository>()),
    );
    gh.factory<_i484.WatchTimelineItemUseCase>(
      () => _i484.WatchTimelineItemUseCase(gh<_i348.TimelineItemsRepository>()),
    );
    gh.factory<_i136.OptimisticSyncService>(
      () => _i136.OptimisticSyncService(
        gh<_i755.DaysRepository>(),
        gh<_i348.TimelineItemsRepository>(),
        gh<_i811.RemoveItemFromDayUseCase>(),
        gh<_i431.DeleteTimelineItemUseCase>(),
        gh<_i327.LoggerService>(),
      ),
    );
    gh.factory<_i293.TimelineCubit>(
      () => _i293.TimelineCubit(
        gh<_i214.GetDaysUseCase>(),
        gh<_i956.WatchDaysUseCase>(),
        gh<_i913.MoveItemBetweenDaysUseCase>(),
        gh<_i468.AddItemToDayUseCase>(),
        gh<_i811.RemoveItemFromDayUseCase>(),
        gh<_i903.GetProjectsUseCase>(),
        gh<_i68.WatchProjectsUseCase>(),
        gh<_i654.GetProjectByIdUseCase>(),
        gh<_i939.CreateTimelineItemUseCase>(),
        gh<_i172.GetTimelineItemUseCase>(),
        gh<_i484.WatchTimelineItemUseCase>(),
        gh<_i1003.UpdateTimelineItemUseCase>(),
        gh<_i431.DeleteTimelineItemUseCase>(),
        gh<_i91.AuthService>(),
        gh<_i136.OptimisticSyncService>(),
      ),
    );
    return this;
  }
}

class _$FirebaseModule extends _i145.FirebaseModule {}
