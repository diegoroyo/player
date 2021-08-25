import 'package:app/constants/dimensions.dart';
import 'package:app/models/song.dart';
import 'package:app/providers/audio_provider.dart';
import 'package:app/providers/cache_provider.dart';
import 'package:app/ui/widgets/full_width_primary_icon_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum SongListContext {
  queue,
  allSongs,
  album,
  artist,
  playlist,
  favorites,
  other,
}

class SongListButtons extends StatefulWidget {
  static final Key playAllButtonKey = UniqueKey();
  static final Key shuffleAllButtonKey = UniqueKey();
  static final Key downloadAllButtonKey = UniqueKey();

  final List<Song> songs;

  const SongListButtons({Key? key, required this.songs}) : super(key: key);

  @override
  _SongListButtonsState createState() => _SongListButtonsState();
}

class _SongListButtonsState extends State<SongListButtons> {
  late CacheProvider cache;
  bool _downloading = false;
  int _numDownloadedSongs = 0;

  @override
  void initState() {
    super.initState();
    cache = context.read();
    _checkDownloadedSongs();
  }

  void _checkDownloadedSongs() async {
    for (Song song in widget.songs) {
      if (await cache.has(song: song)) {
        _numDownloadedSongs++;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    AudioProvider audio = context.read();
    return Container(
      padding: const EdgeInsets.all(AppDimensions.horizontalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: <Widget>[
              FullWidthPrimaryIconButton(
                key: SongListButtons.playAllButtonKey,
                icon: CupertinoIcons.play_fill,
                label: 'Play All',
                onPressed: () async => await audio.replaceQueue(widget.songs),
              ),
              const SizedBox(width: 12),
              FullWidthPrimaryIconButton(
                key: SongListButtons.shuffleAllButtonKey,
                icon: CupertinoIcons.shuffle,
                label: 'Shuffle All',
                onPressed: () async =>
                    await audio.replaceQueue(widget.songs, shuffle: true),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              FullWidthPrimaryIconButton(
                key: SongListButtons.downloadAllButtonKey,
                icon: _numDownloadedSongs == widget.songs.length
                    ? CupertinoIcons.checkmark_alt_circle_fill
                    : CupertinoIcons.cloud_download_fill,
                label: _numDownloadedSongs == widget.songs.length
                    ? 'All songs available offline'
                    : 'Download All'
                        '${_downloading ? " (" + _numDownloadedSongs.toString() + " / " + widget.songs.length.toString() + ")" : ""}',
                onPressed: () async {
                  if (!_downloading) {
                    setState(() => _downloading = true);
                    for (Song song in widget.songs) {
                      if (!await cache.has(song: song)) {
                        await cache
                            .cache(song: song)
                            .then((e) => setState(() => _numDownloadedSongs++));
                      }
                    }
                    setState(() => _downloading = false);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
