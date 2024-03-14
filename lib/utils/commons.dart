import 'dart:convert';
import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nova/constant/global.dart';
import 'package:permission_handler/permission_handler.dart';

class Commons {

  static void requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
    ].request();
    print(statuses);
  }

  static GlobalKey<AnimatedListState> audioListKey =
  GlobalKey<AnimatedListState>();

  static String createCryptoRandomString([int length = 8]) {
    final Random _random = Random.secure();
    var values = List<int>.generate(length, (i) => _random.nextInt(256));
    return base64Url.encode(values);
  }

  static Widget errorNoInternet() {
    return Container(
      margin: EdgeInsets.only(top: 25.00),
      padding: EdgeInsets.all(10.00),
      color: Colors.orange,
      child: Row(
          children: [
        Container(
          margin: EdgeInsets.only(right: 6.00),
          child: Icon(Icons.wifi_off, color: Colors.white),
        ),
        Text("Please check your connection.",
            style: TextStyle(color: Colors.white)),
      ]),
    );
  }

  static offLineWidget() {
    return errorNoInternet();
  }

  static Widget novaLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.all(5),
            child: AnimatedTextKit(
              animatedTexts: [
                FadeAnimatedText(
                  "Connecting...",
                  textStyle: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.normal,
                      color: appColor),
                ),
                FadeAnimatedText(
                  'Connecting...',
                  textStyle: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.normal,
                      color: appColor),
                ),
                FadeAnimatedText(
                  'Retrieving messages...',
                  textStyle: TextStyle(
                      fontSize: 11.0,
                      fontFamily: "DMSans-Regular",
                      fontWeight: FontWeight.normal,
                      color: appColor),
                ),
              ],
            )),
      ],
    );
  }

  static Widget novaLoader() {
    return Center(
        child: SpinKitFadingCube(
          color: appColor,
        ));
  }

  static novaFlushBarError(BuildContext context, String message) {
    final snackBar = SnackBar(
      content:Text(message),
      backgroundColor: (Colors.red),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
