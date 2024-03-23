import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wos/utils.dart';
import 'package:wos/wos_theme.dart';
import '../database/search_item.dart';
import '../database/search_item_manager.dart';
import '../menu/menu.dart';
import '../menu/menu_chapter.dart';
import '../model/chapter_page_provider.dart';
import '../ui/widget/draggable_scrollbar_sliver.dart';
import '../ui/widget/image_place_holder.dart';
import 'content_page_manager.dart';

class ChapterPage extends StatefulWidget {
  final SearchItem searchItem;

  const ChapterPage({Key key, this.searchItem}) : super(key: key);

  @override
  State<ChapterPage> createState() => _ChapterPageState(searchItem);
}

class _ChapterPageState extends State<ChapterPage> {
  _ChapterPageState(this.searchItem) : super();

  double opacity = 0.0;
  StateSetter state;
  final SearchItem searchItem;
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
    _controller = ScrollController();
    return ChangeNotifierProvider<ChapterPageProvider>(
        create: (context) =>
            ChapterPageProvider(searchItem: searchItem, size: size),
        builder: (context, child) => Container(
                child: Scaffold(
                    body: Stack(
              children: [
                NotificationListener(
                  child: DraggableScrollbar.semicircle(
                    child: CustomScrollView(
                      physics: ClampingScrollPhysics(),
                      controller: _controller,
                      slivers: <Widget>[
                        _comicDetail(context),
                        _buildChapter(context),
                      ],
                    ),
                    controller: _controller,
                    padding: const EdgeInsets.only(top: 100, bottom: 8),
                  ),
                  onNotification: ((ScrollUpdateNotification n) {
                    if (n.depth == 0 && n.metrics.pixels <= 200.0) {
                      opacity = min(n.metrics.pixels, 100.0) / 100.0;
                      if (opacity < 0) opacity = 0;
                      if (opacity > 1) opacity = 1;
                      if (state != null) state(() => null);
                    }
                    return true;
                  }),
                ),
                StatefulBuilder(
                  builder: (context, _state) {
                    state = _state;
                    return Container(
                      child: _buildAlphaAppbar(context),
                      height: topHeight,
                    );
                  },
                ),
              ],
            ))));
  }

  //头部
  Widget _buildAlphaAppbar(BuildContext context) {
    final provider = Provider.of<ChapterPageProvider>(context, listen: false);

    return AppBar(
      elevation: 0.0,
      backgroundColor:
          Theme.of(context).appBarTheme.backgroundColor.withOpacity(opacity),
      title: Text(
        searchItem.origin,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: <Widget>[
        // 加入收藏时需要刷新图标，其他不刷新
        Consumer<ChapterPageProvider>(
          builder: (context, provider, child) => IconButton(
            icon: SearchItemManager.isFavorite(
                    searchItem.originTag, searchItem.url)
                ? Icon(Icons.favorite)
                : Icon(Icons.favorite_border),
            iconSize: 21,
            onPressed: provider.toggleFavorite,
          ),
        ),
        Menu<MenuChapter>(
          items: chapterMenus,
          onSelect: (value) => provider.onSelect(value, context),
        ),
      ],
    );
  }

  static double lastTopHeight = 0.0;
  Widget _comicDetail(BuildContext context) {
    //获取状态栏高度
    double _top = MediaQuery.of(context).padding.top;
    if (_top <= 0) {
      _top = lastTopHeight;
    } else {
      lastTopHeight = _top;
    }
    final _hero = Utils.empty(searchItem.cover)
        ? null
        : '${searchItem.name}.${searchItem.cover}.${searchItem.id}';
    return SliverList(
        delegate: SliverChildListDelegate([
      Stack(children: [
        ArcBannerImage(searchItem.cover),
        SizedBox(
            height: 300 + _top,
            width: double.infinity,
            child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Padding(
                    padding: EdgeInsets.only(top: _top),
                    child: Column(children: [
                      SizedBox(height: 45),
                      Expanded(
                          child: Container(
                        child: GestureDetector(
                          child: searchItem.cover == "nocover"
                              ? ImagePlaceHolder(width: 120)
                              : Image.memory(
                                  base64Decode(searchItem.cover),
                                  width: 120,
                                ),
                        ),
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(blurRadius: 8, color: Colors.white70)
                        ]),
                      )),
                      SizedBox(height: 12),
                      Text(
                        searchItem.name,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1.color,
                          fontWeight: FontWeight.w700,
                          fontFamily: WOSTheme.staticFontFamily,
                          fontSize: 18,
                          shadows: [Shadow(blurRadius: 2, color: Colors.grey)],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        searchItem.author,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: WOSTheme.staticFontFamily,
                          color: Theme.of(context).textTheme.bodyText1.color,
                        ),
                      ),
                    ])))),
      ])
    ]));
  }

  Widget _buildChapter(BuildContext context) {
    return Consumer<ChapterPageProvider>(builder: (context, provider, child) {
      void Function(int index) onTap = (int index) {
        provider.changeChapter(index);
        Navigator.of(context).push(ContentPageRoute().route(searchItem));
      };
      return StatefulBuilder(
          builder: (BuildContext context, setState) => SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return buildChapterButton(index, onTap);
                    },
                    childCount: searchItem.chapters.length,
                  ),
                ),
              ));
    });
  }

  Widget buildChapterButton(int chapterIndex, void Function(int) onTap) {
    final chapter = searchItem.chapters[chapterIndex];
    return Card(
        child: ListTile(
      onTap: () => onTap(chapterIndex),
      title: Text(
        chapter.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ));
  }
}

//背景虚化
class ArcBannerImage extends StatelessWidget {
  ArcBannerImage(this.imageUrl, {this.arcH = 30.0, this.height = 335.0});
  final String imageUrl;
  final double height, arcH;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ArcClipper(this),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: height,
            child: imageUrl == "nocover"
                ? ImagePlaceHolder(height: 80, width: 80)
                : Image.memory(
                    base64Decode(imageUrl),
                    width: 80,
                  ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Theme.of(context).bottomAppBarColor.withOpacity(0.8),
              height: height,
            ),
          ),
        ],
      ),
    );
  }
}

class ArcClipper extends CustomClipper<Path> {
  final ArcBannerImage widget;
  ArcClipper(this.widget);

  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - widget.arcH);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstPoint.dx, firstPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 4), size.height);
    var secondPoint = Offset(size.width, size.height - widget.arcH);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondPoint.dx, secondPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
