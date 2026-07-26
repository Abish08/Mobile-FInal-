import 'package:nutri_nepal/core/api/api_endpoints.dart';
import 'package:nutri_nepal/features/workouts/domain/entities/workout_entity.dart';

class WorkoutModel extends UserWorkout {
  const WorkoutModel({
    required super.id,
    required super.name,
    required super.category,
    super.description,
    super.thumbnail,
    super.youtubeUrl,
    super.duration,
    super.caloriesBurned,
    super.difficulty,
    super.sets,
    super.reps,
    super.rest,
    super.equipment,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    final thumbnail = _thumbnailFrom(json);
    return WorkoutModel(
      id: _idFrom(json['_id']),
      name: _text(json['name'], fallback: 'Unknown Workout'),
      category: _text(json['category'], fallback: 'General'),
      description: _optionalText(json['description']),
      thumbnail: thumbnail == null
          ? null
          : ApiEndpoints.resolveUploadUrl(thumbnail, defaultFolder: 'workouts'),
      youtubeUrl: _optionalText(json['youtubeUrl'] ?? json['videoUrl']),
      duration: _durationText(json['duration'] ?? json['durationMinutes']),
      caloriesBurned: _nonNegativeInt(
        json['caloriesBurned'] ?? json['calories'],
      ),
      difficulty: _optionalText(json['difficulty']),
      sets: _nonNegativeInt(json['sets']),
      reps: _nonNegativeInt(json['reps']),
      rest: _optionalText(json['rest']),
      equipment: _optionalText(json['equipment']),
    );
  }

  static List<UserWorkout> listFromResponse(dynamic responseData) {
    List<dynamic> rawData = const [];
    if (responseData is Map) {
      rawData =
          (responseData['workouts'] ?? responseData['data'] ?? [])
              as List<dynamic>;
    } else if (responseData is List) {
      rawData = responseData;
    }

    return rawData
        .whereType<Map>()
        .map((item) => WorkoutModel.fromJson(Map<String, dynamic>.from(item)))
        .where((workout) => workout.id.isNotEmpty)
        .toList();
  }

  static String _idFrom(dynamic value) {
    if (value is Map) return value['\$oid']?.toString() ?? '';
    return value?.toString() ?? '';
  }

  static String _text(dynamic value, {required String fallback}) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  static String? _optionalText(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static String? _durationText(dynamic value) {
    final parsed = _nonNegativeInt(value);
    if (parsed == null || parsed == 0) return null;
    return parsed.toString();
  }

  static int? _nonNegativeInt(dynamic value) {
    final parsed = value is num ? value.toDouble() : double.tryParse('$value');
    if (parsed == null || parsed.isNaN || parsed.isInfinite || parsed < 0) {
      return null;
    }
    return parsed.round();
  }

  static String? _thumbnailFrom(Map<String, dynamic> json) {
    final media = json['media'];
    if (media is List && media.isNotEmpty) {
      final image = media.whereType<Map>().cast<Map>().firstWhere(
        (item) => item['type'] == 'image',
        orElse: () => media.first is Map ? media.first as Map : const {},
      );
      final url = _optionalText(image['url']);
      if (url != null) return url;
    }
    final thumbnail = _optionalText(json['thumbnail']);
    if (thumbnail != null) return thumbnail;
    final images = json['images'];
    if (images is List && images.isNotEmpty) return _optionalText(images.first);
    return null;
  }
}
