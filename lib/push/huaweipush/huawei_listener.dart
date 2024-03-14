import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:huawei_push/huawei_push.dart';
import 'package:nova/models/device_token.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/services/services_locator.dart';


void backgroundMessageCallback(RemoteMessage remoteMessage) async {
  String data = remoteMessage.data;
  if (data != null) {
    print("Background message is received, sending local notification.");
    Push.localNotification({
      HMSLocalNotificationAttr.TITLE: '[Headless] DataMessage Received',
      HMSLocalNotificationAttr.MESSAGE: data
    });
  } else {
    print("Background message is received. There is no data in the message.");
  }
}

class HuaweiListen {

  static void huaweiListen(BuildContext context) async {

    String _token = '';
    void _onTokenEvent(Object event) {
        _token = event;
    }

    void _onTokenError(Object error) {
      PlatformException e = error as PlatformException;
      print("TokenErrorEvent" + e.message);
    }

    void _onMessageReceived(RemoteMessage remoteMessage) {
      String data = remoteMessage.data;
      if (data != null) {
        Push.localNotification({
          HMSLocalNotificationAttr.TITLE: 'DataMessage Received',
          HMSLocalNotificationAttr.MESSAGE: data
        });
        print("onMessageReceived Data: " + data);
      } else {
        print("onMessageReceived No data is present.");
      }
    }

    void _onMessageReceiveError(Object error) {
      print("onMessageReceiveError" + error.toString());
    }

    void _onRemoteMessageSendStatus(String event) {
      print("RemoteMessageSendStatus Status: " + event.toString());
    }

    void _onRemoteMessageSendError(Object error) {
      PlatformException e = error as PlatformException;
      print("RemoteMessageSendError Error: " + e.toString());
    }

    void _onNotificationOpenedApp(dynamic initialNotification) {
      if (initialNotification != null) {
        print("onNotificationOpenedApp" + initialNotification.toString());
      }
    }

    Future<void> initPlatformState() async {
      await Push.setAutoInitEnabled(true);
      Push.getTokenStream.listen(_onTokenEvent, onError: _onTokenError);
      await Push.getToken("getToken");
      Push.onNotificationOpenedApp.listen(_onNotificationOpenedApp);
      _token = await Push.getTokenStream.first;
      DeviceToken deviceToken = DeviceToken();
      UserToken user = UserToken();
      _token = 'huawei-' + _token;
      user.deviceToken = _token;
      deviceToken.user = user;
      HttpService _api = serviceLocator<HttpService>();
      _api.updateDeviceToken(deviceToken);
      print('Push Token: ' + _token);
      dynamic initialNotification = await Push.getInitialNotification();
      _onNotificationOpenedApp(initialNotification);
      Push.onMessageReceivedStream.listen(
        _onMessageReceived,
        onError: _onMessageReceiveError,
      );
      Push.getRemoteMsgSendStatusStream.listen(
        _onRemoteMessageSendStatus,
        onError: _onRemoteMessageSendError,
      );
    }

    initPlatformState();
  }
}
