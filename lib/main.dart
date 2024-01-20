import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oktoast/oktoast.dart';
import 'global.dart';
import 'hive/theme_mode_box.dart';
import 'page/first_page.dart';
import 'page/home_page.dart';
import 'theme_box.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //在安装目录 windows下面 电脑 文档/eso
  await Hive.initFlutter("wos");
  await openThemeModeBox(); //初始化一个box

  runApp(const MyApp());
}

BoxDecoration globalDecoration;

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StackTrace _stackTrace;
  dynamic _error;

  InitFlag initFlag = InitFlag.wait;

  @override
  void initState() {
    super.initState();
    () async {
      try {
        await openThemeBox(); //打开样式
        // 设置刷新率
        if (displayHighRate) {
          await FlutterDisplayMode.setHighRefreshRate();
        } else if (displayMode.refreshRate > 1) {
          await FlutterDisplayMode.setPreferredMode(displayMode);
        }
        await Global.init();
        Future.delayed(Duration(seconds: 3), () {
          print("延迟3钟后输出");
          initFlag = InitFlag.ok;
          setState(() {}); //刷新布局 initFlag 改变
        });
      } catch (e, st) {
        _error = e;
        _stackTrace = st;
        initFlag = InitFlag.error;
        setState(() {});
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<int>>(
      valueListenable: themeModeBox.listenable(),
      builder: (BuildContext context, Box<int> _, Widget child) {
        final _themeMode = ThemeMode.values[themeMode];
        switch (initFlag) {
          case InitFlag.ok:
            return OKToast(
                textStyle: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
                backgroundColor: Colors.black.withOpacity(0.8),
                radius: 20.0,
                textPadding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: MaterialApp(
                    navigatorKey: navigatorKey,
                    title: Global.appName,
                    theme: getGlobalThemeData(),
                    darkTheme: getGlobalDarkThemeData(),
                    home: HomePage()));
          case InitFlag.error:
            return MaterialApp(
              themeMode: _themeMode,
              darkTheme: ThemeData.dark(),
              scrollBehavior: MyCustomScrollBehavior(),
              title: Global.appName,
              home: ErrorApp(error: _error, stackTrace: _stackTrace),
            );
          default:
            return MaterialApp(
              themeMode: _themeMode,
              darkTheme: ThemeData.dark(),
              scrollBehavior: MyCustomScrollBehavior(),
              title: Global.appName,
              home: FirstPage(),
            );
        }
      },
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}

class ErrorApp extends StatelessWidget {
  final error;
  final stackTrace;
  const ErrorApp({Key key, this.error, this.stackTrace}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: MyCustomScrollBehavior(),
      home: Scaffold(
        body: ListView(
          children: [
            Text(
              "$error\n$stackTrace",
              style: TextStyle(color: Color(0xFFF56C6C)),
            )
          ],
        ),
      ),
    );
  }
}
