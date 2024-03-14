import 'package:flutter/material.dart';
import 'package:nova/constant/global.dart';

class FadingMicrophoneIcon extends StatefulWidget {
  @override
  _FadingMicrophoneIconState createState() => _FadingMicrophoneIconState();
}

class _FadingMicrophoneIconState extends State<FadingMicrophoneIcon>
    with TickerProviderStateMixin {

  AnimationController _controller;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Icon(
            Icons.mic,
            color: microphoneRed,
            size: 30,
          ),
        );
      },
    );
  }
}
