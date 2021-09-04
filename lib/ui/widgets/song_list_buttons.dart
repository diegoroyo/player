import 'package:app/constants/dimensions.dart';
import 'package:app/models/song.dart';
import 'package:app/providers/audio_provider.dart';
import 'package:app/router.dart';
import 'package:app/ui/screens/queue.dart';
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
  late DownloadableSongList cachedSongs;

  @override
  void initState() {
    super.initState();

    cachedSongs = DownloadableSongList(context, widget.songs)
      ..addListener(() {
        setState(() {});
      });
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
                onPressed: () async =>
                    await audio.replaceQueue(cachedSongs.songs),
              ),
              const SizedBox(width: 12),
              FullWidthPrimaryIconButton(
                  key: SongListButtons.shuffleAllButtonKey,
                  icon: CupertinoIcons.shuffle,
                  label: 'Shuffle All',
                  onPressed: () async {
                    await audio.replaceQueue(cachedSongs.songs, shuffle: true);
                    Navigator.of(context, rootNavigator: true)
                        .pushNamed(QueueScreen.routeName);
                    await AppRouter().openNowPlayingScreen(context);
                  }),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              FullWidthPrimaryIconButton(
                key: SongListButtons.downloadAllButtonKey,
                icon: cachedSongs.allDownloaded
                    ? CupertinoIcons.checkmark_alt_circle_fill
                    : CupertinoIcons.cloud_download_fill,
                label: cachedSongs.hasFinishedLoading
                    ? (cachedSongs.allDownloaded
                        ? 'All songs available offline'
                        : 'Download All'
                            '${cachedSongs.isDownloading ? " (" + cachedSongs.numDownloaded.toString() + " / " + cachedSongs.songs.length.toString() + ")" : ""}')
                    : 'Loading...',
                onPressed: cachedSongs.requestDownload,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
