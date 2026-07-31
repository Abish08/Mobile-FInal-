import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutri_nepal/features/admin/domain/entities/admin_entity.dart';
import 'package:nutri_nepal/features/admin/domain/repositories/admin_repository.dart';
import 'package:nutri_nepal/features/admin/domain/usecases/admin_usecases.dart';

class MockAdminRepository extends Mock implements IAdminRepository {}

void main() {
  late MockAdminRepository repository;
  late AdminUseCases useCases;

  setUp(() {
    repository = MockAdminRepository();
    useCases = AdminUseCases(repository);
  });

  test('getUsers forwards search and goal filters', () async {
    const users = AdminUserList(users: [], totalUsers: 0, newToday: 0);
    when(() => repository.getUsers(search: 'abish', goal: 'bulk'))
        .thenAnswer((_) async => const Right(users));

    final result = await useCases.getUsers(search: 'abish', goal: 'bulk');

    expect(result, const Right(users));
    verify(() => repository.getUsers(search: 'abish', goal: 'bulk')).called(1);
  });

  test('deleteWorkout delegates selected workout id', () async {
    when(() => repository.deleteWorkout('workout-1'))
        .thenAnswer((_) async => const Right<Never, void>(null));

    final result = await useCases.deleteWorkout('workout-1');

    expect(result, const Right<Never, void>(null));
    verify(() => repository.deleteWorkout('workout-1')).called(1);
  });
}
