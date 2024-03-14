import 'package:flutter/material.dart';
import 'package:nova/ui/videoview.dart';
import 'package:nova/constant/global.dart';

// ignore: must_be_immutable
class FullScreenVideo extends StatefulWidget {
  String video;

  FullScreenVideo({this.video});
  @override
  SettingOptionsState createState() {
    return new SettingOptionsState();
  }
}

class SettingOptionsState extends State<FullScreenVideo> {
  bool isInView = true;
  bool isLoading;

  @override
  void initState() {
    isLoading = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appColorWhite,
        title: Text(
          "",
          style: TextStyle(
              fontFamily: "DMSans-Regular", fontSize: 17, color: appColorBlack),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: appColor,
            )),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: isLoading == true ? Center(child: loader()) : Container(),
          ),
          VideoView(url: widget.video, play: isInView, id: "not null"),
        ],
      ),
    );
  }
}
