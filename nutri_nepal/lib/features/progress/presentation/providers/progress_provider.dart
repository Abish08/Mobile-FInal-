import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/providers/refresh_provider.dart';
import 'package:nutri_nepal/features/progress/domain/entities/progress_entity.dart';
import 'package:nutri_nepal/features/progress/domain/usecases/add_progress_usecase.dart';
import 'package:nutri_nepal/features/progress/domain/usecases/get_calorie_history_usecase.dart';
import 'package:nutri_nepal/features/progress/domain/usecases/get_progress_summary_usecase.dart';
import 'package:nutri_nepal/features/progress/domain/usecases/get_workout_history_usecase.dart';

final progressProvider = AsyncNotifierProvider<ProgressNotifier, ProgressState>(
  ProgressNotifier.new,
);

class ProgressState extends Equatable {
  final ProgressSummaryEntity? summary;
  final List<ProgressPointEntity> calorieHistory;
  final List<ProgressPointEntity> workoutHistory;

  const ProgressState({
    required this.summary,
    required this.calorieHistory,
    required this.workoutHistory,
  });

  const ProgressState.empty()
    : summary = null,
      calorieHistory = const [],
      workoutHistory = const [];

  bool get isEmpty => calorieHistory.isEmpty && workoutHistory.isEmpty;

  @override
  List<Object?> get props => [summary, calorieHistory, workoutHistory];
}

class ProgressNotifier extends AsyncNotifier<ProgressState> {
  @override
  Future<ProgressState> build() async {
    return const ProgressState.empty();
  }

  Future<ProgressState?> load({int days = 30}) async {
    state = const AsyncLoading();

    final summaryResult = await ref
        .read(getProgressSummaryUseCaseProvider)
        .call();
    final calorieResult = await ref
        .read(getCalorieHistoryUseCaseProvider)
        .call(days);
    final workoutResult = await ref
        .read(getWorkoutHistoryUseCaseProvider)
        .call(days);

    String? failureMessage;
    ProgressSummaryEntity? summary;
    List<ProgressPointEntity> calorieHistory = const [];
    List<ProgressPointEntity> workoutHistory = const [];

    summaryResult.fold(
      (failure) => failureMessage = failure.message,
      (value) => summary = value,
    );
    calorieResult.fold(
      (failure) => failureMessage ??= failure.message,
      (value) => calorieHistory = value,
    );
    workoutResult.fold(
      (failure) => failureMessage ??= failure.message,
      (value) => workoutHistory = value,
    );

    if (failureMessage != null) {
      state = AsyncError(failureMessage!, StackTrace.current);
      return null;
    }

    final progressState = ProgressState(
      summary: summary,
      calorieHistory: calorieHistory,
      workoutHistory: workoutHistory,
    );
    state = AsyncData(progressState);
    return progressState;
  }

  Future<bool> addProgressEntry(double weight) async {
    state = const AsyncLoading();
    final result = await ref.read(addProgressUseCaseProvider).call(weight);

    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        ref.invalidateSelf();
        ref.read(refreshProvider.notifier).refresh();
        return true;
      },
    );
  }

  Future<ProgressState?> retry() => load();
}
