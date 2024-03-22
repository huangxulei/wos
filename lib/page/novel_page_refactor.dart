import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/search_item.dart';
import 'package:text_composition/text_composition.dart';

import '../database/text_config_manager.dart';
import '../ui/ui_chapter_select.dart';
import 'content_page_manager.dart';

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
  Widget build(BuildContext context) {
    final provider = Provider.of<ContentProvider>(context);
    final bookName = "${searchItem.name}(${searchItem.origin})";
    return Container(child: LayoutBuilder(builder: (context, constrains) {
      final controller = TextComposition(
        config: _config,
        loadChapter: provider.loadChapter, //载入数据
        chapters: searchItem.chapters.map((e) => e.name).toList(),
        name: bookName,
        menuBuilder: (TextComposition composition) =>
            NovelMenu(searchItem: searchItem, composition: composition),
      );
      return TextCompositionPage(controller: controller);
    }));
  }
}

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
                          })
                    ]),
              ))
        ],
      ),
    );
  }

  // stop() async {
  //   speakingCheck = -1;
  //   SpeakService.instance.stop();
  // }

  prevPage() async {
    // await stop();
    composition.previousPage();
    // speak();
  }

  nextPage() async {
    // await stop();
    composition.nextPage();
    // speak();
  }
}
