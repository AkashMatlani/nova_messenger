import 'dart:io';
import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/ui/edit_profile.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/ui/intro.dart';
import 'package:nova/utils/commons.dart';
import 'package:share_plus/share_plus.dart';

class SettingsOptions extends StatefulWidget {
  @override
  _SettingsOptionsState createState() => _SettingsOptionsState();
}

class _SettingsOptionsState extends State<SettingsOptions> {
  double _height, _width, _fixedPadding;
  bool themeSwitch = false;

  @override
  void initState() {
    super.initState();
    inHome = false;
    print("InHome = " + inHome.toString());
  }

  @override
  void dispose() {
    super.dispose();
  }

  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _fixedPadding = _height * 0.025;

    if (Theme.of(context).brightness == Brightness.dark) {
      setState(() {
        themeSwitch = true;
      });
    } else {
      setState(() {
        themeSwitch = false;
      });
    }
    print(Theme.of(context).brightness);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headline6,
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor:
        Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).brightness != Brightness.dark?Colors.black:Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back when the button is pressed
          },
        ),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              height:
                  _height - kToolbarHeight - MediaQuery.of(context).padding.top,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Card(
                      elevation: 0,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              imageWidget(),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    globalName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditProfile(refresh: refresh),
                                    ),
                                  );
                                },
                                child: SvgPicture.asset(
                                  "assets/images/editsettings.svg",
                                  color: Theme.of(context).brightness ==
                                      Brightness.dark
                                      ? Colors.white
                                      : appColor,
                                ),
                              ),
                              SizedBox(width: 5),
                              GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditProfile(refresh: refresh),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : appColor,
                                    ),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  Card(
                    elevation: 0,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: ListTile(
                      onTap: () async {
                        if (themeSwitch != true) {
                          setState(() {
                            themeSwitch = true;
                          });
                          setBrightness(Brightness.dark);
                          DynamicTheme.of(context).setTheme(1);
                        } else {
                          setState(() {
                            themeSwitch = false;
                          });
                          setBrightness(Brightness.light);
                          DynamicTheme.of(context).setTheme(0);
                        }
                      },
                      leading: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: themeSwitch
                            ? Icon(
                                Icons.light_mode_outlined,
                                color: Colors.white,
                              )
                            : Icon(
                                Icons.dark_mode_outlined,
                                color: Colors.black,
                              ),
                      ),
                      trailing: CupertinoSwitch(
                        onChanged: (bool value) async {
                          if (themeSwitch != true) {
                            setState(() {
                              themeSwitch = true;
                            });
                            setBrightness(Brightness.dark);
                            DynamicTheme.of(context).setTheme(1);
                          } else {
                            setState(() {
                              themeSwitch = false;
                            });
                            setBrightness(Brightness.light);
                            DynamicTheme.of(context).setTheme(0);
                          }
                        },
                        value: themeSwitch,
                      ),
                      title: Text('App Theme'),
                      subtitle: Text(
                        'Manage your app theme',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  Card(
                    elevation: 0,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: ListTile(
                      onTap: () async {
                        var appId = "id1621358108";
                        if (Platform.isAndroid) {
                          Share.share(
                            "Let's chat on $appName! It's a fast, simple, and secure app we can use to message and call each other for free. Get it at https://play.google.com/store/apps/details?id=com.novamesseneger.chat",
                          );
                        } else {
                          Share.share(
                            "Let's chat on $appName! It's a fast, simple, and secure app we can use to message and call each other for free. Get it at https://apps.apple.com/za/app/nova-messenger/id=$appId",
                          );
                        }
                      },
                      leading: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: themeSwitch
                            ? Icon(
                                Icons.share_outlined,
                                color: Colors.white,
                              )
                            : Icon(
                                Icons.share_outlined,
                                color: Colors.black,
                              ),
                      ),
                      title: Text('Tell a Friend'),
                      subtitle: Text(
                        'Share our app with your friends',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 5,
            child: Column(
              children: [
                GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Delete Account?"),
                            content: Text(
                                "Are you sure you want to delete your account?"),
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: appColor, // Set the background color here
                                ),
                                child: Text("OK"),
                                onPressed: () async {
                                  HttpService _api =
                                      serviceLocator<HttpService>();
                                  var deleteResponse =
                                      await _api.deleteAccount();
                                  if (deleteResponse != null) {
                                    Navigator.pushAndRemoveUntil<dynamic>(
                                      context,
                                      MaterialPageRoute<dynamic>(
                                        builder: (BuildContext context) =>
                                            Intro(),
                                      ),
                                      (route) => false,
                                    );
                                  } else {
                                    Commons.novaFlushBarError(
                                      context,
                                      "There was an error deleting your account. Please try again.",
                                    );
                                  }
                                },
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: appColor, // Set the background color here
                                ),
                                child: Text("Cancel"),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            "assets/images/deleteaccount.svg",
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            'Delete account',
                            style: TextStyle(
                              fontSize: 14,
                              color: novaErrorRed,
                            ),
                          ),
                        ],
                      ),
                    )),
                Divider(height: 1),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Build Version: ' + version,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget imageWidget() {
    return globalImage != ""
        ? Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: customImage(globalImage),
            ),
          )
        : Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                "assets/images/user.png",
                height: 10,
                color: Colors.white,
              ),
            ),
          );
  }
}
