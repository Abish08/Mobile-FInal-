import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/providers/refresh_provider.dart';
import 'package:nutri_nepal/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:nutri_nepal/features/profile/domain/entities/profile_entity.dart';
import 'package:nutri_nepal/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:nutri_nepal/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:nutri_nepal/features/profile/domain/usecases/upload_profile_image_usecase.dart';

final profileProvider = AsyncNotifierProvider<ProfileNotifier, ProfileEntity?>(
  ProfileNotifier.new,
);

class ProfileNotifier extends AsyncNotifier<ProfileEntity?> {
  @override
  Future<ProfileEntity?> build() async => null;

  Future<ProfileEntity?> loadProfile() async {
    state = const AsyncLoading();
    final result = await ref.read(getProfileUseCaseProvider).call();
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

  Future<ProfileEntity?> updateProfile(ProfileEntity profile) async {
    state = const AsyncLoading();
    final result = await ref.read(updateProfileUseCaseProvider).call(profile);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return null;
      },
      (updatedProfile) async {
        state = AsyncData(updatedProfile);
        await _refreshSessionAndDashboard();
        return updatedProfile;
      },
    );
  }

  Future<ProfileEntity?> uploadProfileImage(File imageFile) async {
    final previous = state.asData?.value;
    state = const AsyncLoading();
    final result = await ref
        .read(uploadProfileImageUseCaseProvider)
        .call(imageFile);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        if (previous != null) {
          state = AsyncData(previous);
        }
        return null;
      },
      (updatedProfile) async {
        state = AsyncData(updatedProfile);
        await _refreshSessionAndDashboard();
        return updatedProfile;
      },
    );
  }

  Future<ProfileEntity?> retry() => loadProfile();

  Future<void> _refreshSessionAndDashboard() async {
    await ref.read(authViewModelProvider.notifier).getCurrentUser();
    ref.read(refreshProvider.notifier).refresh();
  }
}
