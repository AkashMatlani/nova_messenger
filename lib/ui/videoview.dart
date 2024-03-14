import 'package:flutter/material.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  final String url;
  final bool play;
  final String id;

  VideoView({this.url, this.play, this.id});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<VideoView> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  VideoPlayerController _controller;

  Duration duration, position;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(
      widget.url,
      //closedCaptionFile: _loadCaptions(),
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize();

    if (widget.play) {
      _controller.play();
      _controller.setLooping(true);
    }

    duration = _controller.value.duration;
    position = _controller.value.position;
    if (duration != null && position != null)
      position = (position > duration) ? duration : position;
  }

  @override
  void didUpdateWidget(VideoView oldWidget) {
    if (oldWidget.play != widget.play) {
      if (widget.play) {
        _controller.play();
        _controller.setLooping(true);
      } else {
        _controller.pause();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Center(
            child: Container(
          color: Colors.black,
          width: SizeConfig.screenWidth,
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                VideoPlayer(_controller),
                ClosedCaption(text: _controller.value.caption.text),
                _PlayPauseOverlay(controller: _controller, id: widget.id),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  final String id;

  const _PlayPauseOverlay({Key key, this.controller, this.id})
      : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
            duration: Duration(milliseconds: 50),
            reverseDuration: Duration(milliseconds: 200),
            child: SizedBox.shrink()),
        id == null
            ? Align(
                alignment: Alignment.center,
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[300], shape: BoxShape.circle),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.play_arrow,
                        size: 60,
                        color: Colors.grey[800],
                      ),
                    )))
            : Container()
      ],
    );
  }
}
