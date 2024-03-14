import 'dart:async';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/identify.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/services/services_locator.dart';

class AmplitudeService {

  HttpService _api = serviceLocator<HttpService>();
  String connectivityResult;
  Amplitude analytics;

  AmplitudeService() {}

  Amplitude getAnalyticService() {
    return analytics;
  }

  startAmplitudeService() async {
    try {
      analytics = Amplitude.getInstance(instanceName: "Nova Messenger");
      analytics.setUseDynamicConfig(true);
      analytics.setServerUrl("https://api2.amplitude.com");
      analytics.init(dotenv.env['AMPLITUDE_API']);
      analytics.enableCoppaControl();
      analytics.setServerZone("ZA");
      analytics.logEvent('StartAmplitude', eventProperties: {'started amplitude': true});
      analytics.setOptOut(true);
      analytics.setOptOut(false);
    } catch (e) {
      print("Error initializing Amplitude.");
      HttpService _api = serviceLocator<HttpService>();
      _api.logTelemetryData("Amplitude error log" + e.toString());
    }
  }

  void setUserProperties()async{
    await _api.getUser();
    await _checkConnectivityState();
    analytics.setUserId(userUuid, startNewSession: true);
    analytics.setUserProperties({
      'Username': globalName,
      'User mobile': globalMobile,
      "Connectivity type": connectivityResult,
      "User uuid": userUuid,
      "User token": userToken,
    });
    final Identify identify = Identify()..set('User uuid', userUuid);
    Amplitude.getInstance().identify(identify);
  }

  Future<void> _checkConnectivityState() async {
    final result = await (Connectivity().checkConnectivity());

    if (result == ConnectivityResult.wifi) {
      connectivityResult = "WIFI network";
    } else if (result == ConnectivityResult.mobile) {
      connectivityResult = "Mobile network";
    } else {
      connectivityResult = "No network";
    }
  }

  void sendAmplitudeData(String data, String eventProperty, bool eventBool) async {
    if (await checkInternet()) {
      try {
        if (analytics != null) {
          analytics.logEvent(data, eventProperties: {eventProperty: eventBool});
        }
      } catch (e) {
        HttpService _api = serviceLocator<HttpService>();
        _api.logTelemetryData("Amplitude error log" + e.toString());
      }
    }
  }

  void logAmplitudeData(
      String event, String eventDetail, String uuid, String name) async {
    Timer.run(() async {
      try {
        if (analytics != null) {
          analytics.logEvent(event,
              eventProperties: {eventDetail: true, "uuid": uuid, "chat": name});
        }
      } catch (e) {
        HttpService _api = serviceLocator<HttpService>();
        _api.logTelemetryData("Amplitude error log" + e.toString());
      }
    });
  }
}
