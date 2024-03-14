import 'dart:async';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io' as io;
import 'package:nova/constant/global.dart';
import 'package:nova/constant/globals.dart';
import 'package:nova/ui/voice_notes_swipe/flow_shader.dart';
import 'package:nova/ui/voice_notes_swipe/lottie_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nova/ui/widgets/fadingmicrophone.dart';
import 'package:nova/utils/commons.dart';
import 'package:path_provider/path_provider.dart';

class RecordButton extends StatefulWidget {
  final AnimationController controller;
  final Function onStart;
  final Function onCancel;
  final Function onFinish;
  final Function onPause;
  final Function onContinue;

  const RecordButton(
      {Key key,
      this.controller,
      this.onStart,
      this.onCancel,
      this.onFinish,
      this.onPause,
      this.onContinue})
      : super(key: key);

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  static const double size = 50;

  final double lockerHeight = 200;
  double timerWidth = 0;

  Animation<double> buttonScaleAnimation;
  Animation<double> timerAnimation;
  Animation<double> lockerAnimation;

  Stopwatch stopwatch = Stopwatch();
  Timer timer;
  String recordDuration = "00:00";

  bool isLocked = false;
  bool showLottie = false;

  RecorderController recorderController;

  String path;
  String musicFile;
  bool isRecording = true;
  bool isRecordingCompleted = false;

  Directory appDirectory;
  bool isRecordingButton = false;

