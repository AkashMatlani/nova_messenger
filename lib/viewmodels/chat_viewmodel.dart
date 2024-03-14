import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nova/models/direct_message.dart';
import 'package:nova/models/broadcast_list.dart';
import 'package:nova/models/broadcast_message.dart';
import 'package:nova/models/contact_data.dart';
import 'package:nova/models/chats.dart';
import 'package:nova/models/group_chat_data.dart';
import 'package:nova/models/broadcasts.dart';
import 'package:nova/models/group_message.dart';
import 'package:nova/models/group_messages.dart';
import 'package:nova/models/message.dart';
import 'package:nova/models/messages.dart';
import 'package:nova/models/messagestatus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/models/trengo_data.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/utils/encryptdata.dart';
import 'package:nova/utils/hive_preferences.dart';
import 'package:nova/utils/rsa_encrypt_data.dart';
import 'package:nova/viewmodels/chat_list_viewmodel.dart';

class ChatViewModel extends ChangeNotifier {
  String receiverPhoenix = "";
  String senderPhoenix = "";

  String currentDirectChatId = "";
  String currentGroupChatId = "";
  String currentListChatId = "";

  String receiverGroupPhoenix = "";
  String senderGroupPhoenix = "";
  String receiverListPhoenix = "";
  String senderListPhoenix = "";

  List<String> statuses = ["sent", "received", "read"];

  var messages = Map<String, List<MessagePhoenix>>();
  var usersData = Map<String, ContactData>();
  var groupMessages = Map<String, List<MessagePhoenix>>();
  var listMessages = Map<String, List<Broadcast>>();
  var usersDirect = Map<String, String>();
  var messagesLastTyped = Map<String, String>();
  var lastPageData = Map<String, Chats>();
  HttpService _api = serviceLocator<HttpService>();

  updateLastTyped() async {
    String encodedLastMessages = json.encode(messagesLastTyped);
    final preferences = await HivePreferences.getInstance();
    preferences.setCurrentLastMessages(encodedLastMessages);
  }

  updateLastSavedPage() async {
    String encodedLastPageData = json.encode(lastPageData);
    final preferences = await HivePreferences.getInstance();
    preferences.setLastPageData(encodedLastPageData);
  }

  contactUpdated(payload, _ref, _joinRef) async {
    if (userUuid != payload["uuid"]) {
      bool flag = false;
      contactsGlobalData.forEach((element) {
        if (element.uuid == payload["uuid"]) {
          element.status = payload["status"];
          element.lastSeen = payload["last_seen"];
          element.typing = payload["typing"];
          element.publicKey = payload["public_key"];
          flag = true;
        }
      });

      ContactData contact = ContactData.fromJson(payload);
      if (!flag) {
        contactsGlobalData.add(contact);
      }
      usersData[payload["uuid"]] = contact;

      storeContacts();
    }
  }

  storeContacts() async {
    contactUpdateTimer?.cancel();
    contactUpdateTimer =
        Timer.periodic(const Duration(seconds: 1), (_timer) async {
      final preferences = await HivePreferences.getInstance();
      String contacts = jsonEncode(contactsGlobalData
          .map<Map<String, dynamic>>((chats) => ContactData.toMap(chats))
          .toList());
      preferences.setCurrentContacts(contacts);
      notifyListeners();
      contactUpdateTimer?.cancel();
    });
  }

  newListAdded(payload, _ref, _joinRef) async {
    if (listMessages[payload["list"]["uuid"]] == null) {
      globalSocketService.bindListChannel(payload["list"]["uuid"]);
      serviceLocator<ChatViewModel>().listMessages[payload["list"]["uuid"]] =
          [];
      BroadcastList newList = BroadcastList.fromJson(payload["list"]);
      listGlobalData.add(newList);
      globalAmplitudeService?.sendAmplitudeData(
          'NewListAdded', 'list added', true);
    }
  }

  newGroupAdded(payload, _ref, _joinRef) async {
    if (groupMessages[payload["group"]["uuid"]] == null) {
      globalSocketService.bindGroupChannel(payload["group"]["uuid"]);
      serviceLocator<ChatViewModel>().groupMessages[payload["group"]["uuid"]] =
          [];
      GroupChatData groupResponse = GroupChatData.fromJson(payload["group"]);
      groupGlobalData.add(groupResponse);
    }
  }

  listChatArchived(payload, _ref, _joinRef) async {
    Timer(Duration(milliseconds: 1), () {
      updateChats();
    });
  }

  reloadAllChats(payload, _ref, _joinRef) async {
    Timer(Duration(milliseconds: 1), () {
      updateChats();
    });
  }

  groupChatArchived(payload, _ref, _joinRef) async {
    Timer(Duration(milliseconds: 1), () {
      updateChats();
    });
  }

  messageUpdated(payload, _ref, _joinRef) async {}

  broadcastUpdated(payload, _ref, _joinRef) async {}

  groupMessageUpdated(payload, _ref, _joinRef) async {}

  void updateChats() async {
    await globalSocketService.push(event: "load_archived_chats");
    await globalSocketService.push(event: "load_chats");
  }

