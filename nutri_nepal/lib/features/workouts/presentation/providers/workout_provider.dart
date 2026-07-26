import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/providers/refresh_provider.dart';
import 'package:nutri_nepal/features/workouts/domain/entities/workout_entity.dart';
import 'package:nutri_nepal/features/workouts/domain/usecases/get_workouts_usecase.dart';
import 'package:nutri_nepal/features/workouts/domain/usecases/log_workout_usecase.dart';

final workoutProvider = AsyncNotifierProvider<WorkoutNotifier, WorkoutState>(
  WorkoutNotifier.new,
);

class WorkoutState extends Equatable {
  final List<UserWorkout> workouts;

  const WorkoutState({required this.workouts});
  const WorkoutState.empty() : workouts = const [];

  bool get isEmpty => workouts.isEmpty;

  @override
  List<Object?> get props => [workouts];
}

class WorkoutNotifier extends AsyncNotifier<WorkoutState> {
  @override
  Future<WorkoutState> build() async {
    return const WorkoutState.empty();
  }

  Future<WorkoutState?> load() async {
    state = const AsyncLoading();
    final result = await ref.read(getWorkoutsUseCaseProvider).call();

    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return null;
      },
      (workouts) {
        final workoutState = WorkoutState(workouts: workouts);
        state = AsyncData(workoutState);
        return workoutState;
      },
    );
  }

  Future<bool> logWorkout(UserWorkout workout) async {
    final duration = int.tryParse(workout.duration ?? '') ?? 30;
    final result = await ref
        .read(logWorkoutUseCaseProvider)
        .call(
          LogWorkoutParams(
            workoutId: workout.id,
            duration: duration > 0 ? duration : 30,
            date: DateTime.now(),
          ),
        );

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

  Future<WorkoutState?> retry() => load();
}
