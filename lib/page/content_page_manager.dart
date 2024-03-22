import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wos/api/api.dart';

import '../database/search_item.dart';
import '../utils/cache_util.dart';
import '../utils/memory_cache.dart';
import 'novel_page_refactor.dart';

class ContentPageRoute {
  MaterialPageRoute route(SearchItem searchItem) {
    searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
    return MaterialPageRoute(builder: (context) {
      return ChangeNotifierProvider<ContentProvider>(
          create: (context) => ContentProvider(searchItem), //数据加载
          builder: (context, child) {
            final provider = Provider.of<ContentProvider>(context);
            switch (searchItem.ruleContentType) {
              case API.NOVEL:
                return NovelPage(searchItem: searchItem);
              default:
                throw ('${searchItem.ruleContentType} not support !');
            }
          });
    });
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

  Future<List<String>> loadChapter(int chapterIndex) {
    final r = _memoryCache.getValueOrSet(chapterIndex, () async {
      final resp = await _cache.getData('$chapterIndex.txt',
          hashCodeKey: false, shouldDecode: false);
      if (resp != null && resp is String && resp.isNotEmpty) {
        return resp.split("\n");
      } else {
        return <String>[];
      }
    });

    return r;
  }

  Future<void> retryUseCache() async {
    _cache =
        CacheUtil(basePath: "cache${Platform.pathSeparator}${searchItem.id}");
    _canUseCache = await CacheUtil.requestPermission();
  }
}
