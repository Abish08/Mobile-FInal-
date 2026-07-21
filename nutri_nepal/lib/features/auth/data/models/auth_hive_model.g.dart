// GENERATED CODE - DO NOT MODIFY BY HAND
// Manually updated to include health profile fields

part of 'auth_hive_model.dart';

class AuthHiveModelAdapter extends TypeAdapter<AuthHiveModel> {
  @override
  final int typeId = 1;

  @override
  AuthHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthHiveModel(
      userId: fields[0] as String? ?? '',
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      phone: fields[3] as String,
      email: fields[4] as String,
      password: fields[5] as String,
      profilePicture: fields[6] as String? ?? 'default-profile.png', // ✅ Fixed
      age: fields[7] as int?,
      weight: fields[8] as double?,
      height: fields[9] as double?,
      gender: fields[10] as String?,
      fitnessGoal: fields[11] as String?,
      healthConditions: fields[12] as List<String>?,
    );
  }

  @override
  void write(BinaryWriter writer, AuthHiveModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.password)
      ..writeByte(6)
      ..write(obj.profilePicture)
      ..writeByte(7)
      ..write(obj.age)
      ..writeByte(8)
      ..write(obj.weight)
      ..writeByte(9)
      ..write(obj.height)
      ..writeByte(10)
      ..write(obj.gender)
      ..writeByte(11)
      ..write(obj.fitnessGoal)
      ..writeByte(12)
      ..write(obj.healthConditions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}