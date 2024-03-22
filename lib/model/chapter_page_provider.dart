import 'package:flutter/material.dart';
import '../database/search_item.dart';
import '../database/search_item_manager.dart';

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
