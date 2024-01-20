import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Global with ChangeNotifier {
  static String appName = '我搜';
  static String appVersion = '1.20.4';
  static String appBuildNumber = '12004';
  static String appPackageName = "com.mabdc.eso";

  static const waitingPath = "lib/assets/waiting.png";
  static const logoPath = "lib/assets/eso_logo.png";

  static const profileKey = "profile";
  static const textConfigKey = "textConfig";
  static bool needShowAbout = true;

  static Future<bool> init() async {
    await Hive.openBox(Global.profileKey);
    await Hive.openBox(Global.textConfigKey);
    print("delay global init");
    return true;
  }
}
