import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:nova/ui/onboarding/onboarding.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nova/utils/hive_preferences.dart';
import 'package:flutter/material.dart';
import 'package:nova/ui/home/homescreen.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:nova/provider/countries.dart';
import 'package:provider/provider.dart';

class AppThemes {

  static const int Light = 0;
  static const int Dark = 1;

  static String toStr(int themeId) {
    switch (themeId) {
      case Light:
        return "Light";
      case Dark:
        return "Dark";

      default:
        return "Unknown";
    }
  }
}

class App extends StatefulWidget  {

  final HivePreferences prefs;
  App(this.prefs);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {

  @override
  void initState() {
    super.initState();
    getBuild();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final themeCollection = ThemeCollection(themes: {
      AppThemes.Light: ThemeData(
        primaryColor: appColor,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          headline6: TextStyle(fontSize: 25, fontFamily: 'DMSans-Regular'),
          bodyText1: TextStyle(
              fontSize: 16,
              fontFamily: 'DMSans-Medium',
              fontWeight: FontWeight.bold),
        ),
      ),
      AppThemes.Dark: ThemeData(
        // fontFamily: 'Poppins',
        primaryColor: appColor,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: novaDarkModeBlue,
        textTheme: const TextTheme(
          headline6: TextStyle(fontSize: 25, fontFamily: 'DMSans-Regular'),
        ),
      ),
    });
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => CountryProvider(),
          ),
        ],
        child: DynamicTheme(
            themeCollection: themeCollection,
            defaultThemeId: AppThemes.Light,
            builder: (context, theme) {
              return MaterialApp(
                theme: theme,
                debugShowCheckedModeBanner: false,
                home: _handleCurrentScreen(widget.prefs),
                builder: EasyLoading.init(),
              );
            }));
  }

  Widget _handleCurrentScreen(HivePreferences prefs) {
    bool loggedIn = prefs.getIsLoggedIn() ?? false;
    final mediaQueryData = MediaQuery.of(context);
    final scale = mediaQueryData.textScaleFactor.clamp(0.8, 1.35);
    if (loggedIn == false) {
      return MediaQuery(
        child: OnBoarding(),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      );
    } else {
      return MediaQuery(
        child: HomeScreen(),
        data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
      );
    }
  }
}