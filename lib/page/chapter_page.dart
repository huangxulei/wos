import 'package:flutter/material.dart';

import '../database/search_item.dart';

class ChapterPage extends StatefulWidget {
  final SearchItem searchItem;

  const ChapterPage({Key key, this.searchItem}) : super(key: key);

  @override
  State<ChapterPage> createState() => _ChapterPageState(searchItem);
}

class _ChapterPageState extends State<ChapterPage> {
  _ChapterPageState(this.searchItem) : super();

  double opacity = 0.0;
  StateSetter state;
  final SearchItem searchItem;
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
    _controller = ScrollController();
    return Container();
  }

  static double lastTopHeight = 0.0;
  Widget _comicDetail(BuildContext context) {
    double _top = MediaQuery.of(context).padding.top;
    if (_top <= 0) {
      _top = lastTopHeight;
    } else {
      lastTopHeight = _top;
    }
  }
}
