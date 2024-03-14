import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/models/broadcast_list.dart';
import 'package:nova/models/group_chat_data.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/utils/hive_preferences.dart';
import 'package:phoenix_wings/phoenix_wings.dart';
import 'package:nova/viewmodels/chat_viewmodel.dart';
import 'package:nova/viewmodels/chat_list_viewmodel.dart';
import 'dart:async';

class SocketService {
  static PhoenixSocket socketPhoenix;
  static String userIdPhoenix;
  static String userPhoenixToken;
  static BuildContext context;
  static int maxPushAttempts = 3;
  static const Map defaultPayload = {};
  static const List generalEvents = [
    "say",
    "list_deleted",
    "incoming_chats",
    "message_status_update",
    "message_deleted",
    "messages_updated",
    "chat_archived",
    "broadcasts_updated",
    "new_list",
    "new_group",
    "contact_updated",
    "chat_archived",
    "list_chat_archived",
    "group_chat_archived",
    "list_chat_activated",
    "group_chat_activated",
    "message_updated",
  ];

  static const List groupEvents = [
    "group_message_say",
    "group_message_deleted",
    "incoming_group_messages",
    "group_deleted",
    "group_message_status_update",
    "group_message_updated"
  ];

  static const List broadcastEvents = [
    "broadcast_say",
    "broadcast_deleted",
    "list_deleted",
    "incoming_broadcasts",
    "broadcast_updated"
  ];

  HttpService _api = serviceLocator<HttpService>();
  bool rebootPhoenix = false;

  static var broadcastChannels = Map<String, PhoenixChannel>();
  static var groupChannels = Map<String, PhoenixChannel>();
  PhoenixChannel channelGeneralUser;

  static var loadMessagesLookup = Map<String, bool>();

  SocketService(userToken, userId, context) {
    userIdPhoenix = userId;
    userPhoenixToken = userToken;
    context = context;
  }

  void closeSocket() {
    socketPhoenix.disconnect();
  }

  void restartServices() async {
    globalAmplitudeService?.sendAmplitudeData(
        'Restart Services', 'services restarted', true);
    await startAppServices(context);
    ChatViewModel viewModel = serviceLocator<ChatViewModel>();
    await Future.delayed(Duration(milliseconds: 3500));
    await viewModel.checkBroadcasts(0);
    await viewModel.checkGroups(0);
    await viewModel.checkDirectMessages(0);
  }

  void _listenForDisconnect() async {
    socketPhoenix.onOpen(() => {});
    socketPhoenix.onClose((event) {
      restartServices();
    });
  }

  Future<bool> startPhoenixServices() async {
    final preferences = await HivePreferences.getInstance();
    userUuid = preferences.getUserId();
    globalAmplitudeService?.sendAmplitudeData('startPhoenixServices', "", null);
    await _initSocket();
    return true;
  }

  PhoenixSocket getPhoenixSocket() {
    return socketPhoenix;
  }

  PhoenixChannel getGeneralChannel() {
    return channelGeneralUser;
  }

  PhoenixChannel getChannel(String id, String type) {
    PhoenixChannel channel;
    switch (type) {
      case "general":
        {
          channel = getGeneralChannel();
        }
        break;

      case "broadcast":
        {
          channel = getBroadcastChannel(id);
        }
        break;

      case "group":
        {
          channel = getGroupChannel(id);
        }
        break;
    }
    return channel;
  }

  void push(
      {String id = "general",
      String type = "general",
      String event,
      Map payload = defaultPayload,
      int counter = 1}) async {
    PhoenixChannel channel = getChannel(id, type);
    if (channel != null && channel.canPush) {
      channel.push(event: event, payload: payload);
      if (event == "load_chats") {
        globalAmplitudeService?.sendAmplitudeData(
            'LoadChats', 'load chat messages', true);
      }
    } else {
      if (counter <= maxPushAttempts) {
        Timer(Duration(milliseconds: counter * 100), () {
          push(
              id: id,
              type: type,
              event: event,
              payload: payload,
              counter: counter++);
        });
      }
    }
  }

  void on(
      {String event,
      String id = "general",
      String type = "general",
      callback}) {
    PhoenixChannel channel = getChannel(id, type);
    channel.on(event, callback);
  }

  void sendTelemetryData(event, data) async {
    Timer.run(() async {
      await push(
          event: "client_log",
          payload: {"event_triggered": event, "data": data});
    });
  }

