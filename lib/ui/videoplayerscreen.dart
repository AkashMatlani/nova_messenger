import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:http/http.dart';
import 'package:nova/utils/commons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:nova/constant/global.dart';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class VideoNovaPlayer extends StatefulWidget {

  String url;
  VideoNovaPlayer({this.url});

  @override
  _VideoNovaPlayerState createState() => _VideoNovaPlayerState();
}

class _VideoNovaPlayerState extends State<VideoNovaPlayer> {

  bool downLoadingVideo = true;
  double _progress = 0;

  get downloadProgress => _progress;

  get downloadProgressText => _progress * 100;
  double downloadProgressTextRound = 0;

  VideoPlayerController _controller;
  Chewie chewie;
  ChewieController chewieController;

  void startDownloading() async {
    globalAmplitudeService?.sendAmplitudeData('VideoStarted', "Video download started", true);


    _progress = null;
    final url = widget.url;
    final request = Request('GET', Uri.parse(url));
    final StreamedResponse response = await Client().send(request);

    final contentLength = response.contentLength;

    _progress = 0;

    List<int> bytes = [];
    String extension = "." + widget.url.split('.').last;
    final file = await _getFile('novaVideo' + extension);
    response.stream.listen(
      (List<int> newBytes) {
        bytes.addAll(newBytes);
        if (mounted) {
          setState(() {
            final downloadedLength = bytes.length;
            _progress = downloadedLength / contentLength;
            double percentage = _progress * 100;
            downloadProgressTextRound = percentage.roundToDouble();
          });
        }
      },
      onDone: () async {
        await file.writeAsBytes(bytes);
        _controller = VideoPlayerController.file(
          file,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
        _controller.addListener(() {
          if (mounted)
          setState(() {});
        });
        _controller.setLooping(true);
        _controller.initialize();
        chewieController = ChewieController(
            videoPlayerController: _controller,
            autoPlay: false,
            looping: false,
            materialProgressColors:ChewieProgressColors(backgroundColor: Colors.grey,bufferedColor: Colors.grey,
                handleColor: appColor,playedColor: appColor),
            fullScreenByDefault: false,
            showControls:true,
            allowFullScreen: true);
        chewie = Chewie(
          controller: chewieController,
        );
        chewieController.addListener(() {});
        if (mounted) {
          setState(() {
            downLoadingVideo = false;
          });
        }
        globalAmplitudeService?.sendAmplitudeData('VideoCompletedDownload', "Completed video download.", true);
      },
      onError: (e) {
        globalAmplitudeService?.sendAmplitudeData('VideoError', "Error downloading video file. Please try again.", true);
        Commons.novaFlushBarError(
            context, "Error downloading video file. Please try again.");
      },
      cancelOnError: true,
    );
  }

  Future<File> _getFile(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/$filename");
  }

  @override
  void initState() {
    super.initState();
    startDownloading();
  }

  @override
  void dispose() {
    chewieController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: appColor,
          title: Text(
            "Nova Video Player",
            style: TextStyle(
                fontFamily: "DMSans-Regular",
                fontSize: 17,
                color: Colors.white),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              )),
        ),
        body: downLoadingVideo
            ? Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        strokeWidth: 10,
                        color: appColor,
                        value: downloadProgress,
                      ),
                    ),
                    Text(
                      downloadProgressTextRound.toString() + " %",
                      style:
                          TextStyle(fontSize: 14, fontFamily: "DMSans-Regular"),
                    ),
                  ],
                ),
              )
            : Center(
                child: Container(
                  color: Colors.black,
                  height: MediaQuery.of(context).size.height,
                  padding: const EdgeInsets.all(20),
                  child: _controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: Theme(
                              data: Theme.of(context).copyWith(
                                dialogBackgroundColor: appColor,
                              ),
                              child: Chewie(
                                controller: chewieController,
                              )),
                        )
                      : Center(
                          child: SizedBox(
                              height: 30.0,
                              width: 30.0,
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(appColor),
                                  strokeWidth: 1.0))),
                ),
              ));
  }
}
