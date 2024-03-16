import 'package:hive_flutter/hive_flutter.dart';

import '../api/api.dart';
import '../database/search_item.dart';
import 'chapter_item_adapter.dart';

T cast<T>(x, T v) => x is T ? x : v;

class SearchItemAdapter extends TypeAdapter<SearchItem> {
  @override
  SearchItem read(BinaryReader reader) {
    final now = DateTime.now();
    final searchUrl = cast(reader.readString(), ""),
        chapterUrl = cast(reader.readString(), ""),
        id = cast(reader.readInt(), now.microsecondsSinceEpoch),
        origin = cast(reader.readString(), ""),
        originTag = cast(reader.readString(), ""),
        cover = cast(reader.readString(), ""),
        name = cast(reader.readString(), ""),
        author = cast(reader.readString(), ""),
        chapter = cast(reader.readString(), ""),
        description = cast(reader.readString(), ""),
        url = cast(reader.readString(), ""),
        ruleContentType = cast(reader.readInt(), API.MANGA),
        chaptersCount = cast(reader.readInt(), 0),
        tags = cast(reader.readStringList(), <String>[]),
        createTime = cast(reader.readInt(), now.microsecondsSinceEpoch),
        updateTime = cast(reader.readInt(), now.microsecondsSinceEpoch),
        lastReadTime = cast(reader.readInt(), now.microsecondsSinceEpoch),
        count = cast(reader.readInt(), 0),
        chapters =
            List.generate(count, (_) => ChapterItemAdapter().read(reader));

    return SearchItem.fromAdapter(
      searchUrl,
      chapterUrl,
      id,
      origin,
      originTag,
      cover,
      name,
      author,
      chapter,
      description,
      url,
      ruleContentType,
      chaptersCount,
      tags,
      //增加时间
      createTime,
      updateTime,
      lastReadTime,
      chapters,
    );
  }

  @override
  int get typeId => 1;

  @override
  void write(BinaryWriter writer, SearchItem item) {
    final now = DateTime.now();
    writer.writeString(cast(item.searchUrl, ""));
    writer.writeString(cast(item.chapterUrl, ""));
    writer.writeInt(cast(item.id, now.microsecondsSinceEpoch));
    writer.writeString(cast(item.origin, ""));
    writer.writeString(cast(item.originTag, ""));
    writer.writeString(cast(item.cover, ""));
    writer.writeString(cast(item.name, ""));
    writer.writeString(cast(item.author, ""));
    writer.writeString(cast(item.chapter, ""));
    writer.writeString(cast(item.description, ""));
    writer.writeString(cast(item.url, ""));
    writer.writeInt(cast(item.ruleContentType, API.MANGA));
    writer.writeInt(cast(item.chaptersCount, 0));
    writer.writeStringList(cast(item.tags, <String>[]));
    writer.writeInt(cast(item.createTime, now.microsecondsSinceEpoch));
    writer.writeInt(cast(item.updateTime, now.microsecondsSinceEpoch));
    writer.writeInt(cast(item.lastReadTime, now.microsecondsSinceEpoch));
    writer.writeInt(item.chapters?.length ?? 0);
    for (var chapter in item.chapters) {
      ChapterItemAdapter().write(writer, chapter);
    }
  }
}
