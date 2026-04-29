import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_model.freezed.dart';
part 'student_model.g.dart';

@freezed
abstract class StudentModel with _$StudentModel {
  const factory StudentModel({
    required String id,
    required String name,
    required String studentCode,
    required String schoolName,
    required String city,
    required String passportNumber,
    required String passportExpiry,
    required String courseName,
    required int theoryCompletion,
    required int practicalCompletion,
    required int internshipCompletion,
    required int visitsCompletion,
    @Default(false) bool isPassportExpiring,
  }) = _StudentModel;

  factory StudentModel.fromJson(Map<String, dynamic> json) => _$StudentModelFromJson(json);
}
