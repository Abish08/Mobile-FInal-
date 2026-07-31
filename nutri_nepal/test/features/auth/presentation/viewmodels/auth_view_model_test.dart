import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/features/auth/domain/entities/auth_entity.dart';
import 'package:nutri_nepal/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:nutri_nepal/features/auth/domain/usecases/google_login_usecase.dart';
import 'package:nutri_nepal/features/auth/domain/usecases/login_usecase.dart';
import 'package:nutri_nepal/features/auth/domain/usecases/logout_usecase.dart';
import 'package:nutri_nepal/features/auth/domain/usecases/register_usecase.dart';
import 'package:nutri_nepal/features/auth/presentation/state/auth_state.dart';
import 'package:nutri_nepal/features/auth/presentation/view_model/auth_viewmodel.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetCurrentUseCase extends Mock implements GetCurrentUseCase {}

class MockGoogleLoginUseCase extends Mock implements GoogleLoginUseCase {}

void main() {
  late MockLoginUseCase loginUseCase;
  late MockRegisterUseCase registerUseCase;
  late MockLogoutUseCase logoutUseCase;
  late MockGetCurrentUseCase getCurrentUseCase;
  late MockGoogleLoginUseCase googleLoginUseCase;
  late ProviderContainer container;

  const user = AuthEntity(
    userId: 'user-1',
    firstName: 'Abish',
    lastName: 'Khanal',
    email: 'abish@example.com',
    phone: '9800000000',
    password: '',
  );

  setUpAll(() {
    registerFallbackValue(
      const LoginParams(email: 'abish@example.com', password: 'secret123'),
    );
    registerFallbackValue(
      const RegisterParams(
        firstName: 'Abish',
        lastName: 'Khanal',
        email: 'abish@example.com',
        phone: '9800000000',
        password: 'secret123',
      ),
    );
  });

  setUp(() {
    loginUseCase = MockLoginUseCase();
    registerUseCase = MockRegisterUseCase();
    logoutUseCase = MockLogoutUseCase();
    getCurrentUseCase = MockGetCurrentUseCase();
    googleLoginUseCase = MockGoogleLoginUseCase();

    container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWithValue(loginUseCase),
        registerUseCaseProvider.overrideWithValue(registerUseCase),
        logoutUseCaseProvider.overrideWithValue(logoutUseCase),
        getCurrentUseCaseProvider.overrideWithValue(getCurrentUseCase),
        googleLoginUseCaseProvider.overrideWithValue(googleLoginUseCase),
      ],
    );
    addTearDown(container.dispose);
  });

  test('initial state is initial', () {
    expect(container.read(authViewModelProvider).status, AuthStatus.initial);
  });

  test('login success changes state to authenticated', () async {
    when(() => loginUseCase(any())).thenAnswer((_) async => const Right(user));

    await container
        .read(authViewModelProvider.notifier)
        .login(email: ' abish@example.com ', password: 'secret123');

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.authenticated);
    expect(state.user, user);
    expect(state.message, 'Welcome back, Abish!');
    verify(
      () => loginUseCase(
        const LoginParams(email: 'abish@example.com', password: 'secret123'),
      ),
    ).called(1);
  });

  test('login failure changes state to error', () async {
    const failure = ApiFailure(message: 'Invalid credentials', statusCode: 401);
    when(() => loginUseCase(any()))
        .thenAnswer((_) async => const Left(failure));

    await container
        .read(authViewModelProvider.notifier)
        .login(email: 'abish@example.com', password: 'wrong');

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.error);
    expect(state.message, 'Invalid credentials');
  });

  test('register success changes state to registered', () async {
    when(() => registerUseCase(any()))
        .thenAnswer((_) async => const Right(true));

    await container.read(authViewModelProvider.notifier).register(
          firstName: 'Abish',
          lastName: 'Khanal',
          email: 'abish@example.com',
          phone: '9800000000',
          password: 'secret123',
        );

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.registered);
    expect(state.message, 'Account created successfully! Please log in.');
  });

  test('logout resets state to initial', () async {
    when(() => logoutUseCase()).thenAnswer((_) async => const Right(true));

    await container.read(authViewModelProvider.notifier).logout();

    expect(container.read(authViewModelProvider), const AuthState());
    verify(() => logoutUseCase()).called(1);
  });
}