  @override
  void initState() {
    super.initState();
    buttonScaleAnimation = Tween<double>(begin: 1, end: 2).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticInOut),
      ),
    );
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _initDirControllers() async {
    appDirectory = await getApplicationDocumentsDirectory();
    String name = Commons.createCryptoRandomString(15);
    io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
    path = appDocDirectory.path + '/' + "recordings-$name.mp4";

    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
    await recorderController.record(path: path);
    setState(() {
      isRecordingButton = true;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    timerWidth =
        MediaQuery.of(context).size.width - 2 * Globals.defaultPadding - 4;
    timerAnimation =
        Tween<double>(begin: timerWidth + Globals.defaultPadding, end: 0)
            .animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.2, 1, curve: Curves.easeIn),
      ),
    );
    lockerAnimation =
        Tween<double>(begin: lockerHeight + Globals.defaultPadding, end: 0)
            .animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.2, 1, curve: Curves.easeIn),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (!isLocked) lockSlider(),
        if (!isLocked) cancelSlider(),
        if (!isLocked) audioButton(),
        if (!isLocked) backGroundAudio(),
        if (isLocked) timerLocked(),
      ],
    );
  }

  Widget lockSlider() {
    int isIOSValue = io.Platform.isIOS?20:0;
    return Positioned(
      bottom: -lockerAnimation.value-isIOSValue,
      child: Container(
        height: lockerHeight,
        width: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Globals.borderRadius),
          color: Theme.of(context).brightness != Brightness.dark
              ? Colors.white
              : novaDarkModeBlue,
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(
              FontAwesomeIcons.lock,
              size: 20,
              color: appColor,
            ),
            const SizedBox(height: 8),
            FlowShader(
              direction: Axis.vertical,
              child: Column(
                children: const [
                  Icon(Icons.keyboard_arrow_up),
                  Icon(Icons.keyboard_arrow_up),
                  Icon(Icons.keyboard_arrow_up),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cancelSlider() {
    return Positioned(
      right: -timerAnimation.value - 3,
      child: Container(
        height: size,
        width: timerWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Globals.borderRadius),
          color: Theme.of(context).brightness != Brightness.dark
              ? Colors.white
              : novaDarkModeBlue,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              showLottie
                  ? const LottieAnimation()
                  : Row(
                      children: [
                        Center(
                          child: FadingMicrophoneIcon(),
                        ),
                        const SizedBox(width: 20),
                        Text(recordDuration)
                      ],
                    ),
              const SizedBox(width: size),
              FlowShader(
                child: Row(
                  children: const [
                    Icon(Icons.keyboard_arrow_left),
                    Text("Slide to cancel")
                  ],
                ),
                duration: const Duration(seconds: 3),
                flowColors: const [appColor, Colors.grey],
              ),
              const SizedBox(width: size),
            ],
          ),
        ),
      ),
    );
  }

  Widget backGroundAudio() {
    return Positioned(
      bottom: -lockerHeight - 25,
      child: Container(
        height: lockerHeight,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }

  void _togglePlayPause() {
    setState(() {
      if (isRecording) {
        setState(() {
          isRecording = false;
        });
        widget.onPause();
        recorderController.pause();
        pauseTimer();
      } else {
        setState(() {
          isRecording = true;
        });
        widget.onContinue();
        recorderController.record();
        resumeTimer();
      }
    });
  }

  Widget timerLocked() {
    return Container(
      height: 140,
      width: MediaQuery.of(context).size.width - 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Globals.borderRadius),
        color: Theme.of(context).brightness != Brightness.dark
            ? Colors.white
            : novaDarkModeBlue,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(recordDuration),
                isRecordingButton ? novaRealTimeRecorder() : Container(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    recorderController.reset();
                    Vibrate.feedback(FeedbackType.heavy);
                    timer?.cancel();
                    recordDuration = "00:00";
                    setState(() {
                      showLottie = true;
                      isLocked = false;
                    });
                    Timer(const Duration(milliseconds: 1440), () async {
                      widget.controller.reverse();
                      showLottie = false;
                    });
                    resetTimer();
                    widget.onCancel();
                  },
                  child: SvgPicture.asset(
                    'assets/images/deletevn.svg',
                    fit: BoxFit.fill,
                    height: 25,
                    width: 25,
                  ),
                ),
                Spacer(),
                Expanded(
                    child: Platform.isIOS
                        ? Padding(
                            padding: const EdgeInsets.only(left: 32, bottom: 5),
                            child: IconButton(
                              icon: Icon(
                                isRecording
                                    ? Icons.pause_circle_outline
                                    : Icons.mic,
                                color: microphoneRed,
                                size: 45,
                              ),
                              onPressed: _togglePlayPause,
                            ))
                        : Padding(
                            padding: const EdgeInsets.only(left: 0, bottom: 10),
                            child: IconButton(
                              icon: Icon(
                                isRecording
                                    ? Icons.pause_circle_outline
                                    : Icons.mic,
                                color: microphoneRed,
                                size: 45,
                              ),
                              onPressed: _togglePlayPause,
                            ))),
                Spacer(),
                GestureDetector(
                  onTap: () async {
                    recorderController.reset();
                    final path = await recorderController.stop(false);
                    if (path != null) {
                      isRecordingCompleted = true;
                      debugPrint(path);
                      debugPrint(
                          "Recorded file size: ${File(path).lengthSync()}");
                    }
                    Vibrate.feedback(FeedbackType.success);
                    timer?.cancel();
                    recordDuration = "00:00";
                    setState(() {
                      isLocked = false;
                    });
                    resetTimer();
                    widget.onFinish();
                  },
                  child: Container(
                    padding: EdgeInsets.all(10), // Adjust the padding as needed
                    child: SvgPicture.asset(
                      'assets/images/sendvn.svg',
                      fit: BoxFit.fill,
                      height: 45,
                      width: 45,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget audioButton() {
    return GestureDetector(
      child: Transform.scale(
        scale: buttonScaleAnimation.value,
        child: Container(
          child: const Icon(Icons.mic, color: Colors.white),
          height: size,
          width: size,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: appColor,
          ),
        ),
      ),
      onLongPressDown: (_) {
        debugPrint("onLongPressDown");
        widget.controller.forward();
        widget.onStart();
      },
      onLongPressEnd: (details) async {
        debugPrint("onLongPressEnd");

        if (isCancelled(details.localPosition, context)) {
          Vibrate.feedback(FeedbackType.heavy);

          timer?.cancel();
          recordDuration = "00:00";

          setState(() {
            showLottie = true;
          });

          Timer(const Duration(milliseconds: 1440), () async {
            widget.controller.reverse();
            debugPrint("Cancelled recording");
            showLottie = false;
          });
          resetTimer();
          widget.onCancel();
        } else if (checkIsLocked(details.localPosition)) {
          widget.controller.reverse();
          Vibrate.feedback(FeedbackType.heavy);
          debugPrint("Locked recording");
          debugPrint(details.localPosition.dy.toString());
          setState(() {
            isLocked = true;
          });
        } else {
          widget.controller.reverse();
          Vibrate.feedback(FeedbackType.success);

          timer?.cancel();
          recordDuration = "00:00";
          resetTimer();
          widget.onFinish();
        }
      },
      onLongPressCancel: () {
        debugPrint("onLongPressCancel");
        resetTimer();
        widget.controller.reverse();
        widget.onCancel();
      },
      onLongPressStart: (_) async {
        debugPrint("onLongPress");
        Vibrate.feedback(FeedbackType.success);

        startTimer();
      },
    );
  }

  void startTimer() {
    stopwatch.start();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (stopwatch.isRunning) {
        setState(() {
          recordDuration = formatDuration(stopwatch.elapsed);
        });
      }
    });
    _initDirControllers();
  }

  void pauseTimer() {
    if (stopwatch.isRunning) {
      stopwatch.stop();
      timer.cancel();
    }
  }

  void resumeTimer() {
    if (!stopwatch.isRunning) {
      stopwatch.start();
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (stopwatch.isRunning) {
          setState(() {
            recordDuration = formatDuration(stopwatch.elapsed);
          });
        }
      });
    }
  }

  void resetTimer() {
    stopwatch.stop();
    stopwatch.reset();
    isRecording = true;
    setState(() {
      recordDuration = formatDuration(Duration.zero);
    });
  }

  String formatDuration(Duration duration) {
    final min = (duration.inSeconds ~/ 60).toString().padLeft(2, '0');
    final sec = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  Widget novaRealTimeRecorder() {
    return Row(
      children: [
        AudioWaveforms(
          enableGesture: false,
          size: Size(MediaQuery.of(context).size.width / 1.4, 60),
          recorderController: recorderController,
          waveStyle: const WaveStyle(
            waveColor: waveColor,
            spacing: 5,
            extendWaveform: true,
            showMiddleLine: false,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Theme.of(context).brightness != Brightness.dark
                ? Colors.white
                : novaDarkModeBlue,
          ),
          padding: const EdgeInsets.only(left: 4),
          margin: const EdgeInsets.symmetric(horizontal: 15),
        ),
      ],
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    recorderController.dispose();
    super.dispose();
  }

  bool checkIsLocked(Offset offset) {
    return (offset.dy < -35);
  }

  bool isCancelled(Offset offset, BuildContext context) {
    return (offset.dx < -(MediaQuery.of(context).size.width * 0.2));
  }
}
