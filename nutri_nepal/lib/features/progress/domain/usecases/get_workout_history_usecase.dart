import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/core/usecases/app_usecase.dart';
import 'package:nutri_nepal/features/progress/data/repositories/progress_repository_impl.dart';
import 'package:nutri_nepal/features/progress/domain/entities/progress_entity.dart';
import 'package:nutri_nepal/features/progress/domain/repositories/progress_repository.dart';

final getWorkoutHistoryUseCaseProvider = Provider<GetWorkoutHistoryUseCase>((
  ref,
) {
  return GetWorkoutHistoryUseCase(ref.read(progressRepositoryProvider));
});

class GetWorkoutHistoryUseCase
    implements UsecaseWithParams<List<ProgressPointEntity>, int> {
  final IProgressRepository _repository;

  GetWorkoutHistoryUseCase(this._repository);

  @override
  Future<Either<Failure, List<ProgressPointEntity>>> call(int params) {
    return _repository.getWorkoutHistory(days: params);
  }
}
