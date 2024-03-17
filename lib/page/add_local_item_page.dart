import 'dart:convert';
import 'dart:io';
import 'package:epubx/epubx.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:wos/utils/auto_decode_cli.dart';
import 'package:image/image.dart' as image;
import 'package:flutter/src/widgets/image.dart' as img;
import 'package:path/path.dart' as path;
import '../api/api.dart';
import '../database/chapter_item.dart';
import '../database/search_item.dart';
import '../database/search_item_manager.dart';
import '../utils/cache_util.dart';
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
  SearchItem searchItem;
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
        // Image.memory(base64Decode(searchItem?.cover), width: 180,),
        searchItem = SearchItem(
          cover: epubBook.CoverImage != null
              ? base64Encode(image.encodePng(epubBook.CoverImage))
              : "nocover",
          name: epubBook.Title,
          author: epubBook.Author,
          chapter:
              epubBook.Chapters.isNotEmpty ? epubBook.Chapters.last.Title : "",
          description: "",
          url: platformFile.path,
          api: BaseAPI(
              origin: "本地", originTag: "本地", ruleContentType: API.NOVEL),
          tags: [],
        );
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

  void parseEpubChapter(List<ChapterItem> c, List<EpubChapter> chapters) {
    for (var chapter in chapters) {
      //获取每章的内容
      var temp = chapter.HtmlContent;
      contents.add(temp.trimLeft());
      c.add(ChapterItem(name: chapter.Title, url: "${contents.length}.txt"));
      if (chapter.SubChapters.isNotEmpty) {
        parseEpubChapter(c, chapter.SubChapters);
      }
    }
  }

  void parseEpub() {
    // searchItem.chapters?.clear();
    contents.clear();
    searchItem.chapters = <ChapterItem>[];
    parseEpubChapter(searchItem.chapters, epubBook.Chapters);
    searchItem.chaptersCount = searchItem.chapters.length;
    setState(() {});
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
        child: Scaffold(
            appBar: AppBar(
              title: Text("导入本地txt或epub"),
            ),
            body:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  child: Text(
                    "点击选择 ${platformFile?.extension} ${(platformFile?.size ?? 0) ~/ 1024}KB ${platformFile?.path}",
                  ),
                  onTap: init,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text("书名："),
                    Expanded(
                      child: TextField(
                        controller: textEditingController,
                        onChanged: (value) {
                          searchItem.name = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(spacing: 10, alignment: WrapAlignment.start, children: [
                TextButton(
                  onPressed: () async {
                    // 写入文件
                    final cache = CacheUtil(
                        basePath:
                            "cache${Platform.pathSeparator}${searchItem.id}");
                    final dir = await cache.cacheDir();
                    final d = Directory(dir);
                    if (!d.existsSync()) {
                      d.createSync(recursive: true);
                    }
                    print("写入文件中 $dir");
                    final reg = RegExp(r"^\s*|(\s{2,}|\n)\s*");
                    for (var i = 0; i < contents.length; i++) {
                      File(path.join(dir, '$i.txt')).writeAsStringSync(
                          contents[i]
                              .split(reg)
                              .map((s) => s.trimLeft())
                              .join("\n"));
                    }
                    //写入div中
                    SearchItemManager.addSearchItem(searchItem);
                    print("成功");
                  },
                  child: Text("导入"),
                ),
              ]),
              Expanded(
                  child: Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    child: searchItem?.cover == "nocover"
                        ? img.Image.asset(
                            'lib/assets/no_image.png',
                            width: 180,
                          )
                        : img.Image.memory(
                            base64Decode(searchItem?.cover),
                            width: 180,
                          ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            searchItem.name,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.black54,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(searchItem.author)
                        ],
                      )
                    ],
                  )
                ],
              )),
              Expanded(
                child: Card(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemExtent: 26,
                    itemCount: searchItem?.chapters?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        height: 26,
                        child: Text(
                            "${(index + 1).toString().padLeft(4)}   ${searchItem.chapters[index].name}"),
                      );
                    },
                  ),
                ),
              ),
            ])));
  }
}
