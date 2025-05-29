// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppSettings {

 ThemeMode get themeMode; String get language; String get region; bool get pushNotifications; bool get emailNotifications; bool get smsNotifications; bool get biometricAuth; bool get twoFactorAuth; bool get autoSync; bool get wifiOnlyDownloads;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.language, language) || other.language == language)&&(identical(other.region, region) || other.region == region)&&(identical(other.pushNotifications, pushNotifications) || other.pushNotifications == pushNotifications)&&(identical(other.emailNotifications, emailNotifications) || other.emailNotifications == emailNotifications)&&(identical(other.smsNotifications, smsNotifications) || other.smsNotifications == smsNotifications)&&(identical(other.biometricAuth, biometricAuth) || other.biometricAuth == biometricAuth)&&(identical(other.twoFactorAuth, twoFactorAuth) || other.twoFactorAuth == twoFactorAuth)&&(identical(other.autoSync, autoSync) || other.autoSync == autoSync)&&(identical(other.wifiOnlyDownloads, wifiOnlyDownloads) || other.wifiOnlyDownloads == wifiOnlyDownloads));
}


@override
int get hashCode => Object.hash(runtimeType,themeMode,language,region,pushNotifications,emailNotifications,smsNotifications,biometricAuth,twoFactorAuth,autoSync,wifiOnlyDownloads);

@override
String toString() {
  return 'AppSettings(themeMode: $themeMode, language: $language, region: $region, pushNotifications: $pushNotifications, emailNotifications: $emailNotifications, smsNotifications: $smsNotifications, biometricAuth: $biometricAuth, twoFactorAuth: $twoFactorAuth, autoSync: $autoSync, wifiOnlyDownloads: $wifiOnlyDownloads)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 ThemeMode themeMode, String language, String region, bool pushNotifications, bool emailNotifications, bool smsNotifications, bool biometricAuth, bool twoFactorAuth, bool autoSync, bool wifiOnlyDownloads
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? themeMode = null,Object? language = null,Object? region = null,Object? pushNotifications = null,Object? emailNotifications = null,Object? smsNotifications = null,Object? biometricAuth = null,Object? twoFactorAuth = null,Object? autoSync = null,Object? wifiOnlyDownloads = null,}) {
  return _then(_self.copyWith(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,pushNotifications: null == pushNotifications ? _self.pushNotifications : pushNotifications // ignore: cast_nullable_to_non_nullable
as bool,emailNotifications: null == emailNotifications ? _self.emailNotifications : emailNotifications // ignore: cast_nullable_to_non_nullable
as bool,smsNotifications: null == smsNotifications ? _self.smsNotifications : smsNotifications // ignore: cast_nullable_to_non_nullable
as bool,biometricAuth: null == biometricAuth ? _self.biometricAuth : biometricAuth // ignore: cast_nullable_to_non_nullable
as bool,twoFactorAuth: null == twoFactorAuth ? _self.twoFactorAuth : twoFactorAuth // ignore: cast_nullable_to_non_nullable
as bool,autoSync: null == autoSync ? _self.autoSync : autoSync // ignore: cast_nullable_to_non_nullable
as bool,wifiOnlyDownloads: null == wifiOnlyDownloads ? _self.wifiOnlyDownloads : wifiOnlyDownloads // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc


class _AppSettings implements AppSettings {
  const _AppSettings({this.themeMode = ThemeMode.system, this.language = 'English', this.region = 'Algeria', this.pushNotifications = true, this.emailNotifications = true, this.smsNotifications = false, this.biometricAuth = true, this.twoFactorAuth = false, this.autoSync = true, this.wifiOnlyDownloads = false});
  

@override@JsonKey() final  ThemeMode themeMode;
@override@JsonKey() final  String language;
@override@JsonKey() final  String region;
@override@JsonKey() final  bool pushNotifications;
@override@JsonKey() final  bool emailNotifications;
@override@JsonKey() final  bool smsNotifications;
@override@JsonKey() final  bool biometricAuth;
@override@JsonKey() final  bool twoFactorAuth;
@override@JsonKey() final  bool autoSync;
@override@JsonKey() final  bool wifiOnlyDownloads;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.language, language) || other.language == language)&&(identical(other.region, region) || other.region == region)&&(identical(other.pushNotifications, pushNotifications) || other.pushNotifications == pushNotifications)&&(identical(other.emailNotifications, emailNotifications) || other.emailNotifications == emailNotifications)&&(identical(other.smsNotifications, smsNotifications) || other.smsNotifications == smsNotifications)&&(identical(other.biometricAuth, biometricAuth) || other.biometricAuth == biometricAuth)&&(identical(other.twoFactorAuth, twoFactorAuth) || other.twoFactorAuth == twoFactorAuth)&&(identical(other.autoSync, autoSync) || other.autoSync == autoSync)&&(identical(other.wifiOnlyDownloads, wifiOnlyDownloads) || other.wifiOnlyDownloads == wifiOnlyDownloads));
}


@override
int get hashCode => Object.hash(runtimeType,themeMode,language,region,pushNotifications,emailNotifications,smsNotifications,biometricAuth,twoFactorAuth,autoSync,wifiOnlyDownloads);

@override
String toString() {
  return 'AppSettings(themeMode: $themeMode, language: $language, region: $region, pushNotifications: $pushNotifications, emailNotifications: $emailNotifications, smsNotifications: $smsNotifications, biometricAuth: $biometricAuth, twoFactorAuth: $twoFactorAuth, autoSync: $autoSync, wifiOnlyDownloads: $wifiOnlyDownloads)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 ThemeMode themeMode, String language, String region, bool pushNotifications, bool emailNotifications, bool smsNotifications, bool biometricAuth, bool twoFactorAuth, bool autoSync, bool wifiOnlyDownloads
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? themeMode = null,Object? language = null,Object? region = null,Object? pushNotifications = null,Object? emailNotifications = null,Object? smsNotifications = null,Object? biometricAuth = null,Object? twoFactorAuth = null,Object? autoSync = null,Object? wifiOnlyDownloads = null,}) {
  return _then(_AppSettings(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,pushNotifications: null == pushNotifications ? _self.pushNotifications : pushNotifications // ignore: cast_nullable_to_non_nullable
as bool,emailNotifications: null == emailNotifications ? _self.emailNotifications : emailNotifications // ignore: cast_nullable_to_non_nullable
as bool,smsNotifications: null == smsNotifications ? _self.smsNotifications : smsNotifications // ignore: cast_nullable_to_non_nullable
as bool,biometricAuth: null == biometricAuth ? _self.biometricAuth : biometricAuth // ignore: cast_nullable_to_non_nullable
as bool,twoFactorAuth: null == twoFactorAuth ? _self.twoFactorAuth : twoFactorAuth // ignore: cast_nullable_to_non_nullable
as bool,autoSync: null == autoSync ? _self.autoSync : autoSync // ignore: cast_nullable_to_non_nullable
as bool,wifiOnlyDownloads: null == wifiOnlyDownloads ? _self.wifiOnlyDownloads : wifiOnlyDownloads // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
