import 'package:app/extensions/assets_audio_player.dart';
import 'package:app/providers/audio_provider.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AudioControls extends StatelessWidget {
  const AudioControls({Key? key}) : super(key: key);

  static const FORWARD_SECONDS = 30;
  static const REPLAY_SECONDS = 10;

  @override
  Widget build(BuildContext context) {
    AudioProvider audio = context.watch();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () {
            audio.player.currentPosition.valueWrapper!.value.inSeconds >
                    REPLAY_SECONDS + 1
                ? audio.player.seek(
                    audio.player.currentPosition.valueWrapper!.value -
                        Duration(seconds: REPLAY_SECONDS),
                    force: true)
                : audio.player.restart();
          },
          icon: const Icon(Icons.replay_10),
          iconSize: 42,
        ),
        IconButton(
          onPressed: () {
            audio.player.currentPosition.valueWrapper!.value.inSeconds > 5
                ? audio.player.restart()
                : audio.player.previous();
          },
          icon: const Icon(CupertinoIcons.backward_fill),
          iconSize: 48,
        ),
        PlayerBuilder.isPlaying(
          player: audio.player,
          builder: (context, isPlaying) {
            return IconButton(
              onPressed: () => audio.player.playOrPause(),
              icon: Icon(
                isPlaying
                    ? CupertinoIcons.pause_solid
                    : CupertinoIcons.play_fill,
              ),
              iconSize: 64,
            );
          },
        ),
        IconButton(
          onPressed: () => audio.player.next(),
          icon: const Icon(CupertinoIcons.forward_fill),
          iconSize: 48,
        ),
        IconButton(
          onPressed: () {
            (audio.player.realtimePlayingInfos.valueWrapper!.value.duration -
                            audio.player.currentPosition.valueWrapper!.value)
                        .inSeconds >
                    FORWARD_SECONDS + 1
                ? audio.player.seek(
                    audio.player.currentPosition.valueWrapper!.value +
                        Duration(seconds: FORWARD_SECONDS),
                    force: true)
                : audio.player.next();
          },
          icon: const Icon(Icons.forward_30),
          iconSize: 42,
        ),
      ],
    );
  }
}
