import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../api/api.dart';
import '../model/chapter_page_provider.dart';
import 'chapter_item.dart';

class SearchItem extends HiveObject {
  String searchUrl;
  String chapterUrl;
  @override
  int get hashCode => id;

  int id;

  /// 源名
  String origin;

  /// 源id
  String originTag;
  String cover;
  String name;
  String author;

  /// 最新章节
  String chapter;

  /// 简介
  String description;

  /// 分类
  List<String> tags;

  /// 搜索结果
  String url;
  int ruleContentType;
  int chapterListStyle;
  String durChapter;
  int durChapterIndex;
  int durContentIndex;

  int chaptersCount;
  bool reverseChapter;
  List<ChapterItem> chapters;

  /// 收藏时间
  int createTime;

  /// 更新时间
  int updateTime;

  /// 最后阅读时间
  int lastReadTime;

  SearchItem({
    this.searchUrl,
    this.chapterUrl,
    @required this.cover,
    @required this.name,
    @required this.author,
    @required this.chapter,
    @required this.description,
    @required this.url,
    @required API api,
    this.chaptersCount,
    this.reverseChapter,
    this.chapters,
    @required this.tags,
  }) {
    if (chaptersCount == null) {
      chaptersCount = 0;
    }
    if (reverseChapter == null) {
      reverseChapter = false;
    }
    if (api != null) {
      origin = api.origin;
      originTag = api.originTag;
      ruleContentType = api.ruleContentType;
    }
    id = DateTime.now().microsecondsSinceEpoch;
    chapterListStyle = ChapterPageProvider.BigList;
    durChapter = "";
    durChapterIndex = 0;
    durContentIndex = 1;
    chapters = null;

    createTime ??= DateTime.now().microsecondsSinceEpoch;
    updateTime ??= DateTime.now().microsecondsSinceEpoch;
    lastReadTime ??= DateTime.now().microsecondsSinceEpoch;
  }

  @override
  bool operator ==(Object other) {
    return other is SearchItem &&
        runtimeType == other.runtimeType &&
        id == other.id;
  }

  Map<String, dynamic> toJson() => {
        "searchUrl": searchUrl,
        "chapterUrl": chapterUrl,
        "id": id,
        "origin": origin,
        "originTag": originTag,
        "cover": cover,
        "name": name,
        "author": author,
        "chapter": chapter,
        "description": description,
        "url": url,
        "ruleContentType": ruleContentType,
        "chapterListStyle": chapterListStyle,
        "durChapter": durChapter,
        "durChapterIndex": durChapterIndex,
        "durContentIndex": durContentIndex,
        "chaptersCount": chaptersCount,
        "reverseChapter": reverseChapter,
        "tags": tags != null ? tags.join(", ") : null,
        "createTime": createTime,
        "updateTime": updateTime,
        "lastReadTime": lastReadTime,
      };

  SearchItem.fromAdapter(
    this.searchUrl,
    this.chapterUrl,
    this.id,
    this.origin,
    this.originTag,
    this.cover,
    this.name,
    this.author,
    this.chapter,
    this.description,
    this.url,
    this.ruleContentType,
    this.chapterListStyle,
    this.durChapter,
    this.durChapterIndex,
    this.durContentIndex,
    this.chaptersCount,
    this.reverseChapter,
    this.tags,
    //增加时间
    this.createTime,
    this.updateTime,
    this.lastReadTime,
    this.chapters,
  );
}
