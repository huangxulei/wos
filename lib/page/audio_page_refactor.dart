import 'dart:convert';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:wos/utils.dart';
import '../database/chapter_item.dart';
import '../database/search_item.dart';
import '../database/search_item_manager.dart';
import 'content_page_manager.dart';
import 'package:rxdart/rxdart.dart';
import 'langding_page.dart';

AudioHandler _audioHandler;
AudioHandler get audioHandler => _audioHandler;
Future<bool> ensureInitAudioHandler(SearchItem searchItem) async {
  if (_audioHandler == null) {
    _audioHandler = await AudioService.init(
      builder: () => AudioHandler(searchItem),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.eso.channel.audio',
        androidNotificationChannelName: '亦搜音频',
        androidNotificationOngoing: true,
        androidNotificationIcon: 'mipmap/eso_logo',
      ),
    );
  }
  return true;
}

class AudioHandler extends BaseAudioHandler with SeekHandler {
  SearchItem _searchItem;
  SearchItem get searchItem => _searchItem;
  int _currentIndex = 0;

  ChapterItem get chapter {
    if (searchItem.chapters == null || searchItem.chapters.isEmpty) {
      Utils.toast("无曲目");
      return null;
    }
    final len = searchItem.chapters.length;
    if (_currentIndex < 0) {
      _currentIndex = len - 1;
    } else if (_currentIndex >= len) {
      _currentIndex = 0;
    }
    return searchItem.chapters[_currentIndex];
  }

  var close = false;
  String cover = "";
  Map<String, String> headers;
  bool get emptyCover => Utils.empty(cover);
  ContentProvider _contentProvider;
  final _player = AudioPlayer();
  bool get playing => _player.playing; //是否正在播放
  Stream<Duration> get positionStream => _player.positionStream;
  Duration get position => _player.position; //获取播放当前进度
  Duration get duration => _player.duration; //歌曲时长
  Duration get bufferedPosition => _player.bufferedPosition;
  final _repeatMode = BehaviorSubject.seeded(AudioServiceRepeatMode.all);

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    if (repeatMode == AudioServiceRepeatMode.group) {
      final list = AudioServiceRepeatMode.values;
      repeatMode = list[(repeatMode.index + 1) % list.length];
    }
    _repeatMode.add(repeatMode);
    super.setRepeatMode(repeatMode);
  }

  void toggleRepeatMode() {
    final list = AudioServiceRepeatMode.values;
    final next = list[(_repeatMode.value.index + 1) % list.length];
    if (next == AudioServiceRepeatMode.group) {
      _repeatMode.add(list[(_repeatMode.value.index + 2) % list.length]);
    } else {
      _repeatMode.add(next);
    }
  }

  MapEntry<String, IconData> getRepeatModeName() {
    switch (_repeatMode.value) {
      case AudioServiceRepeatMode.all:
        return MapEntry<String, IconData>("歌单循环", Icons.repeat_rounded);
      case AudioServiceRepeatMode.none:
        return MapEntry<String, IconData>("不循环", Icons.label_outline);
      case AudioServiceRepeatMode.one:
        return MapEntry<String, IconData>("单曲循环", Icons.repeat_one_rounded);
      case AudioServiceRepeatMode.group:
        return MapEntry<String, IconData>("分组循环", Icons.event_repeat_rounded);
      default:
        return MapEntry<String, IconData>(
            "位置循环模式", Icons.report_gmailerrorred_outlined);
    }
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.setRepeatMode,
        MediaAction.play,
        MediaAction.pause,
        MediaAction.playPause,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState],
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      repeatMode: _repeatMode.value,
      // queueIndex: currentIndex,
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> skipToPrevious() async {
    loadChapter(searchItem.durChapterIndex - 1);
  }

  @override
  Future<void> skipToNext() async {
    loadChapter(searchItem.durChapterIndex + 1);
  }

  Future<void> playOrPause() async {
    if (_player.playing)
      return pause();
    else
      play();
  }

  AudioHandler(SearchItem searchItem) {
    _searchItem = searchItem;
    upMediaItem();
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  void upMediaItem({Duration duration, String coverUrl}) {
    if (coverUrl != null) {
      upCover(coverUrl);
    }
    mediaItem.add(MediaItem(
      id: "${_searchItem.id}${_searchItem.durChapterIndex}",
      title: chapter.name,
      displayTitle: chapter.name,
      displaySubtitle:
          "${searchItem.name} ( ${searchItem.author} ${searchItem.origin} )",
      displayDescription: searchItem.description,
      album: searchItem.origin,
      artist: "${searchItem.name}(${searchItem.author})",
      artUri: Uri.tryParse(cover),
      artHeaders: headers,
      duration: duration,
    ));
  }

  void upCover(String urlWithHeaders) {
    final index = urlWithHeaders.indexOf("@headers");
    if (index == -1) {
      cover = urlWithHeaders;
      headers?.clear();
      headers = null;
    } else {
      cover = urlWithHeaders.substring(0, index);
      headers = (jsonDecode(urlWithHeaders.substring(index + "@headers".length))
              as Map)
          .map((k, v) => MapEntry('$k', '$v'));
    }
  }

  void load(SearchItem searchItem, [ContentProvider contentProvider = null]) {
    close = false;
    if (contentProvider != null) _contentProvider = contentProvider;
    if (_searchItem?.id != searchItem.id) {
      _searchItem = searchItem;
      _currentIndex = _searchItem.durChapterIndex;
      final c = chapter;
      if (chapter == null) {
        upMediaItem(duration: Duration.zero);
        _player.stop();
      } else {
        upMediaItem(coverUrl: _searchItem.cover);
        loadChapter(_searchItem.durChapterIndex, c);
      }
    } else if (_searchItem.durChapterIndex == _currentIndex) {
      play();
    } else {
      loadChapter(_searchItem.durChapterIndex);
    }
  }

  Future<void> loadChapter(int index, [ChapterItem c]) async {
    if (c == null && _currentIndex == index) {
      play();
      return;
    }
    if (_currentIndex != index) {
      _currentIndex = index;
      c = chapter;
    }
    if (c == null) {
      Utils.toast("播放失敗");
      _player.stop();
      upMediaItem(duration: Duration.zero);
      return;
    }
    _searchItem.durChapterIndex = _currentIndex;
    _searchItem.durChapter = c.name;
    _searchItem.lastReadTime = DateTime.now().millisecondsSinceEpoch;
    if (SearchItemManager.isFavorite(_searchItem.originTag, _searchItem.url))
      _searchItem.save();
    final result = await _contentProvider.loadChapter(_currentIndex);
    final url = result[0];
    String coverTemp = null;

    if (coverTemp == null && !Utils.empty(c.cover)) {
      coverTemp = c.cover;
    }
    if (url.isEmpty) {
      Utils.toast("播放失敗");
      upMediaItem(duration: Duration.zero, coverUrl: coverTemp);
      _player.stop();
    } else {
      if (url.contains("@headers")) {
        final u = url.split("@headers");
        final h = (jsonDecode(u[1]) as Map).map((k, v) => MapEntry('$k', '$v'));
        print("url:${u[0]},headers:${h}");
        final d = await _player.setUrl(u[0], headers: h);
        upMediaItem(duration: d, coverUrl: coverTemp);
        await play();
        upMediaItem(duration: d, coverUrl: coverTemp);
      } else {
        final d = await _player.setUrl(url);
        upMediaItem(duration: d, coverUrl: coverTemp);
        await play();
        upMediaItem(duration: d, coverUrl: coverTemp);
      }
    }
  }
}

