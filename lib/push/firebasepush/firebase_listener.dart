import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/main.dart';
import 'package:nova/push/firebasepush/notifications_badge.dart';
import 'package:nova/push/firebasepush/push_notification.dart';
import 'package:nova/models/device_token.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/ui/splashscreen.dart';
import 'package:nova/utils/navigationservice.dart';
import 'package:nova/utils/commons.dart';
import 'package:overlay_support/overlay_support.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await setupFlutterNotifications();
  showFlutterNotification(message);
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification notification = message.notification;
  AndroidNotification android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: 'launch_background',
        ),
      ),
    );
  }
}

bool isFlutterLocalNotificationsInitialized = false;
AndroidNotificationChannel channel;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

class FirebaseListen {
  static void firebaseListen(BuildContext context) async {

    WidgetsFlutterBinding.ensureInitialized();

    FirebaseMessaging _messaging;

    int _totalNotifications = 1;
    PushNotification _notificationInfo;

    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;
    _messaging.getToken().then((token) async {
      DeviceToken deviceToken = DeviceToken();
      UserToken user = UserToken();
      if (Platform.isAndroid) {
        token = 'fcm-' + token;
      } else if (Platform.isIOS) {
        token = 'apns-' + token;
      }
      user.deviceToken = token;
      deviceToken.user = user;
      HttpService _api = serviceLocator<HttpService>();
      _api.updateDeviceToken(deviceToken);
    });

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        WidgetsFlutterBinding.ensureInitialized();
        print(
            'Message title: ${message.notification?.title}, body: ${message.notification?.body}, data: ${message.data}');

        String body = message.data['body'] ?? "";
        String messageDataFromUuid = message.data['from_uuid'];
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
          dataTitle: message.data['title'],
          dataBody: body,
        );

        _notificationInfo = notification;

        if (_notificationInfo != null) {
          if (Platform.isIOS) {
            if (inChatUuid != messageDataFromUuid) {
              showSimpleNotification(
                Text(_notificationInfo.title),
                leading: NotificationBadge(_totalNotifications),
                subtitle: Text(_notificationInfo.body),
                background: appColor,
                duration: Duration(seconds: 2),
              );
            }
          } else {
            if (inChatUuid != messageDataFromUuid) {
              showDialog(
                  context: NavigationService.navigatorKey.currentContext,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        "Nova Notification",
                        style: TextStyle(
                            color: appColor, fontWeight: FontWeight.bold),
                      ),
                      content: Text(
                        _notificationInfo.body,
                        style: TextStyle(
                            color: appColor, fontWeight: FontWeight.normal),
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            "Ok",
                            style: TextStyle(
                                color: appColor, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            if (inHome == false) {
                              Navigator.pushAndRemoveUntil<dynamic>(
                                NavigationService.navigatorKey.currentContext,
                                MaterialPageRoute<dynamic>(
                                  builder: (BuildContext context) =>
                                      SplashScreen(),
                                ),
                                (route) =>
                                    false, //if you want to disable back feature set to false
                              );
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                        )
                      ],
                    );
                  });
            }
          }
        }
      });
    } else {
      print('User declined or has not accepted permission');
      Commons.novaFlushBarError(context,
          'You will not receive any push notifications until you have accepted notifications in your settings.');
      if (Platform.isIOS) {
        openAppSettings();
      }
    }

    Stream<RemoteMessage> _stream = FirebaseMessaging.onMessageOpenedApp;
    _stream.listen((RemoteMessage message) async {
      if (message.data != null) {
        String messageDataType = message.data['type'];
        String messageDataFromUuid = message.data['from_uuid'];
        fromPushUuid = messageDataFromUuid;
        fromPushType = messageDataType;
        if (inHome == false) {
          inChatUuid = "";
          Navigator.pushAndRemoveUntil<dynamic>(
            NavigationService.navigatorKey.currentContext,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => SplashScreen(),
            ),
            (route) => false, //if you want to disable back feature set to false
          );
        }
      }
    });
  }
}
