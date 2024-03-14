import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';
import 'package:huawei_hmsavailability/huawei_hmsavailability.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/ui/settings/setting_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nova/ui/chat/main_tab_list.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/viewmodels/chat_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 0;
  List<dynamic> _handlePages = [];
  bool hasLoaded = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FlutterNetworkConnectivity _flutterNetworkConnectivity =
      FlutterNetworkConnectivity(
    isContinousLookUp: true,
    lookUpDuration: const Duration(seconds: 5),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SchedulerBinding.instance.addPostFrameCallback((_) => init());
    inChat = false;
    inHome = true;
    registerInternetConnectivityCheck();
    initAmplitudeProperties();
    checkHMSCore();
    clearBadgeData();
  }

  void checkHMSCore() async {
    if (await isHuawei()) {
      HmsApiAvailability client = HmsApiAvailability();
      int status = await client.isHMSAvailable();
      switch (status) {
        case 0:
          globalAmplitudeService?.sendAmplitudeData(
              "HMS Core (APK) is available.", "hms core", true);
          break;
        case 1:
          globalAmplitudeService?.sendAmplitudeData(
              "No HMS Core (APK) is found on device", "hms core", true);
          break;
        case 2:
          globalAmplitudeService?.sendAmplitudeData(
              "HMS Core (APK) installed is out of date", "hms core", true);
          break;
        case 3:
          globalAmplitudeService?.sendAmplitudeData(
              "HMS Core (APK) installed on the device is unavailable.",
              "hms core",
              true);
          break;
        case 9:
          globalAmplitudeService?.sendAmplitudeData(
              "HMS Core (APK) installed on the device is not the official version.",
              "hms core",
              true);
          break;
        case 21:
          globalAmplitudeService?.sendAmplitudeData(
              "The device is too old to support HMS Core.", "hms core", true);
          break;
      }
    }
  }

  void initAmplitudeProperties() async {
    if (await checkInternet()) {
      try {
        globalAmplitudeService?.setUserProperties();
      } catch (e) {}
    }
  }

  void registerInternetConnectivityCheck() async {
    _flutterNetworkConnectivity
        .getInternetAvailabilityStream()
        .listen((isInternetAvailable) async {
      if (isInternetAvailable) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (isOffline) {
          isOffline = false;
          await startAmplitude();
          if (!isSocketConnected()) {
            await startAppServices(context);
            await getLocalData();
            await Future.delayed(const Duration(milliseconds: 1000));
            ChatViewModel viewModel = serviceLocator<ChatViewModel>();
            await viewModel.checkBroadcasts(0);
            await viewModel.checkGroups(0);
            await viewModel.checkDirectMessages(0);
          }
          if (checkQueueActive) {
            checkQueue();
            checkQueueActive = false;
          }
        }
      } else {
        isOffline = true;
        checkQueueActive = true;
      }
    });
    await _flutterNetworkConnectivity.registerAvailabilityListener();
  }

  void init() async {
    _handlePages.add(MainTabList());
    _handlePages.add(SettingsOptions());
    setState(() {
      hasLoaded = true;
      firstLoad = true;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    WidgetsFlutterBinding.ensureInitialized();

    switch (state) {
      case AppLifecycleState.resumed:
        clearBadgeData();
        if (!imagePicked) {
          if (firstLoad) {
            isAppMinimized = false;
            globalAmplitudeService?.sendAmplitudeData(
                'AppResumed', 'resumed app', true);
            if (!isSocketConnected()) {
              await startAppServices(context);
              ChatViewModel viewModel = serviceLocator<ChatViewModel>();
              await Future.delayed(Duration(milliseconds: 3500));
              await viewModel.checkBroadcasts(0);
              await viewModel.checkGroups(0);
              await viewModel.checkDirectMessages(0);
            }
          }
        }
        appState = "resumed";
        break;
      case AppLifecycleState.inactive:
        globalAmplitudeService?.sendAmplitudeData(
            'AppInactive', 'inactive app', true);
        appState = "inactive";
        isAppMinimized = true;
        break;
      case AppLifecycleState.paused:
        globalAmplitudeService?.sendAmplitudeData(
            'AppPause', 'paused app', true);
        appState = "paused";
        isAppMinimized = true;
        break;
      case AppLifecycleState.detached:
        globalAmplitudeService?.sendAmplitudeData(
            'AppDetached', 'detached app', true);
        appState = "detached";
        isAppMinimized = true;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
        onWillPop: () async {
          if (_currentIndex == 0) {
            SystemNavigator.pop();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
          return false;
        },
        child: hasLoaded
            ? Scaffold(key: _scaffoldKey, body: MainTabList())
            : Scaffold(
                body: Center(
                    child: CircularProgressIndicator(
                color: Theme.of(context).scaffoldBackgroundColor,
              ))));
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
