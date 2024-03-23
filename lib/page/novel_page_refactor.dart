import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:wos/page/setting/about_page.dart';

import '../database/search_item.dart';
import 'package:text_composition/text_composition.dart';

import '../database/text_config_manager.dart';
import '../ui/ui_chapter_select.dart';
import '../utils.dart';
import '../utils/flutter_slider.dart';
import 'content_page_manager.dart';
import 'package:win32/win32.dart';

import 'fonticons_icons.dart';

class NovelPage extends StatefulWidget {
  final SearchItem searchItem;

  const NovelPage({Key key, this.searchItem}) : super(key: key);
  @override
  State<NovelPage> createState() => _NovelPageState();
}

class _NovelPageState extends State<NovelPage> {
  SearchItem searchItem;
  TextCompositionConfig _config;

  @override
  void initState() {
    super.initState();
    _config = TextConfigManager.config;
    searchItem = widget.searchItem;
  }

  @override
  void dispose() {
    TextConfigManager.config = _config; //退出保存设置
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ContentProvider>(context);
    final bookName = "${searchItem.name}(${searchItem.origin})";
    return Container(child: LayoutBuilder(builder: (context, constrains) {
      final controller = TextComposition(
        config: _config,
        loadChapter: provider.loadChapter, //载入数据
        chapters: searchItem.chapters.map((e) => e.name).toList(),
        percent: () {
          final p = searchItem.durContentIndex / NovelContentTotal;
          final ch = (p * searchItem.chapters.length).floor();
          if (ch == searchItem.durChapterIndex) return p;
          return searchItem.durChapterIndex / searchItem.chapters.length;
        }(),
        onSave: (TextCompositionConfig config, double percent) async {
          if (percent > 0.0000001) {
            percent -= 0.0000001;
          }
          _config = config;
          searchItem.durContentIndex = (percent * NovelContentTotal).floor();
          final index = (percent * searchItem.chapters.length).floor();
          if (searchItem.durChapterIndex != index) {
            searchItem.durChapterIndex = index;
            searchItem.durChapter = searchItem.chapters[index].name;
            await searchItem.save();
          }
        },
        name: bookName,
        menuBuilder: (TextComposition composition) =>
            NovelMenu(searchItem: searchItem, composition: composition),
      );
      return TextCompositionPage(controller: controller);
    }));
  }
}

int speakingCheck = -1;

class SpeakService {
  static SpeakService _;
  static SpeakService get instance => SpeakService.createInstance();
  factory SpeakService.createInstance() => _ ??= SpeakService.__();
  SpeakService.__() {
    _rate = 0;
    if (!Platform.isWindows) {
      tts = FlutterTts();
      tts.awaitSpeakCompletion(true);
    }
    () async {
      range = await tts.getSpeechRateValidRange;
      print(range);
    }();
  }

  FlutterTts tts;
  SpVoice spVoice;
  int _rate;
  int get rate => _rate;
  SpeechRateValidRange range =
      SpeechRateValidRange(0, 0.5, 1, TextToSpeechPlatform.android);

  static int speakStatic(List l) {
    final int address = l[0];
    final String s = l[1];
    final ptr = Pointer<COMObject>.fromAddress(address);
    final spVoice = SpVoice(ptr);
    final pwcs = s.toNativeUtf16();
    try {
      return spVoice.Speak(pwcs,
          SPEAKFLAGS.SPF_PURGEBEFORESPEAK | SPEAKFLAGS.SPF_IS_NOT_XML, nullptr);
    } finally {
      free(pwcs);
    }
  }

  speak(String text) async {
    if (!Platform.isWindows) return tts.speak(text);
    freeSpVoice();
    spVoice = SpVoice.createInstance();
    spVoice.SetRate(rate);
    return 0 == await compute(speakStatic, [spVoice.ptr.address, text]);
  }

