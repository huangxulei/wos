import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:wos/main.dart';
import 'package:wos/theme_box.dart';

class DisplayHighRate extends StatefulWidget {
  const DisplayHighRate({Key key}) : super(key: key);

  @override
  State<DisplayHighRate> createState() => _DisplayHighRateState();
}

class _DisplayHighRateState extends State<DisplayHighRate> {
  var supportedModes = <DisplayMode>[];
  DisplayMode preferredMode;
  DisplayMode activeMode;

  @override
  void initState() {
    super.initState();
    () async {
      supportedModes = await FlutterDisplayMode.supported;
      refreshUI();
    }();
  }

  refreshUI() async {
    preferredMode = await FlutterDisplayMode.preferred;
    activeMode = await FlutterDisplayMode.active;
    displayMode = preferredMode;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: globalDecoration,
      child: Scaffold(
        appBar: AppBar(
          title: Text("刷新率设置"),
        ),
        body: ListView(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              title: Text("强制高刷"),
              subtitle: Text(
                "一加的部分机型可能需要，正常不需要启用",
              ),
              value: displayHighRate,
              onChanged: (value) async {
                if (value) {
                  await FlutterDisplayMode.setHighRefreshRate();
                } else {
                  await FlutterDisplayMode.setLowRefreshRate();
                }
                themeBox.put(displayHighRateKey, value);
                refreshUI();
              },
            ),
            Divider(),
            ListTile(
                title: Text(
              "当前设备支持的刷新模式",
              style: TextStyle(fontSize: 24),
            )),
          ],
        ),
      ),
    );
  }
}
