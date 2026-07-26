import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/features/daily_log/domain/entities/daily_log_entity.dart';
import 'package:nutri_nepal/features/daily_log/domain/usecases/delete_daily_log_usecase.dart';
import 'package:nutri_nepal/features/daily_log/domain/usecases/get_daily_log_usecase.dart';

final dailyLogProvider =
    AsyncNotifierProvider<DailyLogNotifier, DailyLogEntity?>(
      DailyLogNotifier.new,
    );

class DailyLogNotifier extends AsyncNotifier<DailyLogEntity?> {
  @override
  Future<DailyLogEntity?> build() async {
    return null;
  }

  Future<DailyLogEntity?> loadDailyLog({DateTime? date}) async {
    state = const AsyncLoading();
    final result = await ref
        .read(getDailyLogUseCaseProvider)
        .call(date ?? DateTime.now());

    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return null;
      },
      (dailyLog) {
        state = AsyncData(dailyLog);
        return dailyLog;
      },
    );
  }

  Future<bool> deleteLog({required String id, required bool isWorkout}) async {
    final previousState = state;
    state = const AsyncLoading();

    final result = await ref
        .read(deleteDailyLogUseCaseProvider)
        .call(DeleteDailyLogParams(id: id, isWorkout: isWorkout));

    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = previousState;
        ref.invalidateSelf();
        return true;
      },
    );
  }
}
