
import 'package:hive_flutter/hive_flutter.dart';

import '../database/chapter_item.dart';

T cast<T>(x, T v) => x is T ? x : v;

class ChapterItemAdapter extends TypeAdapter<ChapterItem> {
  @override
  ChapterItem read(BinaryReader reader) {
    final contentUrl = cast(reader.readString(), ""),
        cover = cast(reader.readString(), ""),
        name = cast(reader.readString(), ""),
        time = cast(reader.readString(), ""),
        url = cast(reader.readString(), "");
    return ChapterItem(
      contentUrl: contentUrl,
      cover: cover,
      name: name,
      time: time,
      url: url,
    );
  }

  @override
  int get typeId => 0;

  @override
  void write(BinaryWriter writer, ChapterItem obj) {
    writer.writeString(cast(obj.contentUrl, ""));
    writer.writeString(cast(obj.cover, ""));
    writer.writeString(cast(obj.name, ""));
    writer.writeString(cast(obj.time, ""));
    writer.writeString(cast(obj.url, ""));
  }
}
