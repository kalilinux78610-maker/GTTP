// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StudentModel {

 String get id; String get name; String get studentCode; String get schoolName; String get city; String get passportNumber; String get passportExpiry; String get courseName; int get theoryCompletion; int get practicalCompletion; int get internshipCompletion; int get visitsCompletion; bool get isPassportExpiring;
/// Create a copy of StudentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentModelCopyWith<StudentModel> get copyWith => _$StudentModelCopyWithImpl<StudentModel>(this as StudentModel, _$identity);

  /// Serializes this StudentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.studentCode, studentCode) || other.studentCode == studentCode)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.city, city) || other.city == city)&&(identical(other.passportNumber, passportNumber) || other.passportNumber == passportNumber)&&(identical(other.passportExpiry, passportExpiry) || other.passportExpiry == passportExpiry)&&(identical(other.courseName, courseName) || other.courseName == courseName)&&(identical(other.theoryCompletion, theoryCompletion) || other.theoryCompletion == theoryCompletion)&&(identical(other.practicalCompletion, practicalCompletion) || other.practicalCompletion == practicalCompletion)&&(identical(other.internshipCompletion, internshipCompletion) || other.internshipCompletion == internshipCompletion)&&(identical(other.visitsCompletion, visitsCompletion) || other.visitsCompletion == visitsCompletion)&&(identical(other.isPassportExpiring, isPassportExpiring) || other.isPassportExpiring == isPassportExpiring));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,studentCode,schoolName,city,passportNumber,passportExpiry,courseName,theoryCompletion,practicalCompletion,internshipCompletion,visitsCompletion,isPassportExpiring);

@override
String toString() {
  return 'StudentModel(id: $id, name: $name, studentCode: $studentCode, schoolName: $schoolName, city: $city, passportNumber: $passportNumber, passportExpiry: $passportExpiry, courseName: $courseName, theoryCompletion: $theoryCompletion, practicalCompletion: $practicalCompletion, internshipCompletion: $internshipCompletion, visitsCompletion: $visitsCompletion, isPassportExpiring: $isPassportExpiring)';
}


}

