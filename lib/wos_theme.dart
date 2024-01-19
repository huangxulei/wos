import 'package:hive_flutter/hive_flutter.dart';
import 'global.dart';

final _box = Hive.box(Global.profileKey);
final globalConfigBox = _box;

const versionBox = "versionBox";

const thDef = {
  versionBox: '',
};

class WOSTheme {
  static final WOSTheme _profile = WOSTheme._internal();
  factory WOSTheme() => _profile;
  WOSTheme._internal();

  String get version => _box.get(versionBox, defaultValue: thDef[versionBox]);
  set version(String value) {
    if (value != version) {
      _box.put(versionBox, cast(value, thDef[versionBox]));
    }
  }

  String get lastestVersion => '${Global.appVersion}+${Global.appBuildNumber}';

  void updateVersion() {
    version = lastestVersion;
  }
}

T cast<T>(x, T defaultValue) => x is T ? x : defaultValue; // 安全转换