  // DELETE //

  removeDirectMessages(payload, _ref, _joinRef) async {
    // peer deletes //
    if (messages[payload['from_uuid']] != null) {
      messages[payload['from_uuid']] = messages[payload['from_uuid']]
          .where((message) => message.uuid != payload['uuid'])
          .toList();
      String encodedDirectMessages = json.encode(messages);
      final preferences = await HivePreferences.getInstance();
      preferences.setDirectChats(encodedDirectMessages);
      notifyListeners();
      ContactData user = ContactData();
      user = contactsGlobalData
          .firstWhere((contact) => contact.uuid == payload['from_uuid']);
      GroupChatData group = GroupChatData();
      BroadcastList listData = BroadcastList();
      MessagePhoenix lastMessage = messages[payload['from_uuid']].first;
      lastMessage.user = user;
      lastMessage.group = group;
      lastMessage.listData = listData;
      // TODO remove chat if last message //
      serviceLocator<ChatListViewModel>()
          .updateChat("DirectMessage", lastMessage);
    }
  }

  void deleteFromLocal(String uuid) async {
    // user deletes //
    if (messages[receiverPhoenix] != null) {
      messages[receiverPhoenix] = messages[receiverPhoenix]
          .where((message) => message.uuid != uuid)
          .toList();
      String encodedDirectMessages = json.encode(messages);
      final preferences = await HivePreferences.getInstance();
      preferences.setDirectChats(encodedDirectMessages);
      notifyListeners();
      ContactData user = ContactData();
      user = contactsGlobalData
          .firstWhere((contact) => contact.uuid == receiverPhoenix);
      GroupChatData group = GroupChatData();
      BroadcastList listData = BroadcastList();
      MessagePhoenix lastMessage = messages[receiverPhoenix].first;
      lastMessage.user = user;
      lastMessage.group = group;
      lastMessage.listData = listData;
      // TODO remove chat if last message //
      serviceLocator<ChatListViewModel>()
          .updateChat("DirectMessage", lastMessage);
    }
  }

  groupMessageDeleted(payload, _ref, _joinRef) async {
    if (groupMessages[payload['from_uuid']] != null) {
      groupMessages[payload['from_uuid']]
          .removeWhere((element) => element.uuid == payload['uuid']);
      groupMessages[payload['from_uuid']].toSet().toList();
      String encodedGroupMessages = json.encode(groupMessages);
      final preferences = await HivePreferences.getInstance();
      preferences.setGroupChats(encodedGroupMessages);
      notifyListeners();
      GroupChatData group = GroupChatData();
      group = groupGlobalData.firstWhere(
          (groupMessageData) => groupMessageData.uuid == payload['from_uuid']);
      BroadcastList listData = BroadcastList();
      MessagePhoenix lastMessage = groupMessages[payload['from_uuid']].first;
      lastMessage.group = group;
      lastMessage.listData = listData;
      // TODO remove chat if last message //
      serviceLocator<ChatListViewModel>()
          .updateChat("GroupMessage", lastMessage);
    }
  }

  void deleteLocalGroupMessage() async {
    if (groupMessages[receiverGroupPhoenix] != null) {
      groupMessages[receiverGroupPhoenix]
          .removeWhere((element) => element.uuid == userUuid);
      groupMessages[receiverGroupPhoenix].toSet().toList();
      String encodedGroupMessages = json.encode(groupMessages);
      final preferences = await HivePreferences.getInstance();
      preferences.setGroupChats(encodedGroupMessages);
      notifyListeners();
      GroupChatData group = GroupChatData();
      group = groupGlobalData.firstWhere(
          (groupMessageData) => groupMessageData.uuid == receiverGroupPhoenix);
      BroadcastList listData = BroadcastList();
      MessagePhoenix lastMessage = groupMessages[receiverGroupPhoenix].first;
      lastMessage.group = group;
      lastMessage.listData = listData;
      // TODO remove chat if last message //
      serviceLocator<ChatListViewModel>()
          .updateChat("GroupMessage", lastMessage);
    }
  }

  deletedBroadcastListMessage(payload, _ref, _joinRef) async {
    if (listMessages[payload['from_uuid']] != null) {
      listMessages[payload['from_uuid']]
          .removeWhere((element) => element.uuid == payload['uuid']);
      listMessages[payload['from_uuid']].toSet().toList();
      String encodedListMessages = json.encode(listMessages);
      final preferences = await HivePreferences.getInstance();
      preferences.setListChats(encodedListMessages);
      notifyListeners();
      Broadcast lastMessage = listMessages[payload['from_uuid']].first;
      BroadcastList listData = BroadcastList();
      listData = listGlobalData.firstWhere(
          (listMessageData) => listMessageData.uuid == payload['from_uuid']);
      BroadCastMessage messageBroadcast =
          BroadCastMessage(message: lastMessage, listData: listData);
      // TODO remove chat if last message //
      serviceLocator<ChatListViewModel>().updateBroadCastChat(messageBroadcast);
    }
  }

