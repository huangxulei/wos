import 'package:flutter/material.dart';
import 'package:wos/database/search_item_manager.dart';

import '../database/search_item.dart';

class FavoriteListPage extends StatelessWidget {
  final void Function(Widget) invokeTap;
  final int type;
  const FavoriteListPage({this.type, Key key, this.invokeTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<SearchItem> list = SearchItemManager.searchItem;
    return ListView.builder(
      // 长度
      itemCount: list.length,
      // 遍历
      itemBuilder: (context, index) {
        return Text(list[index].name);
      },
    );
  }
}
