import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/features/auth/domain/entities/auth_entity.dart';
import 'package:nutri_nepal/features/auth/domain/repositories/auth_repository.dart';
import 'package:nutri_nepal/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:nutri_nepal/features/auth/domain/usecases/google_login_usecase.dart';
import 'package:nutri_nepal/features/auth/domain/usecases/login_usecase.dart';
import 'package:nutri_nepal/features/auth/domain/usecases/logout_usecase.dart';
import 'package:nutri_nepal/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository repository;

  const user = AuthEntity(
    userId: 'user-1',
    firstName: 'Abish',
    lastName: 'Khanal',
    email: 'abish@example.com',
    phone: '9800000000',
    password: '',
  );

  setUpAll(() {
    registerFallbackValue(user);
  });

  setUp(() {
    repository = MockAuthRepository();
  });

  test('LoginUseCase delegates email and password to repository', () async {
    when(() => repository.login('abish@example.com', 'secret123'))
        .thenAnswer((_) async => const Right(user));

    final result = await LoginUseCase(repository)(
      const LoginParams(email: 'abish@example.com', password: 'secret123'),
    );

    expect(result, const Right(user));
    verify(() => repository.login('abish@example.com', 'secret123')).called(1);
  });

  test('RegisterUseCase builds AuthEntity and returns repository result',
      () async {
    when(() => repository.register(any()))
        .thenAnswer((_) async => const Right(true));

    final result = await RegisterUseCase(repository)(
      const RegisterParams(
        firstName: 'Abish',
        lastName: 'Khanal',
        email: 'abish@example.com',
        phone: '9800000000',
        password: 'secret123',
      ),
    );

    expect(result, const Right(true));
    final captured = verify(() => repository.register(captureAny())).captured;
    expect((captured.single as AuthEntity).email, 'abish@example.com');
  });

  test('GetCurrentUseCase returns repository failure unchanged', () async {
    const failure = ApiFailure(message: 'No session', statusCode: 401);
    when(() => repository.getCurrentUser())
        .thenAnswer((_) async => const Left(failure));

    final result = await GetCurrentUseCase(repository)();

    expect(result, const Left(failure));
  });

  test('GoogleLoginUseCase sends id token to repository', () async {
    when(() => repository.loginWithGoogle('google-token'))
        .thenAnswer((_) async => const Right(user));

    final result = await GoogleLoginUseCase(repository)('google-token');

    expect(result, const Right(user));
    verify(() => repository.loginWithGoogle('google-token')).called(1);
  });

  test('LogoutUseCase delegates logout', () async {
    when(() => repository.logout()).thenAnswer((_) async => const Right(true));

    final result = await LogoutUseCase(repository)();

    expect(result, const Right(true));
    verify(() => repository.logout()).called(1);
  });
}