  deleteBroadcastList(String uuid) async {
    listMessages[uuid].removeWhere((element) => element.uuid == uuid);
    listMessages[uuid].toSet().toList();
    String encodedListMessages = json.encode(listMessages);
    final preferences = await HivePreferences.getInstance();
    preferences.setListChats(encodedListMessages);
    notifyListeners();
  }

  deleteGroup(String uuid) async {
    groupMessages[uuid].removeWhere((element) => element.uuid == uuid);
    groupMessages[uuid].toSet().toList();
    String encodedListMessages = json.encode(groupMessages);
    final preferences = await HivePreferences.getInstance();
    preferences.setGroupChats(encodedListMessages);
    notifyListeners();
  }

  void deleteLocalListMessage() async {
    listMessages[receiverListPhoenix]
        .removeWhere((element) => element.uuid == receiverListPhoenix);
    listMessages[receiverListPhoenix].toSet().toList();
    String encodedListMessages = json.encode(listMessages);
    final preferences = await HivePreferences.getInstance();
    preferences.setListChats(encodedListMessages);
    notifyListeners();
    Broadcast lastMessage = listMessages[receiverListPhoenix].first;
    BroadcastList listData = BroadcastList();
    listData = listGlobalData.firstWhere(
        (listMessageData) => listMessageData.uuid == receiverListPhoenix);
    BroadCastMessage messageBroadcast =
        BroadCastMessage(message: lastMessage, listData: listData);
    // TODO remove chat if last message //
    serviceLocator<ChatListViewModel>().updateBroadCastChat(messageBroadcast);
  }

  deletedBroadcastList(payload, _ref, _joinRef) async {
    listMessages[payload['uuid']] = [];
    serviceLocator<ChatListViewModel>().mainChatList =
        serviceLocator<ChatListViewModel>()
            .mainChatList
            .where((element) => (element.list.uuid != payload['uuid']))
            .toList();
    String chats = jsonEncode(serviceLocator<ChatListViewModel>()
        .mainChatList
        .map<Map<String, dynamic>>((chats) => Chats.toMap(chats))
        .toList());
    final preferences = await HivePreferences.getInstance();
    preferences.setCurrentChats(chats);
    serviceLocator<ChatListViewModel>().notifyListeners();
  }

  deletedGroup(payload, _ref, _joinRef) async {
    groupMessages[payload['uuid']] = [];
    serviceLocator<ChatListViewModel>().mainChatList =
        serviceLocator<ChatListViewModel>()
            .mainChatList
            .where((element) => (element.group.uuid != payload['uuid']))
            .toList();
    String chats = jsonEncode(serviceLocator<ChatListViewModel>()
        .mainChatList
        .map<Map<String, dynamic>>((chats) => Chats.toMap(chats))
        .toList());
    final preferences = await HivePreferences.getInstance();
    preferences.setCurrentChats(chats);
    serviceLocator<ChatListViewModel>().notifyListeners();
  }

  updateGroupMessageStatus(payload, _ref, _joinRef) async {
    GroupMessage groupMessage = GroupMessage.fromJson(payload);
    groupMessages[groupMessage.group.uuid].forEach((message) {
      if (groupMessage.message.clientUuid == message.clientUuid) {
        message.status = groupMessage.message.status;
      }
    });
    String encodedGroupMessages = json.encode(groupMessages);
    final preferences = await HivePreferences.getInstance();
    preferences.setGroupChats(encodedGroupMessages);
    notifyListeners();
  }

  updateSentGroupMessagesStatuses(String uuid) async {
    groupMessages[uuid].forEach((message) {
      if (message.user.uuid == userUuid && message.status != "read") {
        globalSocketService.push(
            id: uuid,
            type: "group",
            event: "group_message_status_update",
            payload: {"uuid": message.uuid});
      }
    });
  }

  setPeer(String peerDataId) async {
    receiverPhoenix = peerDataId;
    final preferences = await HivePreferences.getInstance();
    var id = await preferences.getUserId();
    senderPhoenix = id;
  }

  setGroupPeer(String groupDataId) async {
    receiverGroupPhoenix = groupDataId;
    final preferences = await HivePreferences.getInstance();
    var id = await preferences.getUserId();
    senderGroupPhoenix = id;
  }

  setListPeer(String listDataId) async {
    receiverListPhoenix = listDataId;
    final preferences = await HivePreferences.getInstance();
    var id = await preferences.getUserId();
    senderListPhoenix = id;
  }

  void checkBroadcasts(int count) async {
    Timer.run(() async {
      if (inChatUuid != "" && inChatType == "list") {
        globalSocketService.push(
            id: inChatUuid,
            type: "broadcast",
            event: "load_broadcasts",
            payload: {"uuid": inChatUuid});
      }
    });
  }

  void checkGroups(int count) async {
    Timer.run(() async {
      if (inChatUuid != "" && inChatType == "group") {
        await globalSocketService.push(
            id: inChatUuid,
            type: "group",
            event: "load_group_messages",
            payload: {"uuid": inChatUuid});
      }
    });
  }

