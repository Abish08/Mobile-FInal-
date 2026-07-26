import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/features/health_profile/domain/entities/health_profile_entity.dart';
import 'package:nutri_nepal/features/health_profile/domain/usecases/get_health_profile_usecase.dart';
import 'package:nutri_nepal/features/health_profile/domain/usecases/save_health_profile_usecase.dart';

final healthProfileProvider =
    AsyncNotifierProvider<HealthProfileNotifier, HealthProfileEntity?>(
  HealthProfileNotifier.new,
);

class HealthProfileNotifier extends AsyncNotifier<HealthProfileEntity?> {
  @override
  Future<HealthProfileEntity?> build() async {
    return null;
  }

  Future<HealthProfileEntity?> loadProfile() async {
    state = const AsyncLoading();
    final result = await ref.read(getHealthProfileUseCaseProvider).call();

    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return null;
      },
      (profile) {
        state = AsyncData(profile);
        return profile;
      },
    );
  }

  Future<HealthProfileEntity?> saveProfile(HealthProfileEntity profile) async {
    state = const AsyncLoading();
    final result = await ref.read(saveHealthProfileUseCaseProvider).call(profile);

    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return null;
      },
      (savedProfile) {
        state = AsyncData(savedProfile);
        return savedProfile;
      },
    );
  }
}
