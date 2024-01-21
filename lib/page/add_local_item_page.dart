import 'dart:io';

import 'package:epubx/epubx.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:wos/main.dart';
import 'package:wos/utils/auto_decode_cli.dart';

import '../database/chapter_item.dart';
import '../utils/utils.dart';

class AddLocalItemPage extends StatefulWidget {
  final PlatformFile platformFile;
  const AddLocalItemPage({Key key, this.platformFile}) : super(key: key);

  @override
  State<AddLocalItemPage> createState() => _AddLocalItemPageState();
}

class _AddLocalItemPageState extends State<AddLocalItemPage> {
  PlatformFile platformFile;
  String content;
  EpubBook epubBook;
  TextEditingController textEditingController;
  TextEditingController textEditingControllerReg;
  final List<String> contents = <String>[];
  final defaultReg =
      "(\\s|\\n|^)(第)([\\u4e00-\\u9fa5a-zA-Z0-9]{1,7})[章|节|回|卷][^\\n]{1,35}(\\n|\$)";

  init() async {
    if (platformFile == null) {
      FilePickerResult result = await FilePicker.platform
          .pickFiles(withData: false, dialogTitle: "选择txt或者epub导入我搜");
      if (result == null) {
        Utils.toast("未选择文件");
        if (platformFile == null) {
          Navigator.of(context).pop();
          return;
        }
      } else {
        platformFile = result.files.first;
      }
    }
    if (platformFile.extension == "epub") {
      try {
        epubBook = await EpubReader.readBook(
            File(platformFile.path).readAsBytesSync());
        textEditingController.text = epubBook.Title;
      } catch (e) {
        Utils.toast("$e");
      }
      parseEpub();
    } else {
      if (platformFile.size ~/ 1024 > 20000) {
        Utils.toast('文件太大 放弃');
        return;
      }

      try {
        content = autoReadFile(platformFile.path);
        textEditingController.text = Utils.getFileName(platformFile.name);
        if (textEditingControllerReg.text.isEmpty) {
          textEditingControllerReg.text = defaultReg;
        }
      } catch (e) {
        Utils.toast("$e");
      }
    }
  }

  void parseEpub() {}

  //解析txt文件
  void parseText() {
    contents.clear();
    final chapters = <ChapterItem>[]; //章节
    var start = 0;
    var name = "";
    var i = 0;
    //正则txt文件
    for (var r in RegExp(textEditingControllerReg.text).allMatches(content)) {
      if (start == 0 && r.start > 0) {
        chapters.add(ChapterItem(name: "无名", url: "${i++}.txt"));
      }
      final tempName = content.substring(r.start, r.end).trim();
      if (tempName == name) continue;
      var temp = content.substring(start, r.start).trim();
      if (temp.startsWith(name)) {
        contents.add(temp.substring(name.length));
      } else {
        contents.add(temp);
      }
      start = r.end;
      name = tempName;
      chapters.add(ChapterItem(name: name, url: "${i++}.txt"));
    }
  }

  @override
  void initState() {
    platformFile = widget.platformFile;
    textEditingController = TextEditingController();
    textEditingControllerReg = TextEditingController();
    init();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController?.dispose();
    textEditingControllerReg?.dispose();
    contents.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: globalDecoration,
      child: Scaffold(
        appBar: AppBar(
          title: Text("导入本地txt或epub"),
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: InkWell(
              child: Text(
                "点击选择 ${platformFile?.extension} ${(platformFile?.size ?? 0) ~/ 1024}KB ${platformFile?.path}",
              ),
              onTap: init,
            ),
          ),
        ]),
      ),
    );
  }
}
