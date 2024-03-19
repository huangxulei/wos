import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/search_item.dart';
import '../utils/cache_util.dart';
import '../utils/memory_cache.dart';

class ContentPageRoute {
  MaterialPageRoute route(SearchItem searchItem) {
    searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
    return MaterialPageRoute(builder: (context) {});
  }
}

class ContentProvider with ChangeNotifier {
  final SearchItem searchItem;

  String _info;
  String get info => _info;
  bool _showInfo;
  bool get showInfo => _showInfo != false;

  CacheUtil _cache;
  CacheUtil get cache => _cache;
  bool _canUseCache;
  bool get canUseCache => _canUseCache == true;

  final MemoryCache<int, List<String>> _memoryCache;

  ContentProvider(this.searchItem) : _memoryCache = MemoryCache(cacheSize: 30) {
    _info = "";
    _addInfo("获取书籍信息 (内容可复制)");
    init();
  }

  Future<void> init() async {
    try {
      _cache =
          CacheUtil(basePath: "cache${Platform.pathSeparator}${searchItem.id}");
      _canUseCache = await CacheUtil.requestPermission();
      if (_canUseCache != true) _addInfo("权限检查失败 本地缓存需要存储权限");
      _showInfo = false;
      notifyListeners();
    } catch (e, st) {
      _addInfo(e);
      _addInfo("$st");
    }
  }

  final _format = DateFormat("HH:mm:ss");
  _addInfo(String s) {
    _info += "\n[${_format.format(DateTime.now())}] $s";
    notifyListeners();
  }
}