  void checkDirectMessages(int count) async {
    Timer.run(() async {
      if (inChatUuid != "" && inChatType == "direct") {
        await globalSocketService
            .push(event: "load_messages", payload: {"to": inChatUuid});
        globalAmplitudeService?.sendAmplitudeData(
            'Load Direct Messages Time Stamp', DateTime.now().toString(), true);
      }
    });
  }

  // Incoming //
  incomingDirectSay(payload, _ref, _joinRef) async {
    DirectMessage directMessage = DirectMessage.fromJson(payload);
    globalAmplitudeService?.logAmplitudeData(
        'DirectMessageSay',
        'incoming direct message say',
        directMessage.user.uuid,
        directMessage.user.name);

    BroadcastList list = BroadcastList();
    GroupChatData group = GroupChatData();

    list.uuid = "";
    group.uuid = "";

    MessagePhoenix message = MessagePhoenix(
        content:
            await RSAEncryptData.decryptText(directMessage.message.content),
        contentType: directMessage.message.contentType,
        file: directMessage.message.file,
        toUuid: directMessage.message.toUuid,
        user: directMessage.user,
        fromUuid: directMessage.message.fromUuid,
        group: group,
        avatar: directMessage.message.avatar,
        listData: list,
        clientUuid: directMessage.message.clientUuid,
        lastSeen: directMessage.message.lastSeen,
        insertedAt: directMessage.message.insertedAt,
        status: directMessage.message.status,
        muted: directMessage.message.muted,
        repliedMessageUuid: directMessage.message.repliedMessageUuid,
        hasReplied: directMessage.message.hasReplied,
        replyIndex: directMessage.message.replyIndex,
        hasForwarded: directMessage.message.hasForwarded,
        uuid: directMessage.message.uuid);
    Timer(Duration(milliseconds: 1), () {
      _pushStatus(payload);
    });
    var uuid = "";
    if (message.fromUuid == userUuid) {
      uuid = directMessage.message.toUuid;
      messages[uuid] = messages[uuid] ?? [];
      if (message.contentType != "text") {
        messages[uuid].insert(0, message);
        notifyListeners();
        await serviceLocator<ChatListViewModel>()
            .updateChat("DirectMessage", message);
        if (isTrengoClient) sendOutgoingTrengoAttachment(message.file);
      } else {
        if (isTrengoClient) sendOutgoingTrengoMessage(message.content);
      }
    } else {
      message.content = await RSAEncryptData.decryptText(message.content);
      uuid = directMessage.message.fromUuid;
      messages[uuid] = messages[uuid] ?? [];
      messages[uuid].insert(0, message);
      if (messages[uuid].length > 300) {
        messages[uuid].length = 300;
      }
      notifyListeners();
      await serviceLocator<ChatListViewModel>()
          .updateChat("DirectMessage", message);
    }
    // Log time incoming direct message
    globalAmplitudeService?.sendAmplitudeData(
        'Incoming Direct Message Time Stamp', DateTime.now().toString(), true);
    String encodedDirectMessages = json.encode(messages);
    final preferences = await HivePreferences.getInstance();
    preferences.setDirectChats(encodedDirectMessages);
  }

  incomingGroupSay(payload, _ref, _joinRef) async {
    GroupMessage groupMessage = GroupMessage.fromJson(payload);
    groupMessages[groupMessage.message.uuid] =
        groupMessages[groupMessage.message.uuid] ?? [];
    globalAmplitudeService?.logAmplitudeData(
        'GroupSay',
        'incoming group message say',
        groupMessage.group.uuid,
        groupMessage.group.name);
    BroadcastList list = BroadcastList();
    list.uuid = "";
    MessagePhoenix message = MessagePhoenix(
        content: EncryptAESData.decryptAES(groupMessage.message.content),
        contentType: groupMessage.message.contentType,
        file: groupMessage.message.file,
        fromUuid: groupMessage.message.fromUuid,
        insertedAt: groupMessage.message.insertedAt,
        clientUuid: groupMessage.message.clientUuid,
        user: groupMessage.message.user,
        status: groupMessage.message.status,
        uuid: groupMessage.message.uuid,
        group: groupMessage.group,
        muted: groupMessage.group.muted,
        repliedMessageUuid: groupMessage.message.repliedMessageUuid,
        hasReplied: groupMessage.message.hasReplied,
        replyIndex: groupMessage.message.replyIndex,
        hasForwarded: groupMessage.message.hasForwarded,
        listData: list);
    Timer(Duration(milliseconds: 1), () {
      _pushGroupStatus(groupMessage);
    });
    groupMessages[groupMessage.group.uuid].insert(0, message);
    if (groupMessages[groupMessage.group.uuid].length > 300) {
      groupMessages[groupMessage.group.uuid].length = 300;
    }
    String encodedGroupMessages = json.encode(groupMessages);
    final preferences = await HivePreferences.getInstance();
    preferences.setGroupChats(encodedGroupMessages);
    notifyListeners();
    await serviceLocator<ChatListViewModel>()
        .updateChat("GroupMessage", message);
    // Log time incoming group message //
    globalAmplitudeService?.sendAmplitudeData(
        'Incoming Group Message Time Stamp', DateTime.now().toString(), true);
  }

