import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/core/usecases/app_usecase.dart';
import 'package:nutri_nepal/features/progress/data/repositories/progress_repository_impl.dart';
import 'package:nutri_nepal/features/progress/domain/repositories/progress_repository.dart';

final addProgressUseCaseProvider = Provider<AddProgressUseCase>((ref) {
  return AddProgressUseCase(ref.read(progressRepositoryProvider));
});

class AddProgressUseCase implements UsecaseWithParams<void, double> {
  final IProgressRepository _repository;

  AddProgressUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(double params) {
    return _repository.addProgress(weight: params);
  }
}
