import 'package:flutter/services.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/constant/globals.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nova/ui/voice_notes_swipe/common.dart';
import 'package:just_audio_cache/just_audio_cache.dart';

class AudioBubble extends StatefulWidget {
  const AudioBubble({Key key, this.filepath, this.isPeer, this.uuid})
      : super(key: key);

  final String filepath;
  final bool isPeer;
  final String uuid;

  @override
  State<AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<AudioBubble>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {

  AudioPlayer player = AudioPlayer();
  Duration duration;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    audioPlayersMap[widget.uuid] = player;
    player.dynamicSet(url: widget.filepath).then((value) async {
      if (mounted) {
        if (await player.existedInLocal(url: widget.filepath) == true) {
          setState(() {
            duration = value;
          });
        } else {
          setState(() {
            duration = value;
          });
        }
      }
    });
    // audio caching //;
    //_init();
    super.initState();
    ambiguate(WidgetsBinding.instance).addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
  }

  @override
  void dispose() {
    ambiguate(WidgetsBinding.instance).removeObserver(this);
    player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      player.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return !widget.isPeer
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                Expanded(
                  child: Container(
                    height: 65,
                    padding: const EdgeInsets.only(left: 12, right: 18),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(Globals.borderRadius - 10),
                      color: vnpeerBG,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            StreamBuilder<PlayerState>(
                              stream: player.playerStateStream,
                              builder: (context, snapshot) {
                                final playerState = snapshot.data;
                                final processingState =
                                    playerState?.processingState;
                                final playing = playerState?.playing;
                                if (processingState ==
                                        ProcessingState.loading ||
                                    processingState ==
                                        ProcessingState.buffering) {
                                  return GestureDetector(
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.black87,
                                      size: 30,
                                    ),
                                    onTap: () {
                                      player.play();
                                      stopAllOtherAudio(widget.uuid);
                                    },
                                  );
                                } else if (playing != true) {
                                  return GestureDetector(
                                    child: const Icon(Icons.play_arrow,
                                        size: 30, color: Colors.black87),
                                    onTap: () {
                                      player.play();
                                      stopAllOtherAudio(widget.uuid);
                                    },
                                  );
                                } else if (processingState !=
                                    ProcessingState.completed) {
                                  return GestureDetector(
                                    child: const Icon(Icons.pause,
                                        size: 30, color: Colors.black87),
                                    onTap: player.pause,
                                  );
                                } else {
                                  return GestureDetector(
                                    child: const Icon(Icons.replay,
                                        size: 30, color: Colors.black87),
                                    onTap: () {
                                      player.seek(Duration.zero);
                                    },
                                  );
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: StreamBuilder<Duration>(
                                stream: player.positionStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Column(
                                      children: [
                                        const SizedBox(height: 4),
                                        LinearProgressIndicator(
                                          value: snapshot.data.inMilliseconds /
                                              (duration?.inMilliseconds ?? 1),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              prettyDuration(snapshot.data ==
                                                      Duration.zero
                                                  ? duration ?? Duration.zero
                                                  : snapshot.data),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  } else {
                                    return const LinearProgressIndicator();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                Expanded(
                  child: Container(
                    height: 65,
                    padding: const EdgeInsets.only(left: 12, right: 18),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(8),
                      color: vnuserBG,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            StreamBuilder<PlayerState>(
                              stream: player.playerStateStream,
                              builder: (context, snapshot) {
                                final playerState = snapshot.data;
                                final processingState =
                                    playerState?.processingState;
                                final playing = playerState?.playing;
                                if (processingState ==
                                        ProcessingState.loading ||
                                    processingState ==
                                        ProcessingState.buffering) {
                                  return GestureDetector(
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    onTap: () {
                                      player.play();
                                      stopAllOtherAudio(widget.uuid);
                                    },
                                  );
                                } else if (playing != true) {
                                  return GestureDetector(
                                    child: const Icon(Icons.play_arrow,
                                        size: 30, color: Colors.white),
                                    onTap: () {
                                      player.play();
                                      stopAllOtherAudio(widget.uuid);
                                    },
                                  );
                                } else if (processingState !=
                                    ProcessingState.completed) {
                                  return GestureDetector(
                                    child: const Icon(Icons.pause,
                                        size: 30, color: Colors.white),
                                    onTap: player.pause,
                                  );
                                } else {
                                  return GestureDetector(
                                    child: const Icon(Icons.replay,
                                        size: 30, color: Colors.white),
                                    onTap: () {
                                      player.seek(Duration.zero);
                                    },
                                  );
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: StreamBuilder<Duration>(
                                stream: player.positionStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Column(
                                      children: [
                                        const SizedBox(height: 4),
                                        LinearProgressIndicator(
                                          value: snapshot.data.inMilliseconds /
                                              (duration?.inMilliseconds ?? 1),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              prettyDuration(snapshot.data ==
                                                      Duration.zero
                                                  ? duration ?? Duration.zero
                                                  : snapshot.data),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  } else {
                                    return const LinearProgressIndicator();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  String prettyDuration(Duration d) {
    var min = d.inMinutes < 10 ? "0${d.inMinutes}" : d.inMinutes.toString();
    var sec = d.inSeconds < 10 ? "0${d.inSeconds}" : d.inSeconds.toString();
    return min + ":" + sec;
  }
}
