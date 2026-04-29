// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StudentModel _$StudentModelFromJson(Map<String, dynamic> json) =>
    _StudentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      studentCode: json['studentCode'] as String,
      schoolName: json['schoolName'] as String,
      city: json['city'] as String,
      passportNumber: json['passportNumber'] as String,
      passportExpiry: json['passportExpiry'] as String,
      courseName: json['courseName'] as String,
      theoryCompletion: (json['theoryCompletion'] as num).toInt(),
      practicalCompletion: (json['practicalCompletion'] as num).toInt(),
      internshipCompletion: (json['internshipCompletion'] as num).toInt(),
      visitsCompletion: (json['visitsCompletion'] as num).toInt(),
      isPassportExpiring: json['isPassportExpiring'] as bool? ?? false,
    );

Map<String, dynamic> _$StudentModelToJson(_StudentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'studentCode': instance.studentCode,
      'schoolName': instance.schoolName,
      'city': instance.city,
      'passportNumber': instance.passportNumber,
      'passportExpiry': instance.passportExpiry,
      'courseName': instance.courseName,
      'theoryCompletion': instance.theoryCompletion,
      'practicalCompletion': instance.practicalCompletion,
      'internshipCompletion': instance.internshipCompletion,
      'visitsCompletion': instance.visitsCompletion,
      'isPassportExpiring': instance.isPassportExpiring,
    };
