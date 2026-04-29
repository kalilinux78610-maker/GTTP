// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReportModel {

 String get id; String get submissionId; String get schoolName; String get activityTitle; String get flagReason; ReportCategory get category; ReportStatus get status; DateTime get createdAt; String get description; String get reporterName; String? get flaggedBy; int? get groupCount; String? get overrideComments;
/// Create a copy of ReportModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportModelCopyWith<ReportModel> get copyWith => _$ReportModelCopyWithImpl<ReportModel>(this as ReportModel, _$identity);

  /// Serializes this ReportModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportModel&&(identical(other.id, id) || other.id == id)&&(identical(other.submissionId, submissionId) || other.submissionId == submissionId)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.activityTitle, activityTitle) || other.activityTitle == activityTitle)&&(identical(other.flagReason, flagReason) || other.flagReason == flagReason)&&(identical(other.category, category) || other.category == category)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.reporterName, reporterName) || other.reporterName == reporterName)&&(identical(other.flaggedBy, flaggedBy) || other.flaggedBy == flaggedBy)&&(identical(other.groupCount, groupCount) || other.groupCount == groupCount)&&(identical(other.overrideComments, overrideComments) || other.overrideComments == overrideComments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,submissionId,schoolName,activityTitle,flagReason,category,status,createdAt,description,reporterName,flaggedBy,groupCount,overrideComments);

@override
String toString() {
  return 'ReportModel(id: $id, submissionId: $submissionId, schoolName: $schoolName, activityTitle: $activityTitle, flagReason: $flagReason, category: $category, status: $status, createdAt: $createdAt, description: $description, reporterName: $reporterName, flaggedBy: $flaggedBy, groupCount: $groupCount, overrideComments: $overrideComments)';
}


}