  void cleanup() {
    PhoenixChannel general = getGeneralChannel();
    generalEvents.forEach((event) {
      general?.off(event);
    });
    general?.leave();
    broadcastChannels.forEach((key, value) {
      broadcastEvents.forEach((event) {
        value?.off(event);
      });
      value?.leave();
    });
    groupChannels.forEach((key, value) {
      groupEvents.forEach((event) {
        value?.off(event);
      });
      value?.leave();
    });
    groupChannels = {};
    broadcastChannels = {};
    loadMessagesLookup = {};
  }

  bool isSocketConnected() {
    return socketPhoenix.isConnected;
  }

  void phoenixSocketReBirth() {
    cleanup();
    globalAmplitudeService?.sendAmplitudeData('SocketService', 'started', true);
    final PhoenixSocket socket = PhoenixSocket(
        "wss://" + dotenv.env['SERVERSocket'] + "/socket/websocket",
        socketOptions: PhoenixSocketOptions(
          heartbeatIntervalMs: 10000,
          params: {
            "token":
                "JBZVA6Kvvuk93W/gEM1G8ABNNzLby2lyPZCRlWEWN87aEyBla7zDppFrunEyvT9S",
            "user_token": userPhoenixToken
          },
        ));
    socketPhoenix = socket;

    // Timer.periodic(const Duration(seconds: 10), (_) {
    //   sendTelemetryData("heartBeat", inspect(appState));
    // });
  }

  PhoenixChannel getBroadcastChannel(String uuid) {
    // print("broadcastChannels = " + broadcastChannels.toString());
    // print("broadcastChannels uuid = " + broadcastChannels[uuid].toString());
    return broadcastChannels[uuid];
  }

  PhoenixChannel getGroupChannel(String uuid) {
    // print("groupChannels = " + groupChannels.toString());
    // print("groupChannels uuid = " + groupChannels[uuid].toString());
    return groupChannels[uuid];
  }

  void setBroadcastChannel(String listUuid) {
    broadcastChannels[listUuid] =
        socketPhoenix.channel("list:" + listUuid, {"uuid": userUuid});
    broadcastChannels[listUuid].join();
  }

  void setGroupChannel(String groupUuid) {
    groupChannels[groupUuid] =
        socketPhoenix.channel("group:" + groupUuid, {"uuid": userUuid});
    groupChannels[groupUuid].join();
    // print("groupChannels = " + groupChannels.toString());
    // print("groupChannels uuid = " + groupChannels[groupUuid].toString());
  }

  Map<String, PhoenixChannel> getBroadCastChannels() {
    return broadcastChannels;
  }

  Map<String, PhoenixChannel> getGroupChannels() {
    return groupChannels;
  }

  void initListeners() {
    ChatListViewModel listViewModel = serviceLocator<ChatListViewModel>();

    on(event: "incoming_chats", callback: listViewModel.loadChats);
    on(event: "list_deleted", callback: listViewModel.deleteLocalListChat);

    ChatViewModel viewModel = serviceLocator<ChatViewModel>();
    // General
    on(event: "say", callback: viewModel.incomingDirectSay);
    on(event: "incoming_messages", callback: viewModel.incomingDirectMessages);
    on(
        event: "message_status_update",
        callback: viewModel.updateDirectStatusMessage);
    on(event: "message_deleted", callback: viewModel.removeDirectMessages);
    on(event: "messages_updated", callback: viewModel.updateStatusMessages);
    on(event: "chat_archived", callback: viewModel.updateArchivedChat);
    on(
        event: "broadcasts_updated",
        callback: viewModel.updatedBroadCastMessages);
    on(event: "new_list", callback: viewModel.newListAdded);
    on(event: "new_group", callback: viewModel.newGroupAdded);
    on(event: "contact_updated", callback: viewModel.contactUpdated);
    on(event: "chat_archived", callback: viewModel.reloadAllChats);
    on(event: "list_chat_archived", callback: viewModel.listChatArchived);
    on(event: "group_chat_archived", callback: viewModel.groupChatArchived);
    on(event: "list_chat_activated", callback: viewModel.reloadAllChats);
    on(event: "group_chat_activated", callback: viewModel.reloadAllChats);

    on(event: "message_updated", callback: viewModel.messageUpdated);
    on(event: "broadcast_updated", callback: viewModel.broadcastUpdated);
    on(event: "group_message_updated", callback: viewModel.groupMessageUpdated);

    globalAmplitudeService?.sendAmplitudeData('initListeners', "", null);
    _initBroadcastChannels();
    _initGroupChannels();
  }

