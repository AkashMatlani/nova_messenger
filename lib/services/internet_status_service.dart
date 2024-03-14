import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

enum InternetNetworkStatus { Online, Offline }

class InternetStatusService extends ChangeNotifier{

  static bool isOnline = true;
  bool isOnlineCheck = true;
  StreamController<InternetNetworkStatus> networkStatusController =
  StreamController<InternetNetworkStatus>();

  InternetStatusService() {
    InternetConnectionChecker().onStatusChange.listen((status) async{
      switch (status) {
        case InternetConnectionStatus.connected:
          isOnline = isOnlineCheck = true;
          notifyListeners();
          break;
        case InternetConnectionStatus.disconnected:
          isOnline = isOnlineCheck = false;
          notifyListeners();
          break;
      }
      networkStatusController.add(_getNetworkStatus(status));
    });
  }

  InternetNetworkStatus _getNetworkStatus(InternetConnectionStatus status) {
    return status == InternetConnectionStatus.connected ? InternetNetworkStatus.Online : InternetNetworkStatus.Offline;
  }
}