  incomingListSay(payload, _ref, _joinRef) async {
    BroadCastMessage listMessage = BroadCastMessage.fromJson(payload);
    listMessages[listMessage.listData.uuid] =
        listMessages[listMessage.listData.uuid] ?? [];
    globalAmplitudeService?.logAmplitudeData(
        'ListSay',
        'incoming broadcast message say',
        listMessage.listData.uuid,
        listMessage.listData.name);
    String listUser = "";
    listUser = getUserName(listMessage.message.listUserName);
    String avatar = "";
    avatar = getAvatar(listMessage.message.listUserName);
    Broadcast message = Broadcast(
        avatar:avatar,
        content: listMessage.message.content,
        contentType: listMessage.message.contentType,
        file: listMessage.message.file,
        clientUuid: listMessage.message.clientUuid,
        status: listMessage.message.status,
        uuid: listMessage.message.uuid,
        senderUuid: listMessage.message.listUserName,
        repliedMessageUuid: listMessage.message.repliedMessageUuid,
        replyIndex: listMessage.message.replyIndex,
        hasReplied: listMessage.message.hasReplied,
        insertedAt: listMessage.message.insertedAt,
        hasForwarded: listMessage.message.hasForwarded,
        listUserName: listUser);
    Timer(Duration(milliseconds: 1), () {
      _pushListStatus(listMessage);
    });

    var existingMessage = listMessages[listMessage.listData.uuid].firstWhere(
        (element) => element.clientUuid == listMessage.message.clientUuid,
        orElse: () => null);

    if (existingMessage == null) {
      listMessages[listMessage.listData.uuid].forEach((chats) {
        chats.content = chats.content;
      });
      listMessages[listMessage.listData.uuid].insert(0, message);
      if (listMessages[listMessage.listData.uuid].length > 300) {
        listMessages[listMessage.listData.uuid].length = 300;
      }
      listMessages[listMessage.listData.uuid].toSet().toList();
      String encodedListMessages = json.encode(listMessages);
      final preferences = await HivePreferences.getInstance();
      preferences.setListChats(encodedListMessages);
      notifyListeners();
      await serviceLocator<ChatListViewModel>()
          .updateBroadCastChat(listMessage);
      // Log time incoming list message //
      globalAmplitudeService?.sendAmplitudeData(
          'Incoming List Message Time Stamp', DateTime.now().toString(), true);
    }
  }

  _pushGroupStatus(GroupMessage groupMessage) async {
    await globalSocketService.push(
        id: groupMessage.group.uuid,
        type: "group",
        event: "mark_group_message_as_received",
        payload: {"uuid": groupMessage.message.uuid});
    if (senderGroupPhoenix == groupMessage.group.uuid) {
      await globalSocketService.push(
          id: groupMessage.group.uuid,
          type: "group",
          event: "mark_group_message_as_read",
          payload: {"uuid": groupMessage.message.uuid});
    }
  }

  _pushListStatus(BroadCastMessage listMessage) async {
    await globalSocketService.push(
        id: listMessage.listData.uuid,
        type: "broadcast",
        event: "mark_broadcast_as_received",
        payload: {"uuid": listMessage.message.uuid});
    if (senderListPhoenix == listMessage.message.fromUuid) {
      await globalSocketService.push(
          id: listMessage.listData.uuid,
          type: "broadcast",
          event: "mark_broadcast_as_read",
          payload: {"uuid": listMessage.message.uuid});
    }
  }

  _pushStatus(payload) {
    globalSocketService.push(event: "mark_as_received", payload: {
      "from_uuid": payload["message"]['from_uuid'],
      "uuid": payload["message"]['uuid']
    });
    if (senderPhoenix == payload["message"]['to_uuid']) {
      globalSocketService.push(event: "mark_as_read", payload: {
        "from_uuid": payload["message"]['from_uuid'],
        "uuid": payload["message"]['uuid']
      });
    }
  }

