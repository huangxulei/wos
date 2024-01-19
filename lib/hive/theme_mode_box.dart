import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

//状态管理 等待 ok 报错
enum InitFlag { wait, ok, error }

//初始化数据库
const _name = "themeModeBox";
Future<Box<int>> openThemeModeBox() => Hive.openBox<int>(_name);
final themeModeBox = Hive.box<int>(_name);
//默认主题
const _themeMode = "themeMode";
int get themeMode =>
    themeModeBox.get(_themeMode, defaultValue: ThemeMode.system.index);
set themeMode(int val) {
  if (null != val && val != themeMode) themeModeBox.put(_themeMode, val);
}
