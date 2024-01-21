class ChapterItem {
  String contentUrl; //内容地址
  String cover; //封面
  String name; //名字
  String time; //时间
  String url; //地址

  ChapterItem({
    this.contentUrl,
    this.cover,
    this.name,
    this.time,
    this.url,
  });

//导出到json
  Map<String, dynamic> toJson() => {
        "contentUrl": contentUrl,
        "cover": cover,
        "name": name,
        "time": time,
        "url": url,
      };
//从json 导入
  ChapterItem.fromJson(Map<String, dynamic> json) {
    contentUrl = json["contentUrl"];
    cover = json["cover"];
    name = json["name"];
    time = json["time"];
    url = json["url"];
  }
}
