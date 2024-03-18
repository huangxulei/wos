import 'package:hive_flutter/hive_flutter.dart';
import 'package:wos/database/chapter_item.dart';
import 'package:wos/utils.dart';

import '../global.dart';
import 'search_item.dart';

class SearchItemManager {
  static List<SearchItem> _searchItem;
  static String get key => Global.searchItemKey;

  static get searchItem => _searchItem;
  //初始化内容
  static void initSearchItem() {
    // _searchItem = <SearchItem>[];
    //保存在searchItem.hive中
    final sbox = Hive.box<SearchItem>(key);
    _searchItem = sbox.values.toList();
    for (SearchItem _item in _searchItem) {
      print(_item.name);
    }
  }

  static Future<bool> addSearchItem(SearchItem searchItem) async {
    _searchItem.removeWhere((element) => element.id == searchItem.id);
    _searchItem.add(searchItem);
    final sbox = Hive.box<SearchItem>(key);
    sbox.put(searchItem.id.toString(), searchItem);
    return true;
  }

  /// 根据类型和排序规则取出收藏
  static List<SearchItem> getSearchItemByType(
      int contentType, SortType sortType,
      [String tag]) {
    if (tag == "全部") {
      tag = null;
    }
    final searchItem = <SearchItem>[];
    _searchItem.forEach((element) {
      if (element.ruleContentType == contentType &&
          (tag == null || tag.isEmpty || element.tags.contains(tag)))
        searchItem.add(element);
    });
    //排序
    sortType = SortType.CREATE;
    switch (sortType) {
      case SortType.CREATE:
        searchItem.sort((a, b) => b.createTime.compareTo(a.createTime));
        break;
      case SortType.UPDATE:
        searchItem.sort((a, b) => b.updateTime.compareTo(a.updateTime));
        break;
      case SortType.LASTREAD:
        searchItem.sort((a, b) => b.lastReadTime.compareTo(a.lastReadTime));
        break;
    }
    return searchItem;
  }

  // static Future<void> refreshAll() async {
  //   // 先用单并发，加延时5s判定
  //   for (var item in _searchItem) {
  //     var current = item.name;
  //     await Future.any([
  //       refreshItem(item),
  //       (SearchItem temp) async {
  //         await Future.delayed(Duration(seconds: 5), () {
  //           if (current == temp.name) Utils.toast("${temp.name} 章节更新超时");
  //         });
  //       }(item),
  //     ]);
  //     current = null;
  //   }
  //   return;
  // }

  // static Future<void> refreshItem(SearchItem item) async {
  //   // if (item.chapters.isEmpty) {
  //   //   item.chapters = SearchItemManager.getChapter(item.id);
  //   // }
  //   List<ChapterItem> chapters;
  //   try {
  //     chapters = await APIManager.getChapter(item.originTag, item.url);
  //   } catch (e) {
  //     Utils.toast("${item.name} 章节获取失败");
  //     return;
  //   }
  //   if (chapters.isEmpty) {
  //     Utils.toast("${item.name} 章节为空");
  //     return;
  //   }
  //   final newCount = chapters.length - item.chapters.length;
  //   if (newCount > 0) {
  //     Utils.toast("${item.name} 新增 $newCount 章节");
  //     item.chapters = chapters;
  //     item.chapter = chapters.last?.name;
  //     item.chaptersCount = chapters.length;
  //     await item.save();
  //     // await SearchItemManager.saveChapter(item.id, item.chapters);
  //   } else {
  //     Utils.toast("${item.name} 无新增章节");
  //   }
  //   return;
  // }
}

enum SortType { UPDATE, CREATE, LASTREAD }
