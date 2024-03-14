import 'package:flutter/material.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:nova/utils/hive_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  void navigationPage() async {
    final prefs = await HivePreferences.getInstance();
    bool loggedIn = prefs.getIsLoggedIn() ?? false;
    if (loggedIn == true) {
      await getLocalData();
      if (await checkInternet()) {
        await startAmplitude();
      } else {
        isOffline = true;
      }
    } else {
      await HivePreferences.deleteAllPreferences();
      if (await checkInternet()) {
        await startAmplitude();
      }
    }
    getBuild();
    Navigator.of(context).pushReplacementNamed('/App');
  }

  @override
  void initState() {
    super.initState();
    navigationPage();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            Center(
              child: Container(
                height: double.infinity,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      child: Image.asset(
                        'assets/images/applogo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
            bottomWidget()
          ],
        ));
  }

  Widget bottomWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "from",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black45, fontSize: 16, fontFamily: boldFamily),
            ),
          ],
        ),
        Container(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$appName",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: appColor, fontSize: 20, fontFamily: boldFamily),
            ),
          ],
        ),
        Container(height: 40),
      ],
    );
  }
}
