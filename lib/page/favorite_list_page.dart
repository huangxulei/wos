import 'dart:convert';

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
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 6),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.55,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
      ),

      itemCount: list.length,
      // 遍历
      itemBuilder: (context, index) {
        final searchItem = list[index];
        return InkWell(
            child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(blurRadius: 8, color: Colors.white70)
                        ]),
                        padding: const EdgeInsets.all(6),
                        child: searchItem.cover == "nocover"
                            ? Image.asset(
                                'lib/assets/no_image.png',
                                width: 100,
                              )
                            : Image.memory(
                                base64Decode(searchItem.cover),
                                width: 100,
                              )),
                    SizedBox(height: 12),
                    Text(
                      '${searchItem.name}'.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        shadows: [Shadow(blurRadius: 2, color: Colors.grey)],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      searchItem.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyText1.color,
                      ),
                    ),
                  ],
                )));
      },
    );
  }
}
