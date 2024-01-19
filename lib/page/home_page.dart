import 'package:flutter/material.dart';
import 'package:wos/page/page_switch.dart';
import 'package:provider/provider.dart';
import 'fonticons_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var isLargeScreen = false;
  int _nowIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (MediaQuery.of(context).size.width > 600) {
        isLargeScreen = true;
      } else {
        isLargeScreen = false;
      }
      return ChangeNotifierProvider(
        create: (context) => PageSwitch(_nowIndex),
        child: Consumer<PageSwitch>(builder:
            (BuildContext context, PageSwitch pageSwitch, Widget widget) {
          _nowIndex = pageSwitch.currentIndex;
          pageSwitch.updatePageController();
          final _pageView = PageView(
            controller: pageSwitch.pageController,
            onPageChanged: (index) => pageSwitch.changePage(index, false),
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              Page(name: "收藏", mColor: Colors.red), //收藏
              Page(name: "发现", mColor: Colors.blue),
              Page(name: "历史", mColor: Colors.green),
              Page(name: "关于", mColor: Colors.orange)
            ],
          );
          return Container(
              color: Theme.of(context).canvasColor,
              child: Scaffold(
                body: Stack(
                  children: [
                    _pageView,
                  ],
                ),
                bottomNavigationBar: BottomAppBar(
                    shape: CircularNotchedRectangle(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Expanded(
                                      child: TextButton(
                                    onPressed: () => pageSwitch.changePage(0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(FIcons.heart,
                                            color: getColor(
                                                pageSwitch, context, 0)),
                                        Text("收藏",
                                            style: TextStyle(
                                                color: getColor(
                                                    pageSwitch, context, 0)))
                                      ],
                                    ),
                                  )),
                                  Expanded(
                                      child: TextButton(
                                    onPressed: () => pageSwitch.changePage(1),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(FIcons.compass,
                                            color: getColor(
                                                pageSwitch, context, 1)),
                                        Text("发现",
                                            style: TextStyle(
                                                color: getColor(
                                                    pageSwitch, context, 1)))
                                      ],
                                    ),
                                  )),
                                ],
                              )),
                          if ((isLargeScreen)) Spacer(),
                          if ((isLargeScreen))
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Expanded(
                                      child: TextButton(
                                    onPressed: () => pageSwitch.changePage(2),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(Icons.history,
                                            color: getColor(
                                                pageSwitch, context, 2)),
                                        Text("历史",
                                            style: TextStyle(
                                                color: getColor(
                                                    pageSwitch, context, 2)))
                                      ],
                                    ),
                                  )),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () => pageSwitch.changePage(3),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Icon(Icons.info_outline_rounded,
                                              color: getColor(
                                                  pageSwitch, context, 3)),
                                          Text("关于",
                                              style: TextStyle(
                                                  color: getColor(
                                                      pageSwitch, context, 3)))
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    )),
              ));
        }),
      );
    });
  }
}

class Page extends StatelessWidget {
  String name;
  Color mColor;
  Page({Key key, this.name, this.mColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: mColor,
      child: Text(
        "${this.name}",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

Color getColor(PageSwitch pageSwitch, BuildContext context, int value) {
  return pageSwitch.currentIndex == value
      ? Theme.of(context).primaryColor
      : Theme.of(context).textTheme.bodyText1.color;
}
