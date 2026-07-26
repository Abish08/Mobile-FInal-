import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/core/usecases/app_usecase.dart';
import 'package:nutri_nepal/features/daily_log/data/repositories/daily_log_repository_impl.dart';
import 'package:nutri_nepal/features/daily_log/domain/entities/daily_log_entity.dart';
import 'package:nutri_nepal/features/daily_log/domain/repositories/daily_log_repository.dart';

final getDailyLogUseCaseProvider = Provider<GetDailyLogUseCase>((ref) {
  return GetDailyLogUseCase(ref.read(dailyLogRepositoryProvider));
});

class GetDailyLogUseCase implements UsecaseWithParams<DailyLogEntity, DateTime> {
  final IDailyLogRepository _repository;

  GetDailyLogUseCase(this._repository);

  @override
  Future<Either<Failure, DailyLogEntity>> call(DateTime params) {
    return _repository.getDailyLog(params);
  }
}
