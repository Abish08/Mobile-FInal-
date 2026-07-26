import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/core/usecases/app_usecase.dart';
import 'package:nutri_nepal/features/daily_log/data/repositories/daily_log_repository_impl.dart';
import 'package:nutri_nepal/features/daily_log/domain/repositories/daily_log_repository.dart';

final deleteDailyLogUseCaseProvider = Provider<DeleteDailyLogUseCase>((ref) {
  return DeleteDailyLogUseCase(ref.read(dailyLogRepositoryProvider));
});

class DeleteDailyLogParams {
  final String id;
  final bool isWorkout;

  const DeleteDailyLogParams({required this.id, required this.isWorkout});
}

class DeleteDailyLogUseCase
    implements UsecaseWithParams<void, DeleteDailyLogParams> {
  final IDailyLogRepository _repository;

  DeleteDailyLogUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(DeleteDailyLogParams params) {
    return _repository.deleteLog(id: params.id, isWorkout: params.isWorkout);
  }
}
