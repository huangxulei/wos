import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../database/search_item.dart';
import '../database/search_item_manager.dart';
import '../global.dart';

class FavoriteListProvider with ChangeNotifier {
  List<SearchItem> _searchList;
  List<SearchItem> get searchList => _searchList;
  List<SearchItem> get allSearchList =>
      SearchItemManager.getSearchItemByType(type, _sortType, "全部");
  final box = Hive.box<List<String>>(Global.favoriteListTagKey);

  List<String> _tags = ["全部"];
  Iterable<String> get tags => _tags.skip(1);
  String get selectTag => _tags.first;

  final _sortType = SortType.CREATE;
  final int type;

  FavoriteListProvider(this.type) {
    _tags = box.get(type, defaultValue: ["全部"]);
    updateList();
  }

  void removeTag(String tag) {
    if (selectTag == tag) {
      _tags[0] = "全部";
      _searchList =
          SearchItemManager.getSearchItemByType(type, _sortType, "全部");
      // if (type == API.AUDIO) checkAudioInList(_searchList);
    }
    _tags.remove(tag);
    box.put(type, _tags);
    notifyListeners();
  }

  void updateList([String tag]) {
    _searchList = SearchItemManager.getSearchItemByType(
        type, _sortType, tag ?? selectTag);
    // if (type == API.AUDIO) checkAudioInList(_searchList);
    notifyListeners();
  }

  @override
  void dispose() {
    _searchList.clear();
    super.dispose();
  }
}
