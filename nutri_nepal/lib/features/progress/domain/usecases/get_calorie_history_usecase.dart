import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/core/usecases/app_usecase.dart';
import 'package:nutri_nepal/features/progress/data/repositories/progress_repository_impl.dart';
import 'package:nutri_nepal/features/progress/domain/entities/progress_entity.dart';
import 'package:nutri_nepal/features/progress/domain/repositories/progress_repository.dart';

final getCalorieHistoryUseCaseProvider = Provider<GetCalorieHistoryUseCase>((
  ref,
) {
  return GetCalorieHistoryUseCase(ref.read(progressRepositoryProvider));
});

class GetCalorieHistoryUseCase
    implements UsecaseWithParams<List<ProgressPointEntity>, int> {
  final IProgressRepository _repository;

  GetCalorieHistoryUseCase(this._repository);

  @override
  Future<Either<Failure, List<ProgressPointEntity>>> call(int params) {
    return _repository.getCalorieHistory(days: params);
  }
}
