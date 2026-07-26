import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/core/usecases/app_usecase.dart';
import 'package:nutri_nepal/features/progress/data/repositories/progress_repository_impl.dart';
import 'package:nutri_nepal/features/progress/domain/entities/progress_entity.dart';
import 'package:nutri_nepal/features/progress/domain/repositories/progress_repository.dart';

final getProgressSummaryUseCaseProvider = Provider<GetProgressSummaryUseCase>((
  ref,
) {
  return GetProgressSummaryUseCase(ref.read(progressRepositoryProvider));
});

class GetProgressSummaryUseCase
    implements UsecaseWithoutParams<ProgressSummaryEntity> {
  final IProgressRepository _repository;

  GetProgressSummaryUseCase(this._repository);

  @override
  Future<Either<Failure, ProgressSummaryEntity>> call() {
    return _repository.getSummary();
  }
}