  incomingDirectMessages(payload, _ref, _joinRef) async {
    Messages messagesIncomingChats = Messages.fromJson(payload);
    messages[messagesIncomingChats.users.last.uuid] =
        messages[messagesIncomingChats.users.last.uuid] ?? [];
    globalAmplitudeService?.logAmplitudeData(
        'IncomingDirectMessages',
        'incoming direct messages',
        messagesIncomingChats.users.last.uuid,
        messagesIncomingChats.users.last.name);
    messagesIncomingChats.messages.forEach((message) async {
      var existingMessage = messages[messagesIncomingChats.users.last.uuid]
          .firstWhere((element) => element.clientUuid == message.clientUuid,
              orElse: () => null);
      if (message.contentType == "text" &&
          existingMessage == null &&
          message.fromUuid != userUuid) {
        message.repliedMessageUuid = message.repliedMessageUuid;
        message.hasReplied = message.hasReplied;
        message.replyIndex = message.replyIndex;
        message.content = await RSAEncryptData.decryptText(message.content);
        messages[messagesIncomingChats.users.last.uuid].insert(0, message);
      } else {
        if (existingMessage != null) {
          existingMessage.file = message.file;
          message.savedImage = existingMessage.savedImage;
          existingMessage.repliedMessageUuid = message.repliedMessageUuid;
          existingMessage.hasReplied = message.hasReplied;
          existingMessage.replyIndex = message.replyIndex;
          existingMessage.hasForwarded = message.hasForwarded;
          int currentIndex = statuses.indexOf(existingMessage.status);
          int incomingIndex = statuses.indexOf(message.status);
          if (incomingIndex > currentIndex) {
            existingMessage.status = message.status;
          }
          messagesIncomingChats.users.forEach((user) {
            if (existingMessage.fromUuid == user.uuid) {
              existingMessage.user = user;
            }
          });
        } else {
          message.repliedMessageUuid = message.repliedMessageUuid;
          message.hasReplied = message.hasReplied;
          message.replyIndex = message.replyIndex;
          message.hasForwarded = message.hasForwarded;
          messages[messagesIncomingChats.users.last.uuid].insert(0, message);
        }
      }
      messages[messagesIncomingChats.users.last.uuid].sort((b, a) =>
          convertedTime(a.insertedAt).compareTo(convertedTime(b.insertedAt)));
    });
    for (int i = 0; i < messagesIncomingChats.users.length; i++) {
      usersDirect[senderPhoenix] = messagesIncomingChats.users[i].uuid;
    }
    String encodedDirectMessages = json.encode(messages);
    final preferences = await HivePreferences.getInstance();
    preferences.setDirectChats(encodedDirectMessages);
    notifyListeners();
    // Log time incoming direct message
    globalAmplitudeService?.sendAmplitudeData(
        'Incoming Direct Message Time Stamp', DateTime.now().toString(), true);
    //
  }

  incomingGroupMessages(payload, _ref, _joinRef) async {
    GroupMessages messagesGroupChat = GroupMessages.fromJson(payload);
    groupMessages[messagesGroupChat.group.uuid] =
        groupMessages[messagesGroupChat.group.uuid] ?? [];
    globalAmplitudeService?.logAmplitudeData(
        'IncomingGroupMessages',
        'incoming group messages',
        messagesGroupChat.group.uuid,
        messagesGroupChat.group.name);
    messagesGroupChat.messages.forEach((message) async {
      var existingMessage = groupMessages[messagesGroupChat.group.uuid]
          .firstWhere((element) => element.clientUuid == message.clientUuid,
              orElse: () => null);
      if (existingMessage != null) {
        existingMessage.file = message.file;
        message.savedImage = existingMessage.savedImage;
        existingMessage.repliedMessageUuid = message.repliedMessageUuid;
        existingMessage.hasReplied = message.hasReplied;
        existingMessage.replyIndex = message.replyIndex;
        existingMessage.hasForwarded = message.hasForwarded;
      } else {
        if (message.contentType == "text") {
          message.content = EncryptAESData.decryptAES(message.content);
        }
        message.repliedMessageUuid = message.repliedMessageUuid;
        message.hasReplied = message.hasReplied;
        message.replyIndex = message.replyIndex;
        message.hasForwarded = message.hasForwarded;
        groupMessages[messagesGroupChat.group.uuid].insert(0, message);
      }
    });

    groupMessages[messagesGroupChat.group.uuid]
        .sort((b, a) => a.insertedAt.compareTo(b.insertedAt));
    String encodedGroupMessages = json.encode(groupMessages);
    final preferences = await HivePreferences.getInstance();
    preferences.setGroupChats(encodedGroupMessages);
    notifyListeners();
    Timer.run(
        () => {updateSentGroupMessagesStatuses(messagesGroupChat.group.uuid)});
    // Log time incoming Group message
    globalAmplitudeService?.sendAmplitudeData(
        'Incoming Group Message Time Stamp', DateTime.now().toString(), true);
    //
  }

  incomingListMessages(payload, _ref, _joinRef) async {
    BroadCastMessages messagesListChat = BroadCastMessages.fromJson(payload);
    listMessages[messagesListChat.broadcastList.uuid] = messagesListChat.broadcasts;
    listMessages[messagesListChat.broadcastList.uuid].forEach((message) async {
      var existingMessage = listMessages[messagesListChat.broadcastList.uuid]
          .firstWhere((element) => element.clientUuid == message.clientUuid,
              orElse: () => null);

      if (existingMessage != null) {
        message.avatar = getAvatar(existingMessage.listUserName);
        message.savedImage = existingMessage.savedImage;
        message.senderUuid = existingMessage.listUserName;
        existingMessage.repliedMessageUuid = message.repliedMessageUuid;
        existingMessage.hasReplied = message.hasReplied;
        existingMessage.replyIndex = message.replyIndex;
        existingMessage.hasForwarded = message.hasForwarded;
        message.listUserName = getUserName(existingMessage.listUserName);
      } else {
        message.avatar = getAvatar(message.listUserName);
        message.repliedMessageUuid = message.repliedMessageUuid;
        message.hasReplied = message.hasReplied;
        message.senderUuid = message.listUserName;
        message.replyIndex = message.replyIndex;
        message.hasForwarded = message.hasForwarded;
        message.listUserName = getUserName(message.listUserName);
      }
    });
    listMessages[messagesListChat.broadcastList.uuid]
        .sort((b, a) => a.insertedAt.compareTo(b.insertedAt));
    String encodedListMessages = json.encode(listMessages);
    final preferences = await HivePreferences.getInstance();
    preferences.setListChats(encodedListMessages);
    notifyListeners();
    // Log time incoming Broadcast message //
    globalAmplitudeService?.sendAmplitudeData(
        'Incoming Broadcast Message Time Stamp',
        DateTime.now().toString(),
        true);
  }

