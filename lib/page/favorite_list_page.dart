import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wos/database/search_item_manager.dart';
import '../api/api.dart';
import '../database/search_item.dart';
import '../ui/widget/image_place_holder.dart';
import '../wos_theme.dart';
import 'chapter_page.dart';

class FavoriteListPage extends StatelessWidget {
  final void Function(Widget) invokeTap;
  final int type;
  const FavoriteListPage({this.type, Key key, this.invokeTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<SearchItem> list = SearchItemManager.searchItem;
    final _size = MediaQuery.of(context).size;
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 6),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),

      itemCount: list.length,
      // 遍历
      itemBuilder: (context, index) {
        final searchItem = list[index];
        final longPress = _size.width > 600 || WOSTheme().switchLongPress;
        VoidCallback openChapter = () => invokeTap(ChapterPage(
              searchItem: searchItem,
              key: Key(searchItem.id.toString()),
            ));
        VoidCallback openContent = () => print('打开内容');
        return InkWell(
            onTap: longPress ? openChapter : openContent,
            child: _ui_favorite_item(searchItem));
      },
    );
  }

  Widget _ui_favorite_item(SearchItem searchItem) {
    final count = searchItem.chaptersCount.toString();
    final currentCount = searchItem.durChapterIndex + 1;
    final suffix = {
      API.NOVEL: "章",
      API.MANGA: "话",
      API.AUDIO: "首",
      API.VIDEO: "集",
    };
    return Flex(direction: Axis.vertical, children: <Widget>[
      Expanded(
        child: Container(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          width: double.maxFinite,
          child: searchItem.cover == "nocover"
              ? ImagePlaceHolder(height: 80, width: 80)
              : Image.memory(
                  base64Decode(searchItem.cover),
                  width: 80,
                ),
        ),
      ),
      SizedBox(height: 6),
      Container(
        alignment: Alignment.center,
        child: Text(
          '${searchItem.name}'.trim(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
          alignment: Alignment.center,
          child: Text(
            '${"0" * (count.length - currentCount.toString().length)}$currentCount${suffix[searchItem.ruleContentType]}/$count${suffix[searchItem.ruleContentType]}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
    ]);
  }
}
