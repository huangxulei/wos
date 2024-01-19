import 'package:flutter/material.dart';

class Global with ChangeNotifier {
  static String appName = '我搜';
  static String appVersion = '1.20.4';
  static String appBuildNumber = '12004';
  static String appPackageName = "com.mabdc.eso";

  static const waitingPath = "lib/assets/waiting.png";
  static const logoPath = "lib/assets/eso_logo.png";

  static const profileKey = "profile";
}
