import 'package:hive_flutter/hive_flutter.dart';
import 'global.dart';

final _box = Hive.box(Global.profileKey);
final globalConfigBox = _box;

const versionBox = "versionBox";
const fontFamilyBox = "fontFamilyBox";
const searchPostionBox = "searchPostionBox";
const switchLongPressBox = "switchLongPressBox";

const thDef = {
  versionBox: '',
  fontFamilyBox: '',
};

class WOSTheme {
  static final WOSTheme _profile = WOSTheme._internal();
  factory WOSTheme() => _profile;
  WOSTheme._internal();

  static const searchDocker = 0;
  static const searchFloat = 1;
  static const searchAction = 2;

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

  String get fontFamily =>
      _box.get(fontFamilyBox, defaultValue: thDef[fontFamilyBox]);
  set fontFamily(String value) {
    if (value != fontFamily) {
      _box.put(fontFamilyBox, cast(value, thDef[fontFamilyBox]));
    }
  }

  static String staticFontFamily;

  int get searchPostion =>
      _box.get(searchPostionBox, defaultValue: thDef[searchPostionBox]);
  set searchPostion(int value) {
    if (value != searchPostion) {
      _box.put(searchPostionBox, cast(value, thDef[searchPostionBox]));
    }
  }

  bool get switchLongPress =>
      _box.get(switchLongPressBox, defaultValue: thDef[switchLongPressBox]);
  set switchLongPress(bool value) {
    if (value != switchLongPress) {
      _box.put(switchLongPressBox, cast(value, thDef[switchLongPressBox]));
    }
  }
}

T cast<T>(x, T defaultValue) => x is T ? x : defaultValue; // 安全转换