  updatedBroadCastMessages(payload, _ref, _joinRef) async {
    if (inChatUuid == payload['uuid']) {
      await globalSocketService.push(
          id: payload['uuid'],
          type: "broadcast",
          event: "load_broadcasts",
          payload: {"uuid": payload['uuid']});
    }
  }

  updateStatusMessages(payload, _ref, _joinRef) async {
    messages[payload['uuid']].forEach((chats) {
      chats.status = "read";
    });
    messages[payload['uuid']].toSet().toList();
    String encodedDirectMessages = json.encode(messages);
    final preferences = await HivePreferences.getInstance();
    preferences.setDirectChats(encodedDirectMessages);
    notifyListeners();
  }

  updateArchivedChat(payload, _ref, _joinRef) async {
    print("Payload archived = " + payload);
  }

  updateDirectStatusMessage(payload, _ref, _joinRef) async {
    MessagesStatusResponse messagesChat =
        MessagesStatusResponse.fromJson(payload);
    messages[messagesChat.message.toUuid].forEach((MessagePhoenix message) {
      if (message.clientUuid == messagesChat.message.clientUuid) {
        int currentIndex = statuses.indexOf(message.status);
        int incomingIndex = statuses.indexOf(messagesChat.message.status);
        if (incomingIndex > currentIndex) {
          message.status = messagesChat.message.status;
        }
      }
    });
    messages[messagesChat.message.toUuid].toSet().toList();
    String encodedDirectMessages = json.encode(messages);
    final preferences = await HivePreferences.getInstance();
    preferences.setDirectChats(encodedDirectMessages);
    notifyListeners();
  }

  Future<bool> getLocalDirectChats() async {
    final preferences = await HivePreferences.getInstance();
    String currentDirectChats = preferences.getDirectChats();
    if (currentDirectChats != null) {
      Map<String, dynamic> decodedMap = jsonDecode(currentDirectChats);
      Map<String, List<MessagePhoenix>> convertedMap = {};
      for (var item in decodedMap.keys) {
        List<MessagePhoenix> _newList = [];
        for (var newListItem in List.from(decodedMap[item])) {
          MessagePhoenix _convertedDirectMessage =
              MessagePhoenix.fromJson(newListItem);
          _convertedDirectMessage.content =
              await RSAEncryptData.decryptText(_convertedDirectMessage.content);
          _newList.add(_convertedDirectMessage);
        }
        convertedMap[item] = _newList;
      }
      messages = convertedMap;
      return true;
    } else {
      return false;
    }
  }

  Future<bool> getLocalGroupChats() async {
    final preferences = await HivePreferences.getInstance();
    String currentGroupChats = preferences.getGroupChats();
    if (currentGroupChats != null) {
      Map<String, dynamic> decodedMap = jsonDecode(currentGroupChats);
      Map<String, List<MessagePhoenix>> convertedMap = {};
      for (var item in decodedMap.keys) {
        List<MessagePhoenix> _newList = [];
        for (var newListItem in List.from(decodedMap[item])) {
          MessagePhoenix _convertedGroupMessage =
              MessagePhoenix.fromJson(newListItem);
          _newList.add(_convertedGroupMessage);
        }
        convertedMap[item] = _newList;
      }

      groupMessages = convertedMap;
      return true;
    } else {
      return false;
    }
  }

  Future<bool> getLocalListChats() async {
    final preferences = await HivePreferences.getInstance();
    String currentListChats = preferences.getListChats();
    if (currentListChats != null) {
      Map<String, dynamic> decodedMap = jsonDecode(currentListChats);
      Map<String, List<Broadcast>> convertedMap = {};
      for (var item in decodedMap.keys) {
        List<Broadcast> _newList = [];
        for (var newListItem in List.from(decodedMap[item])) {
          Broadcast _convertedBroadcast = Broadcast.fromJson(newListItem);
          _newList.add(_convertedBroadcast);
        }
        convertedMap[item] = _newList;
      }
      listMessages = convertedMap;
      return true;
    } else {
      return false;
    }
  }

  Future<bool> getLocalLastMessages() async {
    final preferences = await HivePreferences.getInstance();
    String currentLastMessages = preferences.getCurrentLastMessages();
    if (currentLastMessages != null) {
      Map<String, dynamic> decodedMap = jsonDecode(currentLastMessages);
      Map<String, String> converted =
          decodedMap.map((key, value) => MapEntry(key, value?.toString()));
      messagesLastTyped = converted;
      return true;
    } else {
      return false;
    }
  }

