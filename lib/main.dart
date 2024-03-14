import 'dart:async';
import 'dart:io';
import 'package:agconnect_core/agconnect_core.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nova/utils/navigationservice.dart';
import 'package:nova/utils/hive_preferences.dart';
import 'package:flutter/material.dart';
import 'package:nova/ui/splashscreen.dart';
import 'package:nova/app.dart';
import 'package:nova/constant/global.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:nova/services/services_locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sentry_logging/sentry_logging.dart';

const iOSLocalizedLabels = false;
AndroidNotificationChannel channel;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

const InitializationSettings initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
);


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Future<void> reportError(Object error, StackTrace stackTrace) async {
    globalAmplitudeService?.sendAmplitudeData('Error', error.toString(), true);
    globalAmplitudeService?.sendAmplitudeData(
        'Error stackTrace', stackTrace.toString(), true);
    await Sentry.captureException(
      error.toString(),
      stackTrace: stackTrace.toString(),
    );
  }

  void configLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.white
      ..backgroundColor = appColor
      ..indicatorColor = Colors.white
      ..textColor = Colors.white
      ..maskColor = Colors.purple.withOpacity(0.5)
      ..userInteractions = true
      ..dismissOnTap = false;
  }

  configLoading();
  ByteData data = await PlatformAssetBundle().load('assets/encrypt-r3.cer');
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: appColor,
      statusBarColor: Colors.deepPurpleAccent,
      statusBarIconBrightness: Brightness.light));
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  Amplitude.getInstance().init(dotenv.env['AMPLITUDE_API']);
  //
  Directory dir;
  if (Platform.isIOS) {
    dir = await pathProvider.getApplicationDocumentsDirectory();
  } else {
    dir = await pathProvider.getExternalStorageDirectory();
  }
  Hive.init(dir.path);
  setupServiceLocator();
  if (await isHuawei()) {
    await AGCApp.instance.setClientId(dotenv.env['HUAWEI_CLIENTID']);
    await AGCApp.instance.setClientSecret(dotenv.env['HUAWEI_CLIENTSECRET']);
    await AGCApp.instance.setApiKey(dotenv.env['HUAWEI_APIKEY']);
  }
  await HivePreferences.getInstance().then(
    (prefs) async {
      await SentryFlutter.init((options) {
        options.dsn =
            'https://5a0c5c4637744f60aff68e6f79b9a9b3@o4503997759488000.ingest.sentry.io/4503997760602112';
        options.tracesSampleRate = 1.0;
        options.addIntegration(LoggingIntegration());
      },
          appRunner: () => runZoned<Future<void>>(() async {
                await SystemChrome.setPreferredOrientations(
                        <DeviceOrientation>[DeviceOrientation.portraitUp])
                    .then((_) {
                  runApp(DefaultAssetBundle(
                      bundle:
                          SentryAssetBundle(enableStructuredDataTracing: true),
                      child: MaterialApp(
                          navigatorKey: NavigationService.navigatorKey,
                          debugShowCheckedModeBanner: false,
                          title: appName,
                          theme: ThemeData(
                              primaryColor: Colors.black,
                              primaryColorDark: Colors.black,
                              fontFamily: 'DMSans',
                              colorScheme: ColorScheme.fromSwatch()
                                  .copyWith(secondary: Colors.black)),
                          home: SplashScreen(),
                          routes: <String, WidgetBuilder>{
                            '/App': (BuildContext context) => App(prefs),
                          },
                        ),
                      ));
                });
              }, onError: reportError));

      FlutterError.onError = (details, {bool forceReport = false}) async {
        ErrorLogger().logError(details);
      };
    },
  );
}

class ErrorLogger {
  void logError(FlutterErrorDetails details) async {
    globalAmplitudeService?.sendAmplitudeData(
        'Flutter Error', details.exceptionAsString(), true);
    globalAmplitudeService?.sendAmplitudeData(
        'Flutter Error StackTrace', details.stack.toString(), true);
    await Sentry.captureException(
      details.exceptionAsString(),
    );
  }

  void log(Object data, StackTrace stackTrace) async {
    globalAmplitudeService?.sendAmplitudeData(
        'Flutter Error', data.toString(), true);
    globalAmplitudeService?.sendAmplitudeData(
        'Flutter Error StackTrace', stackTrace.toString(), true);
    await Sentry.captureException(
      stackTrace.toString(),
    );
  }
}