/// @nodoc
abstract mixin class $ReportModelCopyWith<$Res>  {
  factory $ReportModelCopyWith(ReportModel value, $Res Function(ReportModel) _then) = _$ReportModelCopyWithImpl;
@useResult
$Res call({
 String id, String submissionId, String schoolName, String activityTitle, String flagReason, ReportCategory category, ReportStatus status, DateTime createdAt, String description, String reporterName, String? flaggedBy, int? groupCount, String? overrideComments
});




}
/// @nodoc
class _$ReportModelCopyWithImpl<$Res>
    implements $ReportModelCopyWith<$Res> {
  _$ReportModelCopyWithImpl(this._self, this._then);

  final ReportModel _self;
  final $Res Function(ReportModel) _then;

/// Create a copy of ReportModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? submissionId = null,Object? schoolName = null,Object? activityTitle = null,Object? flagReason = null,Object? category = null,Object? status = null,Object? createdAt = null,Object? description = null,Object? reporterName = null,Object? flaggedBy = freezed,Object? groupCount = freezed,Object? overrideComments = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,submissionId: null == submissionId ? _self.submissionId : submissionId // ignore: cast_nullable_to_non_nullable
as String,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,activityTitle: null == activityTitle ? _self.activityTitle : activityTitle // ignore: cast_nullable_to_non_nullable
as String,flagReason: null == flagReason ? _self.flagReason : flagReason // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ReportCategory,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,reporterName: null == reporterName ? _self.reporterName : reporterName // ignore: cast_nullable_to_non_nullable
as String,flaggedBy: freezed == flaggedBy ? _self.flaggedBy : flaggedBy // ignore: cast_nullable_to_non_nullable
as String?,groupCount: freezed == groupCount ? _self.groupCount : groupCount // ignore: cast_nullable_to_non_nullable
as int?,overrideComments: freezed == overrideComments ? _self.overrideComments : overrideComments // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportModel].
extension ReportModelPatterns on ReportModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportModel value)  $default,){
final _that = this;
switch (_that) {
case _ReportModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReportModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String submissionId,  String schoolName,  String activityTitle,  String flagReason,  ReportCategory category,  ReportStatus status,  DateTime createdAt,  String description,  String reporterName,  String? flaggedBy,  int? groupCount,  String? overrideComments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportModel() when $default != null:
return $default(_that.id,_that.submissionId,_that.schoolName,_that.activityTitle,_that.flagReason,_that.category,_that.status,_that.createdAt,_that.description,_that.reporterName,_that.flaggedBy,_that.groupCount,_that.overrideComments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String submissionId,  String schoolName,  String activityTitle,  String flagReason,  ReportCategory category,  ReportStatus status,  DateTime createdAt,  String description,  String reporterName,  String? flaggedBy,  int? groupCount,  String? overrideComments)  $default,) {final _that = this;
switch (_that) {
case _ReportModel():
return $default(_that.id,_that.submissionId,_that.schoolName,_that.activityTitle,_that.flagReason,_that.category,_that.status,_that.createdAt,_that.description,_that.reporterName,_that.flaggedBy,_that.groupCount,_that.overrideComments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String submissionId,  String schoolName,  String activityTitle,  String flagReason,  ReportCategory category,  ReportStatus status,  DateTime createdAt,  String description,  String reporterName,  String? flaggedBy,  int? groupCount,  String? overrideComments)?  $default,) {final _that = this;
switch (_that) {
case _ReportModel() when $default != null:
return $default(_that.id,_that.submissionId,_that.schoolName,_that.activityTitle,_that.flagReason,_that.category,_that.status,_that.createdAt,_that.description,_that.reporterName,_that.flaggedBy,_that.groupCount,_that.overrideComments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportModel implements ReportModel {
  const _ReportModel({required this.id, required this.submissionId, required this.schoolName, required this.activityTitle, required this.flagReason, this.category = ReportCategory.theory, this.status = ReportStatus.pending, required this.createdAt, required this.description, required this.reporterName, this.flaggedBy, this.groupCount, this.overrideComments});
  factory _ReportModel.fromJson(Map<String, dynamic> json) => _$ReportModelFromJson(json);

@override final  String id;
@override final  String submissionId;
@override final  String schoolName;
@override final  String activityTitle;
@override final  String flagReason;
@override@JsonKey() final  ReportCategory category;
@override@JsonKey() final  ReportStatus status;
@override final  DateTime createdAt;
@override final  String description;
@override final  String reporterName;
@override final  String? flaggedBy;
@override final  int? groupCount;
@override final  String? overrideComments;

/// Create a copy of ReportModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportModelCopyWith<_ReportModel> get copyWith => __$ReportModelCopyWithImpl<_ReportModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportModel&&(identical(other.id, id) || other.id == id)&&(identical(other.submissionId, submissionId) || other.submissionId == submissionId)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.activityTitle, activityTitle) || other.activityTitle == activityTitle)&&(identical(other.flagReason, flagReason) || other.flagReason == flagReason)&&(identical(other.category, category) || other.category == category)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.reporterName, reporterName) || other.reporterName == reporterName)&&(identical(other.flaggedBy, flaggedBy) || other.flaggedBy == flaggedBy)&&(identical(other.groupCount, groupCount) || other.groupCount == groupCount)&&(identical(other.overrideComments, overrideComments) || other.overrideComments == overrideComments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,submissionId,schoolName,activityTitle,flagReason,category,status,createdAt,description,reporterName,flaggedBy,groupCount,overrideComments);

@override
String toString() {
  return 'ReportModel(id: $id, submissionId: $submissionId, schoolName: $schoolName, activityTitle: $activityTitle, flagReason: $flagReason, category: $category, status: $status, createdAt: $createdAt, description: $description, reporterName: $reporterName, flaggedBy: $flaggedBy, groupCount: $groupCount, overrideComments: $overrideComments)';
}


}

/// @nodoc
abstract mixin class _$ReportModelCopyWith<$Res> implements $ReportModelCopyWith<$Res> {
  factory _$ReportModelCopyWith(_ReportModel value, $Res Function(_ReportModel) _then) = __$ReportModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String submissionId, String schoolName, String activityTitle, String flagReason, ReportCategory category, ReportStatus status, DateTime createdAt, String description, String reporterName, String? flaggedBy, int? groupCount, String? overrideComments
});




}
/// @nodoc
class __$ReportModelCopyWithImpl<$Res>
    implements _$ReportModelCopyWith<$Res> {
  __$ReportModelCopyWithImpl(this._self, this._then);

  final _ReportModel _self;
  final $Res Function(_ReportModel) _then;

/// Create a copy of ReportModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? submissionId = null,Object? schoolName = null,Object? activityTitle = null,Object? flagReason = null,Object? category = null,Object? status = null,Object? createdAt = null,Object? description = null,Object? reporterName = null,Object? flaggedBy = freezed,Object? groupCount = freezed,Object? overrideComments = freezed,}) {
  return _then(_ReportModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,submissionId: null == submissionId ? _self.submissionId : submissionId // ignore: cast_nullable_to_non_nullable
as String,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,activityTitle: null == activityTitle ? _self.activityTitle : activityTitle // ignore: cast_nullable_to_non_nullable
as String,flagReason: null == flagReason ? _self.flagReason : flagReason // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ReportCategory,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,reporterName: null == reporterName ? _self.reporterName : reporterName // ignore: cast_nullable_to_non_nullable
as String,flaggedBy: freezed == flaggedBy ? _self.flaggedBy : flaggedBy // ignore: cast_nullable_to_non_nullable
as String?,groupCount: freezed == groupCount ? _self.groupCount : groupCount // ignore: cast_nullable_to_non_nullable
as int?,overrideComments: freezed == overrideComments ? _self.overrideComments : overrideComments // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
