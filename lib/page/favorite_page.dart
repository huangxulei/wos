import 'package:flutter/material.dart';
import 'package:wos/global.dart';
import 'package:wos/main.dart';
import 'package:wos/menu/menu_favorite.dart';
import 'package:wos/ui/round_indicator.dart';
import 'package:wos/wos_theme.dart';

import '../api/api.dart';
import '../menu/menu.dart';
import '../utils.dart';
import 'add_local_item_page.dart';
import 'setting/about_page.dart';
import 'favorite_list_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  var isLargeScreen = false;
  Widget detailPage;
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (MediaQuery.of(context).size.width > 600) {
        isLargeScreen = true;
      } else {
        isLargeScreen = false;
      }
      return Row(
        children: <Widget>[
          Expanded(
            child: FavoritePage2(
                //带一个widget
                invokeTap: (Widget detailPage) {
              if (isLargeScreen) {
                this.detailPage = detailPage;
                setState(() {});
              } else {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => detailPage));
              }
            }),
          ),
          SizedBox(
            height: double.infinity,
            width: 2,
            child: Material(
              color: Colors.grey.withAlpha(123),
            ),
          ),
          isLargeScreen
              ? Expanded(child: detailPage ?? Scaffold())
              : Container(),
        ],
      );
    });
  }
}

//左边导航栏
class FavoritePage2 extends StatelessWidget {
  final void Function(Widget) invokeTap;
  const FavoritePage2({Key key, this.invokeTap}) : super(key: key);

  static const tabs = [
    ["文字", API.NOVEL],
    ["图片", API.MANGA],
    ["音频", API.AUDIO],
    ["视频", API.VIDEO],
  ];

  @override
  Widget build(BuildContext context) {
    final profile = WOSTheme();
    if (Global.needShowAbout) {
      Global.needShowAbout = false;
      if (profile.version != profile.lastestVersion) {
        Future.delayed(Duration(microseconds: 10),
            () => AboutPage2.showAbout(context, true));
      }
    }
    return DefaultTabController(
        length: tabs.length,
        child: Container(
          decoration: globalDecoration,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              elevation: 0,
              title: TabBar(
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor:
                    Theme.of(context).textTheme.bodyText1.color,
                indicator: RoundTabIndicator(
                    insets: EdgeInsets.only(left: 5, right: 5),
                    borderSide: BorderSide(
                        width: 3.0, color: Theme.of(context).primaryColor)),
                tabs: tabs
                    .map((tab) => Container(
                          height: 30,
                          alignment: Alignment.center,
                          child: Text(
                            tab[0],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: WOSTheme.staticFontFamily),
                          ),
                        ))
                    .toList(),
              ),
              actions: <Widget>[
                Menu<MenuFavorite>(
                    tooltip: "选项",
                    items: favoriteMenus,
                    onSelect: (value) {
                      switch (value) {
                        case MenuFavorite.addItem:
                          Utils.startPageWait(context, AddLocalItemPage());
                          break;
                        case MenuFavorite.history:
                          // Utils.startPageWait(context, HistoryPage());
                          break;
                        case MenuFavorite.more_settings:
                          Utils.startPageWait(context, AboutPage());
                          break;
                        default:
                      }
                    }),
              ],
            ),
            body: TabBarView(
              children: tabs
                  .map((tab) =>
                      FavoriteListPage(type: tab[1], invokeTap: invokeTap))
                  .toList(),
            ),
          ),
        ));
  }
}