/// @nodoc
abstract mixin class $StudentModelCopyWith<$Res>  {
  factory $StudentModelCopyWith(StudentModel value, $Res Function(StudentModel) _then) = _$StudentModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String studentCode, String schoolName, String city, String passportNumber, String passportExpiry, String courseName, int theoryCompletion, int practicalCompletion, int internshipCompletion, int visitsCompletion, bool isPassportExpiring
});




}
/// @nodoc
class _$StudentModelCopyWithImpl<$Res>
    implements $StudentModelCopyWith<$Res> {
  _$StudentModelCopyWithImpl(this._self, this._then);

  final StudentModel _self;
  final $Res Function(StudentModel) _then;

/// Create a copy of StudentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? studentCode = null,Object? schoolName = null,Object? city = null,Object? passportNumber = null,Object? passportExpiry = null,Object? courseName = null,Object? theoryCompletion = null,Object? practicalCompletion = null,Object? internshipCompletion = null,Object? visitsCompletion = null,Object? isPassportExpiring = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,studentCode: null == studentCode ? _self.studentCode : studentCode // ignore: cast_nullable_to_non_nullable
as String,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,passportNumber: null == passportNumber ? _self.passportNumber : passportNumber // ignore: cast_nullable_to_non_nullable
as String,passportExpiry: null == passportExpiry ? _self.passportExpiry : passportExpiry // ignore: cast_nullable_to_non_nullable
as String,courseName: null == courseName ? _self.courseName : courseName // ignore: cast_nullable_to_non_nullable
as String,theoryCompletion: null == theoryCompletion ? _self.theoryCompletion : theoryCompletion // ignore: cast_nullable_to_non_nullable
as int,practicalCompletion: null == practicalCompletion ? _self.practicalCompletion : practicalCompletion // ignore: cast_nullable_to_non_nullable
as int,internshipCompletion: null == internshipCompletion ? _self.internshipCompletion : internshipCompletion // ignore: cast_nullable_to_non_nullable
as int,visitsCompletion: null == visitsCompletion ? _self.visitsCompletion : visitsCompletion // ignore: cast_nullable_to_non_nullable
as int,isPassportExpiring: null == isPassportExpiring ? _self.isPassportExpiring : isPassportExpiring // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StudentModel].
extension StudentModelPatterns on StudentModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudentModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudentModel value)  $default,){
final _that = this;
switch (_that) {
case _StudentModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudentModel value)?  $default,){
final _that = this;
switch (_that) {
case _StudentModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String studentCode,  String schoolName,  String city,  String passportNumber,  String passportExpiry,  String courseName,  int theoryCompletion,  int practicalCompletion,  int internshipCompletion,  int visitsCompletion,  bool isPassportExpiring)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudentModel() when $default != null:
return $default(_that.id,_that.name,_that.studentCode,_that.schoolName,_that.city,_that.passportNumber,_that.passportExpiry,_that.courseName,_that.theoryCompletion,_that.practicalCompletion,_that.internshipCompletion,_that.visitsCompletion,_that.isPassportExpiring);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String studentCode,  String schoolName,  String city,  String passportNumber,  String passportExpiry,  String courseName,  int theoryCompletion,  int practicalCompletion,  int internshipCompletion,  int visitsCompletion,  bool isPassportExpiring)  $default,) {final _that = this;
switch (_that) {
case _StudentModel():
return $default(_that.id,_that.name,_that.studentCode,_that.schoolName,_that.city,_that.passportNumber,_that.passportExpiry,_that.courseName,_that.theoryCompletion,_that.practicalCompletion,_that.internshipCompletion,_that.visitsCompletion,_that.isPassportExpiring);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String studentCode,  String schoolName,  String city,  String passportNumber,  String passportExpiry,  String courseName,  int theoryCompletion,  int practicalCompletion,  int internshipCompletion,  int visitsCompletion,  bool isPassportExpiring)?  $default,) {final _that = this;
switch (_that) {
case _StudentModel() when $default != null:
return $default(_that.id,_that.name,_that.studentCode,_that.schoolName,_that.city,_that.passportNumber,_that.passportExpiry,_that.courseName,_that.theoryCompletion,_that.practicalCompletion,_that.internshipCompletion,_that.visitsCompletion,_that.isPassportExpiring);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudentModel implements StudentModel {
  const _StudentModel({required this.id, required this.name, required this.studentCode, required this.schoolName, required this.city, required this.passportNumber, required this.passportExpiry, required this.courseName, required this.theoryCompletion, required this.practicalCompletion, required this.internshipCompletion, required this.visitsCompletion, this.isPassportExpiring = false});
  factory _StudentModel.fromJson(Map<String, dynamic> json) => _$StudentModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String studentCode;
@override final  String schoolName;
@override final  String city;
@override final  String passportNumber;
@override final  String passportExpiry;
@override final  String courseName;
@override final  int theoryCompletion;
@override final  int practicalCompletion;
@override final  int internshipCompletion;
@override final  int visitsCompletion;
@override@JsonKey() final  bool isPassportExpiring;

/// Create a copy of StudentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentModelCopyWith<_StudentModel> get copyWith => __$StudentModelCopyWithImpl<_StudentModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudentModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.studentCode, studentCode) || other.studentCode == studentCode)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.city, city) || other.city == city)&&(identical(other.passportNumber, passportNumber) || other.passportNumber == passportNumber)&&(identical(other.passportExpiry, passportExpiry) || other.passportExpiry == passportExpiry)&&(identical(other.courseName, courseName) || other.courseName == courseName)&&(identical(other.theoryCompletion, theoryCompletion) || other.theoryCompletion == theoryCompletion)&&(identical(other.practicalCompletion, practicalCompletion) || other.practicalCompletion == practicalCompletion)&&(identical(other.internshipCompletion, internshipCompletion) || other.internshipCompletion == internshipCompletion)&&(identical(other.visitsCompletion, visitsCompletion) || other.visitsCompletion == visitsCompletion)&&(identical(other.isPassportExpiring, isPassportExpiring) || other.isPassportExpiring == isPassportExpiring));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,studentCode,schoolName,city,passportNumber,passportExpiry,courseName,theoryCompletion,practicalCompletion,internshipCompletion,visitsCompletion,isPassportExpiring);

@override
String toString() {
  return 'StudentModel(id: $id, name: $name, studentCode: $studentCode, schoolName: $schoolName, city: $city, passportNumber: $passportNumber, passportExpiry: $passportExpiry, courseName: $courseName, theoryCompletion: $theoryCompletion, practicalCompletion: $practicalCompletion, internshipCompletion: $internshipCompletion, visitsCompletion: $visitsCompletion, isPassportExpiring: $isPassportExpiring)';
}


}

/// @nodoc
abstract mixin class _$StudentModelCopyWith<$Res> implements $StudentModelCopyWith<$Res> {
  factory _$StudentModelCopyWith(_StudentModel value, $Res Function(_StudentModel) _then) = __$StudentModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String studentCode, String schoolName, String city, String passportNumber, String passportExpiry, String courseName, int theoryCompletion, int practicalCompletion, int internshipCompletion, int visitsCompletion, bool isPassportExpiring
});




}
/// @nodoc
class __$StudentModelCopyWithImpl<$Res>
    implements _$StudentModelCopyWith<$Res> {
  __$StudentModelCopyWithImpl(this._self, this._then);

  final _StudentModel _self;
  final $Res Function(_StudentModel) _then;

/// Create a copy of StudentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? studentCode = null,Object? schoolName = null,Object? city = null,Object? passportNumber = null,Object? passportExpiry = null,Object? courseName = null,Object? theoryCompletion = null,Object? practicalCompletion = null,Object? internshipCompletion = null,Object? visitsCompletion = null,Object? isPassportExpiring = null,}) {
  return _then(_StudentModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,studentCode: null == studentCode ? _self.studentCode : studentCode // ignore: cast_nullable_to_non_nullable
as String,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,passportNumber: null == passportNumber ? _self.passportNumber : passportNumber // ignore: cast_nullable_to_non_nullable
as String,passportExpiry: null == passportExpiry ? _self.passportExpiry : passportExpiry // ignore: cast_nullable_to_non_nullable
as String,courseName: null == courseName ? _self.courseName : courseName // ignore: cast_nullable_to_non_nullable
as String,theoryCompletion: null == theoryCompletion ? _self.theoryCompletion : theoryCompletion // ignore: cast_nullable_to_non_nullable
as int,practicalCompletion: null == practicalCompletion ? _self.practicalCompletion : practicalCompletion // ignore: cast_nullable_to_non_nullable
as int,internshipCompletion: null == internshipCompletion ? _self.internshipCompletion : internshipCompletion // ignore: cast_nullable_to_non_nullable
as int,visitsCompletion: null == visitsCompletion ? _self.visitsCompletion : visitsCompletion // ignore: cast_nullable_to_non_nullable
as int,isPassportExpiring: null == isPassportExpiring ? _self.isPassportExpiring : isPassportExpiring // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
