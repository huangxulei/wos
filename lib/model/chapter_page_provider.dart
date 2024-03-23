import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../database/search_item.dart';
import '../database/search_item_manager.dart';
import '../global.dart';
import '../menu/menu_chapter.dart';
import '../utils.dart';
import '../utils/cache_util.dart';

class ChapterPageProvider with ChangeNotifier {
  final Size size;
  final SearchItem searchItem;
  ScrollController _controller;
  ScrollController get controller => _controller;

  bool get isLoading => _isLoading;
  bool _isLoading;

  static const BigList = 0;
  static const SmallList = 1;
  static const Grid = 2;

  ChapterPageProvider({@required this.searchItem, @required this.size}) {
    _controller = ScrollController();
    _isLoading = false;
  }

  void adjustScroll() {
    notifyListeners();
  }

  //改变
  void changeChapter(int index) async {
    if (searchItem.durChapterIndex != index) {
      searchItem.durChapterIndex = index;
      searchItem.durChapter = searchItem.chapters[index].name;
      searchItem.durContentIndex = 1;
      await searchItem.save();
      notifyListeners();
    }
  }

  void toggleFavorite() async {
    if (_isLoading) return;
    await SearchItemManager.toggleFavorite(searchItem);
    notifyListeners();
  }

  void onSelect(MenuChapter value, BuildContext context) async {
    if (value == null) return;
    switch (value) {
      case MenuChapter.copy_dec:
        await Clipboard.setData(ClipboardData(text: searchItem.description));
        Utils.toast("已复制");
        break;
      case MenuChapter.clear_cache:
        final _fileCache = CacheUtil(
            basePath: "cache${Platform.pathSeparator}${searchItem.id}");
        await CacheUtil.requestPermission();
        await _fileCache.clear();
        Utils.toast("清理成功");
        break;
      case MenuChapter.edit:
        Utils.toast("请等待下个版本");
        break;
      case MenuChapter.share:
        Share.share(
            '${searchItem.name.trim()}\n${searchItem.author.trim()}\n\n${searchItem.description}\n${searchItem.chapterUrl}');
        break;
      default:
        Utils.toast("该选项功能未实现${value}");
    }
  }

  void scrollerToTop() {
    _controller.jumpTo(1);
  }

  void scrollerToBottom() {
    _controller.jumpTo(_controller.position.maxScrollExtent - 1);
  }

  void toggleReverse() {
    searchItem.reverseChapter = !searchItem.reverseChapter;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