  stop() async {
    if (!Platform.isWindows) return tts.stop();
    return 0 == spVoice?.Pause();
  }

  addRate() {
    if (rate < 5) {
      _rate++;
      if (!Platform.isWindows)
        return tts.setSpeechRate(
            range.min + (range.max - range.min) * (_rate + 5) / 10);
      return 0 == spVoice?.SetRate(rate);
    }
    return false;
  }

  minusRate() {
    if (rate > -5) {
      _rate--;
      if (!Platform.isWindows)
        return tts.setSpeechRate(
            range.min + (range.max - range.min) * (_rate + 5) / 10);
      return 0 == spVoice?.SetRate(rate);
    }
    return false;
  }

  resetRate() {
    if (rate != 0) {
      _rate = 0;
      if (!Platform.isWindows) return tts.setSpeechRate(range.normal);
      return 0 == spVoice?.SetRate(rate);
    }
    return false;
  }

  freeSpVoice() {
    if (spVoice != null) {
      spVoice.Pause();
      free(spVoice.ptr);
      CoUninitialize();
      spVoice = null;
    }
  }
}

const NovelContentTotal = 100000000; // 10000 * 10000 <==> 一万章节 * 一万页
const TextConfigKey = "TextCompositionConfig";

class NovelMenu extends StatelessWidget {
  final SearchItem searchItem;
  final TextComposition composition;
  const NovelMenu({Key key, this.searchItem, this.composition})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).canvasColor.withOpacity(0.97);
    final color = Theme.of(context).textTheme.bodyText1.color;
    return Column(children: <Widget>[
      Spacer(),
      StatefulBuilder(builder: (BuildContext context, setState) {
        return Wrap(
          spacing: 10,
          children: [
            ElevatedButton(
              onPressed: () {
                SpeakService.instance.addRate();
                setState(() {});
              },
              child: Text('加快'),
            ),
            ElevatedButton(
              onPressed: () {
                SpeakService.instance.resetRate();
                setState(() {});
              },
              child: Text('恢复'),
            ),
            ElevatedButton(
              onPressed: () {
                SpeakService.instance.minusRate();
                setState(() {});
              },
              child: Text('减慢'),
            ),
            ElevatedButton(onPressed: speak, child: Text('朗读')),
            ElevatedButton(onPressed: stop, child: Text('停止')),
            ElevatedButton(onPressed: prevPage, child: Text('上页')),
            ElevatedButton(onPressed: nextPage, child: Text('下页')),
          ],
        );
      }),
      Wrap(
        spacing: 10,
        children: [],
      ),
      SizedBox(height: 60),
      _buildBottomRow(context, bgColor, color),
    ]);
  }

  Future<dynamic> _speak(int check) async {
    // if (!Global.isDesktop) await FlutterTts().awaitSpeakCompletion(true);
    while (speakingCheck > 0 && speakingCheck == check) {
      final s = composition.textPages[composition.currentIndex]?.lines
          ?.map((e) => e.text)
          ?.join();
      if (s != null && s.isNotEmpty) {
        await SpeakService.instance.speak(s);
      } else {
        break;
      }
      if (speakingCheck > 0 && speakingCheck == check) {
        composition.nextPage();
      } else {
        break;
      }
    }
  }

  speak() async {
    await stop();
    speakingCheck = DateTime.now().microsecondsSinceEpoch;
    _speak(speakingCheck);
  }

  stop() async {
    speakingCheck = -1;
    SpeakService.instance.stop();
  }

  prevPage() async {
    await stop();
    composition.previousPage();
    speak();
  }

  nextPage() async {
    await stop();
    composition.nextPage();
    speak();
  }

  Widget _buildPopupMenu(BuildContext context, Color bgColor, Color color) {
    const TO_CLICPBOARD = 0;
    const LAUCH = 1;
    const ADD_ITEM = 3;
    const REFRESH = 4;
    const AUTO_CACHE = 5;
    const CLEARCACHE = 6;
    const GOTOPAGE = 7;
    const TEXT_TO_CLICPBOARD = 8;
    final primaryColor = Theme.of(context).primaryColor;

    return PopupMenuButton<int>(
        elevation: 20,
        icon: Icon(FIcons.more_vertical, color: color),
        color: bgColor,
        onSelected: (int value) async {
          switch (value) {
            case GOTOPAGE:
              showDialog(
                  context: context,
                  builder: (context) {
                    final page =
                        composition.textPages[composition.currentIndex];
                    final controllerChaptersNum =
                        TextEditingController(text: "0");
                    final TextEditingController controllerPagesNum =
                        TextEditingController(text: page.number.toString());
                    return AlertDialog(
                        title: Text("快速跳转"),
                        content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "章节（当前${page.chIndex + 1} / ${searchItem.chaptersCount}）："),
                              Row(children: [
                                Container(
                                  width: 100,
                                  child: TextField(
                                    controller: controllerChaptersNum,
                                    keyboardType: TextInputType.number,
                                  ),
                                )
                              ]),
                              TextButton(
                                  onPressed: () {
                                    final n = int.tryParse(
                                        controllerChaptersNum.text);
                                    if (n == null) {
                                      Utils.toast(
                                          "请输入1到${searchItem.chaptersCount}以内的整数");
                                      return;
                                    }
                                    if (n < 0 ||
                                        n >= searchItem.chaptersCount) {
                                      Utils.toast(
                                          "请输入1到${searchItem.chaptersCount}以内的整数");
                                      return;
                                    }
                                    composition.gotoChapter(n - 1);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("跳章节")),
                            ]));
                  });
              break;
            case TEXT_TO_CLICPBOARD:
              final cIndex =
                  composition.textPages[composition.currentIndex]?.chIndex ??
                      searchItem.durChapterIndex;
              final p = "    " +
                  (await composition.loadChapter(cIndex)).join("\n    ");
              final title = searchItem.name + "    " + searchItem.durChapter;
              final config = composition.config;
              TextEditingController controller = TextEditingController(text: p);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: config.backgroundColor,
                  content: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.justify,
                    maxLines: null,
                    style: TextStyle(
                      height: config.fontHeight,
                      color: config.fontColor,
                      fontSize: config.fontSize,
                      fontFamily: config.fontFamily,
                    ),
                  ),
                  title: Text(title),
                  actions: [
                    TextButton(
                      child: Text(
                        "取消",
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text(
                        "复制",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        final t = p.substring(controller.selection.start,
                            controller.selection.end);
                        Utils.toast("已复制: " +
                            (t.length > 10
                                ? t.substring(0, 5) +
                                    "..." +
                                    t.substring(t.length - 5, t.length)
                                : t));
                        Clipboard.setData(ClipboardData(text: t));
                      },
                    ),
                  ],
                ),
              );
              break;
            default:
              Utils.toast("未实现的操作");
              break;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('快速跳转'),
                    Icon(Icons.grid_goldenratio_sharp, color: primaryColor),
                  ],
                ),
                value: GOTOPAGE,
              ),
              PopupMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('自动缓存'),
                    Icon(Icons.import_contacts, color: primaryColor),
                  ],
                ),
                value: AUTO_CACHE,
              ),
              PopupMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('复制原地址'),
                    Icon(FIcons.copy, color: primaryColor),
                  ],
                ),
                value: TO_CLICPBOARD,
              ),
              PopupMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('查看原页面'),
                    Icon(FIcons.external_link, color: primaryColor),
                  ],
                ),
                value: LAUCH,
              ),
              PopupMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('重新加载'),
                    Icon(FIcons.rotate_cw, color: primaryColor),
                  ],
                ),
                value: REFRESH,
              ),
              PopupMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('清理缓存'),
                    Icon(Icons.cleaning_services_outlined, color: primaryColor),
                  ],
                ),
                value: CLEARCACHE,
              ),
              PopupMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('加入收藏'),
                    Icon(
                      FIcons.heart,
                      color: primaryColor,
                    ),
                  ],
                ),
                value: ADD_ITEM,
              ),
              PopupMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('编辑文本'),
                    Icon(Icons.edit_calendar_outlined, color: primaryColor),
                  ],
                ),
                value: TEXT_TO_CLICPBOARD,
              ),
            ]);
  }

  Widget _buildBottomRow(BuildContext context, Color bgColor, Color color) {
    return Container(
      width: double.infinity,
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(color: bgColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: <Widget>[
              Text(
                '章节',
                style: TextStyle(color: color),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: FlutterSlider(
                  values: [
                    1.0 +
                        (composition
                                .textPages[composition.currentIndex]?.chIndex ??
                            searchItem.durChapterIndex)
                  ],
                  max: searchItem.chaptersCount * 1.0,
                  min: 1,
                  step: FlutterSliderStep(step: 1),
                  onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                    // provider.loadChapter((lowerValue as double).toInt() - 1);
                    composition.gotoChapter((lowerValue as double).toInt() - 1);
                  },
                  // disabled: provider.isLoading,
                  handlerWidth: 6,
                  handlerHeight: 14,
                  handler: FlutterSliderHandler(
                    decoration: BoxDecoration(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: bgColor,
                        border: Border.all(
                            color: color.withOpacity(0.65), width: 1),
                      ),
                    ),
                  ),
                  trackBar: FlutterSliderTrackBar(
                    inactiveTrackBar: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: color.withOpacity(0.5),
                    ),
                    activeTrackBar: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  touchSize: 30,
                  tooltip: FlutterSliderTooltip(
                    alwaysShowTooltip: true,
                    disableAnimation: true,
                    absolutePosition: true,
                    positionOffset: FlutterSliderTooltipPositionOffset(
                      left: -20,
                      top: -12,
                      right: 160 - MediaQuery.of(context).size.width,
                    ),
                    custom: (value) {
                      final index = (value as double).toInt();
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        color: bgColor,
                        padding: EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                searchItem.chapters[index - 1].name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: composition.config.fontFamily,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Text(
                              "$index / ${searchItem.chaptersCount}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: composition.config.fontFamily,
                                color: color.withOpacity(0.7),
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 10),
              Text(
                '共${searchItem.chaptersCount}章',
                style: TextStyle(color: color),
              ),
            ]),
          ),
          SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        child: Column(
                          children: [
                            Icon(Icons.arrow_back, color: color, size: 22),
                            Text("退出", style: TextStyle(color: color))
                          ],
                        ),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      InkWell(
                          child: Column(
                            children: [
                              Icon(Icons.format_list_bulleted,
                                  color: color, size: 22),
                              Text("目录", style: TextStyle(color: color))
                            ],
                          ),
                          onTap: () {
                            final x = composition
                                .textPages[composition.currentIndex]?.chIndex;
                            if (x != null) searchItem.durChapterIndex = x;
                            showDialog(
                                context: context,
                                builder: (context) => UIChapterSelect(
                                      searchItem: searchItem,
                                      loadChapter: (index) {
                                        composition.gotoChapter(index);
                                        Navigator.of(context).pop();
                                      },
                                      color: bgColor,
                                      fontColor: color,
                                    ));
                          }),
                      InkWell(
                        child: Column(
                          children: [
                            Icon(Icons.text_format, color: color, size: 22),
                            Text("调节", style: TextStyle(color: color))
                          ],
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              contentPadding: EdgeInsets.zero,
                              content: Container(
                                width: 520,
                                child: myConfigSettingBuilder(
                                    context, composition.config),
                              ),
                            ),
                          );
                        },
                      ),
                      _buildPopupMenu(context, bgColor, color),
                    ]),
              ))
        ],
      ),
    );
  }
}