  bindListChannel(String listUuid) async {
    ChatViewModel viewModel = serviceLocator<ChatViewModel>();

    setBroadcastChannel(listUuid);
    on(
        event: "broadcast_say",
        id: listUuid,
        type: "broadcast",
        callback: viewModel.incomingListSay);
    on(
        event: "broadcast_deleted",
        id: listUuid,
        type: "broadcast",
        callback: viewModel.deletedBroadcastListMessage);
    on(
        event: "list_deleted",
        id: listUuid,
        type: "broadcast",
        callback: viewModel.deletedBroadcastList);
    on(
        event: "incoming_broadcasts",
        id: listUuid,
        type: "broadcast",
        callback: viewModel.incomingListMessages);
  }

  bindGroupChannel(String groupUuid) async {
    ChatViewModel viewModel = serviceLocator<ChatViewModel>();

    setGroupChannel(groupUuid);
    on(
        event: "group_message_say",
        id: groupUuid,
        type: "group",
        callback: viewModel.incomingGroupSay);
    on(
        event: "group_message_deleted",
        id: groupUuid,
        type: "group",
        callback: viewModel.groupMessageDeleted);
    on(
        event: "incoming_group_messages",
        id: groupUuid,
        type: "group",
        callback: viewModel.incomingGroupMessages);
    on(
        event: "group_deleted",
        id: groupUuid,
        type: "group",
        callback: viewModel.deletedGroup);
    on(
        event: "group_message_status_update",
        id: groupUuid,
        type: "group",
        callback: viewModel.updateGroupMessageStatus);
  }

  Future<PhoenixSocket> _initSocket() async {
    if (socketPhoenix == null || !socketPhoenix.isConnected) {
      globalAmplitudeService?.sendAmplitudeData(
          '_initSocket connected', "", null);
      phoenixSocketReBirth();
      _listenForDisconnect();
      await socketPhoenix.connect();
      channelGeneralUser = socketPhoenix.channel("user:" + userIdPhoenix);
      if (!channelGeneralUser.isJoined) {
        await channelGeneralUser.join();
      }
      initListeners();
    } else {
      globalAmplitudeService?.sendAmplitudeData(
          '_initSocket not connected', "", null);
      _listenForDisconnect();
      await socketPhoenix.reconnect();
      phoenixSocketReBirth();
      await socketPhoenix.connect();
      channelGeneralUser = socketPhoenix.channel("user:" + userIdPhoenix);
      if (!channelGeneralUser.isJoined) {
        await channelGeneralUser.join();
      }
      initListeners();
    }

    return socketPhoenix;
  }

  Future<bool> _initBroadcastChannels() async {
    if (await checkInternet()) {
      List<BroadcastList> response = await _api.getBroadcastLists();
      listGlobalData = response;
      globalAmplitudeService?.sendAmplitudeData(
          'initBroadcastChannels', 'channels updated', true);
      if (listGlobalData.length > 0) {
        for (int i = 0; i < listGlobalData.length; i++) {
          if (listGlobalData[i] != null) {
            serviceLocator<ChatViewModel>()
                    .listMessages[listGlobalData[i].uuid] =
                serviceLocator<ChatViewModel>()
                        .listMessages[listGlobalData[i].uuid] ??
                    [];
            bindListChannel(listGlobalData[i].uuid);
          }
        }
        return true;
      }
    }
    return false;
  }

  Future<bool> _initGroupChannels() async {
    if (await checkInternet()) {
      List<GroupChatData> response = await _api.getGroups();
      groupGlobalData = response;
      if (groupGlobalData.length > 0) {
        for (int i = 0; i < groupGlobalData.length; i++) {
          if (groupGlobalData[i] != null) {
            serviceLocator<ChatViewModel>()
                    .groupMessages[groupGlobalData[i].uuid] =
                serviceLocator<ChatViewModel>()
                        .groupMessages[groupGlobalData[i].uuid] ??
                    [];
            bindGroupChannel(groupGlobalData[i].uuid);
          }
        }
        return true;
      }
    }
    return false;
  }
}
