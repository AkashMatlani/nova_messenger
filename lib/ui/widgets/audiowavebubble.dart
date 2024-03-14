import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

class WaveBubble extends StatefulWidget {
  final bool isSender;
  final int index;
  final String path;
  final double width;
  final Directory appDirectory;

  const WaveBubble({
    Key key,
    @required this.appDirectory,
    this.width,
    this.index,
    this.isSender = false,
    this.path,
  }) : super(key: key);

  @override
  State<WaveBubble> createState() => _WaveBubbleState();
}

class _WaveBubbleState extends State<WaveBubble> {

  File file;

  PlayerController controller;
  StreamSubscription<PlayerState> playerStateSubscription;

  final playerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: Colors.black,
    liveWaveColor: Colors.black,
    spacing: 6,
  );

  @override
  void initState() {
    super.initState();
    controller = PlayerController();
    _preparePlayer();
    playerStateSubscription = controller.onPlayerStateChanged.listen((_) {
      setState(() {});
    });
  }

  void _preparePlayer() async {

    if (widget.index == null && widget.path == null && file?.path == null) {
      return;
    }

    controller.preparePlayer(
      path: widget.path ?? file.path,
      shouldExtractWaveform: widget.index?.isEven ?? true,
    );

    if (widget.index?.isOdd ?? false) {
      controller
          .extractWaveformData(
        path: widget.path ?? file.path,
        noOfSamples:
        playerWaveStyle.getSamplesForWidth(widget.width ?? 200),
      )
          .then((waveformData) => debugPrint(waveformData.toString()));
    }
  }

  @override
  void dispose() {
    playerStateSubscription.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.path != null || file?.path != null
        ? Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: widget.isSender
              ? const Color(0xFF276bfd)
              : const Color(0xFF343145),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!controller.playerState.isStopped)
              IconButton(
                onPressed: () async {
                  controller.playerState.isPlaying
                      ? await controller.pausePlayer()
                      : await controller.startPlayer(
                    finishMode: FinishMode.loop,
                  );
                },
                icon: Icon(
                  controller.playerState.isPlaying
                      ? Icons.stop
                      : Icons.play_arrow,
                ),
                color: Colors.black,
              ),
            AudioFileWaveforms(
              size: Size(MediaQuery.of(context).size.width / 1.5, 70),
              playerController: controller,
              waveformType: widget.index?.isOdd ?? false
                  ? WaveformType.fitWidth
                  : WaveformType.long,
              playerWaveStyle: playerWaveStyle,
            ),
          ],
        ),
      ),
    )
        : const SizedBox.shrink();
  }
}
