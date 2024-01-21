import 'package:about/about.dart';
import 'package:flutter/material.dart';
import 'package:wos/main.dart';

import '../../global.dart';
import '../../wos_theme.dart';
import '../add_local_item_page.dart';
import 'display_high_rate.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
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
          Expanded(child: AboutPage2(invokeTap: (Widget detailPage) {
            if (isLargeScreen) {
              this.detailPage = detailPage;
              setState(() {});
            } else {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => detailPage));
            }
          })),
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

class AboutPage2 extends StatelessWidget {
  final void Function(Widget) invokeTap;

  const AboutPage2({Key key, this.invokeTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: globalDecoration,
      child: Scaffold(
        appBar: AppBar(
          title: Text(Global.appName),
        ),
        body: () {
          final profile = WOSTheme();
          return ListView(
            children: <Widget>[
              Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text('设置',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor)),
                    ),
                    Divider(),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 16),
                      title: Text("刷新率设置"),
                      subtitle: Text(
                        "一加的部分机型可能需要",
                      ),
                      onTap: () => invokeTap(DisplayHighRate()),
                    ),
                    ListTile(
                      title: Text('本地导入'),
                      subtitle: Text('导入txt或者epub'),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddLocalItemPage(),
                          )),
                    ),
                  ],
                ),
              ),
              Card(
                  child: Material(
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0)),
                      child: InkWell(
                        //水波纹效果
                        onTap: () => showAbout(context),
                        child: SizedBox(
                          height: 260,
                          width: double.infinity,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'ESO',
                                  style: TextStyle(
                                    fontSize: 100,
                                    fontStyle: FontStyle.italic,
                                    color: Theme.of(context).cardColor,
                                  ),
                                ),
                                Text(
                                  '亦搜，亦看，亦闻',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Theme.of(context).cardColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ))),
              SizedBox(
                height: 4,
              )
            ],
          );
        }(),
      ),
    );
  }

  static void showAbout(BuildContext context, [bool showClose = false]) =>
      showAboutDialog(
          context: context,
          applicationLegalese:
              '版本 ${Global.appVersion}\n版号 ${Global.appBuildNumber}\n包名 ${Global.appPackageName}',
          applicationIcon: Image.asset(
            Global.logoPath,
            width: 50,
            height: 50,
          ),
          applicationVersion: '亦搜，亦看，亦闻',
          children: <Widget>[
            MarkdownPageListTile(
              filename: 'README.md',
              title: Text('使用指北'),
              icon: Icon(Icons.info_outline),
            ),
            MarkdownPageListTile(
              filename: 'CHANGELOG.md',
              title: Text('更新日志'),
              icon: Icon(Icons.history),
            ),
            if (showClose)
              InkWell(
                child: ListTile(
                  leading: Icon(Icons.close),
                  title: Text("不再显示"),
                ),
                onTap: () {
                  WOSTheme().updateVersion();
                  //Utils.toast("在设置中可再次查看");
                  Navigator.of(context).pop();
                },
              ),
          ]);
}
