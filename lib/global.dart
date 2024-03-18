import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'database/search_item.dart';
import 'database/search_item_manager.dart';
import 'hive/search_item_adapter.dart';

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
  static const favoriteListTagKey = "favoriteListTag";
  static const searchItemKey = "searchItem";
  static bool _isDesktop;
  static bool get isDesktop => _isDesktop;
  static Color primaryColor;

  static Future<bool> init() async {
    Hive.registerAdapter(SearchItemAdapter());
    await Hive.openBox(Global.profileKey);
    await Hive.openBox(Global.textConfigKey);
    await initSearchItem();
    print("delay global init");
    return true;
  }

  static Future<void> initSearchItem() async {
    const key = Global.searchItemKey;
    final sbox = await Hive.openBox<SearchItem>(key); //获取数据
    SearchItemManager.initSearchItem(); //控制器那边保存数据
  }
}