  Future<bool> getLocalLastPage() async {
    final preferences = await HivePreferences.getInstance();
    String currentPageData = preferences.getLastPageData();
    if (currentPageData != null) {
      Map<String, dynamic> decodedMap = jsonDecode(currentPageData);
      Map<String, Chats> converted = {};
      converted["savedPage"] = Chats.fromJson(decodedMap["savedPage"]);
      lastPageData = converted;
      return true;
    } else {
      lastPageData = {};
      return false;
    }
  }

  Future<bool> getInChatUuid() async {
    final preferences = await HivePreferences.getInstance();
    if (inChatUuid != null) {
      inChatUuid = preferences.getInChatUuid();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> getInChatType() async {
    final preferences = await HivePreferences.getInstance();
    if (inChatUuid != null) {
      inChatType = preferences.getInChatType();
      return true;
    } else {
      return false;
    }
  }

  updateDirectLocalChat(String receiverUuid, MessagePhoenix message) async {
    messages[receiverUuid] = messages[receiverUuid] ?? [];
    messages[receiverUuid].insert(0, message);
    if (messages[receiverUuid].length > 300) {
      messages[receiverUuid].length = 300;
    }
    messages[receiverUuid].toSet().toList();
    notifyListeners();
    String encodedDirectMessages = json.encode(messages);
    final preferences = await HivePreferences.getInstance();
    preferences.setDirectChats(encodedDirectMessages);
    await serviceLocator<ChatListViewModel>()
        .updateChat("DirectMessage", message);
  }

  updateGroupLocalChat(String receiverUuid, MessagePhoenix message) async {
    groupMessages[receiverUuid] = groupMessages[receiverUuid] ?? [];
    groupMessages[receiverUuid].insert(0, message);
    if (groupMessages[receiverUuid].length > 300) {
      groupMessages[receiverUuid].length = 300;
    }
    notifyListeners();
    String encodedGroupMessages = json.encode(groupMessages);
    final preferences = await HivePreferences.getInstance();
    preferences.setGroupChats(encodedGroupMessages);
    await serviceLocator<ChatListViewModel>()
        .updateChat("GroupMessage", message);
  }

  updateListLocalChat(
      BroadcastList listData, String receiverUuid, Broadcast broadcast) async {
    BroadCastMessage listMessage = BroadCastMessage();
    listMessage.message = broadcast;
    listMessage.listData = listData;
    listMessages[receiverUuid] = listMessages[receiverUuid] ?? [];
    listMessages[receiverUuid].insert(0, broadcast);
    if (listMessages[receiverUuid].length > 300) {
      listMessages[receiverUuid].length = 300;
    }
    listMessages[receiverUuid].toSet().toList();
    notifyListeners();
    String encodedListMessages = json.encode(listMessages);
    final preferences = await HivePreferences.getInstance();
    preferences.setListChats(encodedListMessages);
    await serviceLocator<ChatListViewModel>().updateBroadCastChat(listMessage);
  }

  void update() {
    notifyListeners();
  }

  void sendOutgoingTrengoMessage(String message) async {
    TrengoData trengoData = TrengoData();
    Contact contactData = Contact();
    contactData.name = globalName;
    contactData.uuid = userUuid;
    contactData.identifier = trengoIdentifier;
    trengoData.channel = dotenv.env["trengoChannel"];
    Body trengoBody = Body();
    Attachment attachment = Attachment();
    trengoBody.text = message;
    trengoData.contact = contactData;
    trengoData.attachments = attachment;
    trengoData.body = trengoBody;
    _api.outgoingTrengoMessage(trengoData);
  }

  void sendOutgoingTrengoAttachment(String urlAttachment) async {
    TrengoData trengoData = TrengoData();
    Contact contactData = Contact();
    contactData.name = globalName;
    contactData.uuid = userUuid;
    contactData.identifier = trengoIdentifier;
    trengoData.channel = dotenv.env["trengoChannel"];
    Body trengoBody = Body();
    Attachment attachment = Attachment();
    attachment.url = urlAttachment;
    trengoBody.text = "Attachment";
    trengoData.contact = contactData;
    trengoData.attachments = attachment;
    trengoData.body = trengoBody;
    _api.outgoingTrengoMessage(trengoData);
  }

  void handleHighLight(int index, bool isGroup) {
    !isGroup
        ? messages[inChatUuid][index].isHighlighted = true
        : groupMessages[inChatUuid][index].isHighlighted = true;
    notifyListeners();
    Future.delayed(Duration(seconds: 1), () {
      !isGroup
          ? messages[inChatUuid][index].isHighlighted = false
          : groupMessages[inChatUuid][index].isHighlighted = false;
      notifyListeners();
    });
  }

  void handleHighLightLists(int index) {
    listMessages[inChatUuid][index].isHighlighted = true;
    notifyListeners();
    Future.delayed(Duration(seconds: 1), () {
      listMessages[inChatUuid][index].isHighlighted = false;
      notifyListeners();
    });
  }
}