class AudioPage extends StatefulWidget {
  final SearchItem searchItem;

  const AudioPage({
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  _AudioPageState createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> with TickerProviderStateMixin {
  Widget _audioPage;
  SearchItem searchItem;
  bool _showSelect = false;
  bool _showChapter = false;

  void closeChapter() {
    if (_showChapter && mounted) {
      _showChapter = false;
      setState(() {});
    }
  }

  void toggleChapter() {
    if (mounted) {
      _showChapter = !_showChapter;
      setState(() {});
    }
  }

  @override
  void initState() {
    searchItem = widget.searchItem;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_audioPage == null) {
      _audioPage = FutureBuilder<bool>(
          future: ensureInitAudioHandler(searchItem),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              try {
                audioHandler.load(searchItem,
                    Provider.of<ContentProvider>(context, listen: false));
              } catch (e) {
                audioHandler.load(searchItem);
              }
              return _buildPage();
            }
            if (snapshot.hasError)
              return Scaffold(body: Text(snapshot.error.toString()));
            return LandingPage();
          });
    }
    return GestureDetector(
        onTap: closeChapter,
        child: Stack(children: [
          _audioPage,
        ]));
  }

  @override
  void dispose() {
    _audioPage = null;
    super.dispose();
  }

  Widget _buildPage() {
    final chapter = audioHandler.chapter;
    return Scaffold(
        body: Container(
            height: double.infinity,
            width: double.infinity,
            child: Stack(children: <Widget>[
              if (!Utils.empty(audioHandler.cover))
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: Image.network(
                    audioHandler.cover,
                    fit: BoxFit.cover,
                    headers: audioHandler.headers,
                  ),
                ),
            ])));
  }
}
