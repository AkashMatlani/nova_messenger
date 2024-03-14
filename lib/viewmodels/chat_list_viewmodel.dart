import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/models/broadcast_message.dart';
import 'package:nova/models/chats.dart';
import 'package:nova/models/group_chat_data.dart';
import 'package:nova/models/message.dart';
import 'package:nova/utils/encryptdata.dart';
import 'package:nova/utils/hive_preferences.dart';
import 'package:nova/utils/rsa_encrypt_data.dart';

class ChatListViewModel extends ChangeNotifier {
  List<Chats> mainChatList = [];
  List<Chats> mainArchivedChatList = [];

  void initMessagesSocketListener() async {
    globalSocketService.on(event: "incoming_chats", callback: loadChats);
    globalSocketService.on(
        event: "list_deleted", callback: deleteLocalListChat);
  }

  Future getLocalChats() async {
    final preferences = await HivePreferences.getInstance();
    var currentChats = preferences.getCurrentChats();
    if (currentChats != null) {
      final List<Chats> chats = jsonDecode(currentChats)
          .map<Chats>((item) => Chats.fromJson(item))
          .toList();
      mainChatList = chats;
    }
    var currentArchivedChats = preferences.getArchivedChats();
    if (currentArchivedChats != null) {
      final List<Chats> chatsArchived = jsonDecode(currentArchivedChats)
          .map<Chats>((item) => Chats.fromJson(item))
          .toList();
      mainArchivedChatList = chatsArchived;
    }
    notifyListeners();
  }

  loadChats(payload, _ref, _joinRef) async {
    var list = payload['data'] as List;
    if (list != null) {
      List<Chats> messagesChat =
          list.map((i) => Chats.fromJson(i)).toSet().toList();

      messagesChat.sort((a, b) =>
          b.lastMessage.insertedAt.compareTo(a.lastMessage.insertedAt));
      messagesChat.toList().asMap().forEach((index, element) async {
        Chats existingChat = mainChatList.firstWhere(
            (chat) => chat.uuid == element.uuid,
            orElse: () => null);

        Chats existingChatArchived = mainArchivedChatList.firstWhere(
            (chatArchive) => chatArchive.uuid == element.uuid,
            orElse: () => null);

        if (existingChat == null && existingChatArchived == null) {
          switch (element.type) {
            case "DirectMessage":
              if (element.lastMessage.fromUuid != userUuid) {
                element.lastMessage.content = await RSAEncryptData.decryptText(
                    element.lastMessage.content);
              }
              break;
            case "GroupMessage":
              element.lastMessage.content =
                  EncryptAESData.decryptAES(element.lastMessage.content);
              globalSocketService.push(
                  id: element.group.uuid,
                  type: "group",
                  event: "mark_group_message_as_received",
                  payload: {"uuid": element.lastMessage.uuid});
              break;
            case "BroadcastList":
              globalSocketService.push(
                  id: element.uuid,
                  type: "broadcast",
                  event: "mark_broadcast_as_received",
                  payload: {"uuid": element.lastMessage.uuid});
              break;
          }
          mainChatList.insert(0, element);
        } else if (existingChat != null) {
          if (element.lastMessage.fromUuid != userUuid) {
            switch (element.type) {
              case "DirectMessage":
                if (element.lastMessage.fromUuid != userUuid) {
                  element.lastMessage.content =
                      await RSAEncryptData.decryptText(
                          element.lastMessage.content);
                }
                break;
              case "GroupMessage":
                element.lastMessage.content =
                    EncryptAESData.decryptAES(element.lastMessage.content);
                globalSocketService.push(
                    id: element.group.uuid,
                    type: "group",
                    event: "mark_group_message_as_received",
                    payload: {"uuid": element.lastMessage.uuid});
                break;
              case "BroadcastList":
                globalSocketService.push(
                    id: element.list.uuid,
                    type: "broadcast",
                    event: "mark_broadcast_as_received",
                    payload: {"uuid": element.lastMessage.uuid});
                break;
            }
            var existingIndex =
                mainChatList.indexWhere((chat) => chat.uuid == element.uuid);
            mainChatList[existingIndex] = element;
          }
        }
      });
      checkArchivedChats(messagesChat);

      mainChatList.sort((b, a) => convertedTime(a.lastMessage.insertedAt)
          .compareTo(convertedTime(b.lastMessage.insertedAt)));

      notifyListeners();
      //
      globalAmplitudeService?.sendAmplitudeData(
          'IncomingChats', 'loaded incoming chat messages', true);
      String chats = jsonEncode(mainChatList
          .map<Map<String, dynamic>>((chats) => Chats.toMap(chats))
          .toList());
      final preferences = await HivePreferences.getInstance();
      preferences.setCurrentChats(chats);
    }
  }

  checkArchivedChats(List<Chats> incomingChats) async {
    incomingChats.toList().forEach((element) async {
      var archivedChat = mainArchivedChatList.firstWhere(
          (elementArchive) => elementArchive.uuid == element.uuid,
          orElse: () => null);
      if (archivedChat != null) {
        updatedArchivedChats(element);
        globalAmplitudeService?.sendAmplitudeData(
            'found archived chats', 'check archived chats', true);
      }
    });
  }

  deleteLocalDirectChat(String uuid) async {
    mainChatList.removeWhere((element) => element.uuid == uuid);
    String chats = jsonEncode(mainChatList
        .map<Map<String, dynamic>>((chats) => Chats.toMap(chats))
        .toList());
    final preferences = await HivePreferences.getInstance();
    preferences.setCurrentChats(chats);
    notifyListeners();
  }

  deleteLocalArchiveDirectChat(String uuid) async {
    mainArchivedChatList.removeWhere((element) => element.uuid == uuid);
    String chats = jsonEncode(mainArchivedChatList
        .map<Map<String, dynamic>>((chats) => Chats.toMap(chats))
        .toList());
    final preferences = await HivePreferences.getInstance();
    preferences.setArchivedChats(chats);
    notifyListeners();
  }

  deleteLocalListChat(payload, _ref, _joinRef) async {
    String listUuid = payload['uuid'];
    mainChatList.removeWhere((element) => element.uuid == listUuid);
    String chats = jsonEncode(mainChatList
        .map<Map<String, dynamic>>((chats) => Chats.toMap(chats))
        .toList());
    final preferences = await HivePreferences.getInstance();
    preferences.setCurrentChats(chats);
    notifyListeners();
  }

  void deleteListChat(String listUuid) async {
    mainChatList.removeWhere((element) => element.list.uuid == listUuid);
    String chats = jsonEncode(mainChatList
        .map<Map<String, dynamic>>((chats) => Chats.toMap(chats))
        .toList());
    final preferences = await HivePreferences.getInstance();
    preferences.setCurrentChats(chats);
    notifyListeners();
  }

  void deleteListArchivedChat(String listUuid) async {
    mainArchivedChatList
        .removeWhere((element) => element.list.uuid == listUuid);
    String chats = jsonEncode(mainArchivedChatList
        .map<Map<String, dynamic>>((chats) => Chats.toMap(chats))
        .toList());
    final preferences = await HivePreferences.getInstance();
    preferences.setArchivedChats(chats);
    notifyListeners();
  }

  void deleteGroupChat(String groupUuid) async {
    mainChatList.removeWhere((element) => element.group.uuid == groupUuid);
    String chats = jsonEncode(mainChatList
        .map<Map<String, dynamic>>((chats) => Chats.toMap(chats))
        .toList());
    final preferences = await HivePreferences.getInstance();
    preferences.setCurrentChats(chats);
    notifyListeners();
  }

  void deleteArchivedGroupChat(String groupUuid) async {
    mainArchivedChatList
        .removeWhere((element) => element.group.uuid == groupUuid);
    String chats = jsonEncode(mainArchivedChatList
        .map<Map<String, dynamic>>((chats) => Chats.toMap(chats))
        .toList());
    final preferences = await HivePreferences.getInstance();
    preferences.setArchivedChats(chats);
    notifyListeners();
  }

  String directMessageKey(LastMessage message) {
    List<String> keyList = [message.fromUuid, message.toUuid];
    if (keyList[0] != null && keyList[1] != null) {
      keyList.sort((a, b) {
        return a.compareTo(b);
      });
      return keyList.join(',');
    }
    return null;
  }

  void updateIncomingLocalChats(Chats newChat) async {
    var archivedChat = mainArchivedChatList.firstWhere(
        (element) => element.uuid == newChat.uuid,
        orElse: () => null);
    if (archivedChat != null) {
      updatedArchivedChats(newChat);
    } else {
      updatedMainChats(newChat);
    }
  }

  void updatedMainChats(Chats newChat) async {
    List<Chats> messagesList = List.from(mainChatList);
    bool isNewChat = true;
    messagesList.forEach((Chats chat) {
      if (newChat.type == "DirectMessage") {
        if (chat.user != null) {
          if (directMessageKey(chat.lastMessage) ==
              directMessageKey(newChat.lastMessage)) {
            mainChatList.remove(chat);
            if (inChatUuid != chat.user.uuid) {
              if (newChat.lastMessage.fromUuid != userUuid) {
                newChat.unreadCount = chat.unreadCount + 1;
              } else {
                newChat.unreadCount = chat.unreadCount;
              }
            } else {
              newChat.unreadCount = 0;
            }
            mainChatList.insert(0, newChat);
            isNewChat = false;
          }
        }
      } else if (newChat.type == "GroupMessage") {
        if (chat.group != null) {
          if (chat.group.uuid == newChat.group.uuid) {
            mainChatList.remove(chat);
            if (inChatUuid != chat.group.uuid) {
              if (newChat.user.uuid != userUuid) {
                newChat.unreadCount = chat.unreadCount + 1;
              } else {
                newChat.unreadCount = chat.unreadCount;
              }
            } else {
              newChat.unreadCount = 0;
            }
            mainChatList.insert(0, newChat);
            isNewChat = false;
          }
        }
      } else if (newChat.type == "BroadcastList") {
        if (chat.list != null) {
          if (chat.list.uuid == newChat.list.uuid) {
            mainChatList.remove(chat);
            if (inChatUuid != chat.list.uuid) {
              if (newChat.list.user.uuid != userUuid) {
                newChat.unreadCount = chat.unreadCount + 1;
              } else {
                newChat.unreadCount = chat.unreadCount;
              }
            } else {
              newChat.unreadCount = 0;
            }
            mainChatList.insert(0, newChat);
            isNewChat = false;
          }
        }
      }
    });
    if (isNewChat) {
      newChat.unreadCount = 1;
      mainChatList.insert(0, newChat);
    }
    mainChatList.sort((b, a) => convertedTime(a.lastMessage.insertedAt)
        .compareTo(convertedTime(b.lastMessage.insertedAt)));
    String chats = jsonEncode(mainChatList
        .map<Map<String, dynamic>>((chats) => Chats.toMap(chats))
        .toList());
    final preferences = await HivePreferences.getInstance();
    preferences.setCurrentChats(chats);
    notifyListeners();
  }

  void updatedArchivedChats(Chats newChat) async {
    List<Chats> messagesList = List.from(mainArchivedChatList);
    bool isNewChat = true;
    messagesList.forEach((Chats chat) {
      if (newChat.type == "DirectMessage") {
        if (chat.user != null) {
          if (directMessageKey(chat.lastMessage) ==
              directMessageKey(newChat.lastMessage)) {
            mainArchivedChatList.remove(chat);
            if (inChatUuid != chat.user.uuid) {
              if (newChat.lastMessage.fromUuid != userUuid) {
                newChat.unreadCount = chat.unreadCount + 1;
              } else {
                newChat.unreadCount = chat.unreadCount;
              }
            } else {
              newChat.unreadCount = 0;
            }
            mainArchivedChatList.insert(0, newChat);
            isNewChat = false;
          }
        }
      } else if (newChat.type == "GroupMessage") {
        if (chat.group != null) {
          if (chat.group.uuid == newChat.group.uuid) {
            mainArchivedChatList.remove(chat);
            if (inChatUuid != chat.group.uuid) {
              if (newChat.user.uuid != userUuid) {
                newChat.unreadCount = chat.unreadCount + 1;
              } else {
                newChat.unreadCount = chat.unreadCount;
              }
            } else {
              newChat.unreadCount = 0;
            }
            mainArchivedChatList.insert(0, newChat);
            isNewChat = false;
          }
        }
      } else if (newChat.type == "BroadcastList") {
        if (chat.list != null) {
          if (chat.list.uuid == newChat.list.uuid) {
            mainArchivedChatList.remove(chat);
            if (inChatUuid != chat.list.uuid) {
              if (newChat.list.user.uuid != userUuid) {
                newChat.unreadCount = chat.unreadCount + 1;
              } else {
                newChat.unreadCount = chat.unreadCount;
              }
            } else {
              newChat.unreadCount = 0;
            }
            mainArchivedChatList.insert(0, newChat);
            globalAmplitudeService?.sendAmplitudeData(
                'broadcast archived chats uuid',
                newChat.lastMessage.content,
                true);
            isNewChat = false;
          }
        }
      }
    });
    if (isNewChat) {
      mainArchivedChatList.insert(0, newChat);
    }
    String chats = jsonEncode(mainArchivedChatList
        .map<Map<String, dynamic>>((chats) => Chats.toMap(chats))
        .toList());
    final preferences = await HivePreferences.getInstance();
    preferences.setArchivedChats(chats);
    notifyListeners();
  }

  void updateChat(String messageType, MessagePhoenix message) async {
    Chats newChat = Chats();
    LastMessage lastMessage = LastMessage();
    lastMessage.uuid = message.uuid;
    lastMessage.insertedAt = message.insertedAt;
    lastMessage.content = message.content;
    lastMessage.fromUuid = message.fromUuid;
    lastMessage.toUuid = message.toUuid;
    lastMessage.file = message.file;
    lastMessage.contentType = message.contentType;
    var uuid = message.fromUuid;
    if (messageType == "DirectMessage") {
      uuid = message.toUuid;
      if (uuid == userUuid) {
        uuid = message.fromUuid;
      }
    }
    newChat.type = messageType;
    newChat.user = message.user;
    newChat.uuid = uuid;
    newChat.lastMessage = lastMessage;
    newChat.group = message.group;
    newChat.list = message.listData;
    newChat.muted = message.muted;
    newChat.unreadCount = 0;
    updateIncomingLocalChats(newChat);
  }

  void updateBroadCastChat(BroadCastMessage message) async {
    Chats newChat = Chats();
    LastMessage lastMessage = LastMessage();
    GroupChatData group = GroupChatData();
    group.uuid = "";
    lastMessage.uuid = message.message.uuid;
    lastMessage.insertedAt = message.message.insertedAt;
    lastMessage.content = message.message.content;
    lastMessage.fromUuid = message.message.fromUuid;
    lastMessage.file = message.message.file;
    lastMessage.contentType = message.message.contentType;
    newChat.type = "BroadcastList";
    newChat.group = group;
    newChat.uuid = message.listData.uuid;
    newChat.user = message.listData.user;
    newChat.muted = message.listData.muted;
    newChat.lastMessage = lastMessage;
    newChat.list = message.listData;
    newChat.unreadCount = 0;
    updateIncomingLocalChats(newChat);
  }

  void updateMutedStatus(String type, String uuid, bool muted) async {
    switch (type) {
      case "DirectMessage":
        mainChatList.forEach((chat) {
          if (uuid == chat.uuid) chat.muted = muted;
        });
        break;
      case "BroadcastList":
        mainChatList.forEach((chat) {
          if (uuid == chat.list.uuid) chat.muted = muted;
        });
        break;
      case "GroupMessage":
        mainChatList.forEach((chat) {
          if (uuid == chat.uuid) chat.muted = muted;
        });
        break;
    }
    notifyListeners();
    String chats = jsonEncode(mainChatList
        .map<Map<String, dynamic>>((chats) => Chats.toMap(chats))
        .toList());
    final preferences = await HivePreferences.getInstance();
    preferences.setCurrentChats(chats);
  }

  void setLocal() async {
    final preferences = await HivePreferences.getInstance();
    String chats = jsonEncode(mainChatList
        .map<Map<String, dynamic>>((chats) => Chats.toMap(chats))
        .toList());
    preferences.setCurrentChats(chats);
  }

  void update() {
    notifyListeners();
  }

  void updateTimeSorting() {
    mainChatList.sort((b, a) => convertedTime(a.lastMessage.insertedAt)
        .compareTo(convertedTime(b.lastMessage.insertedAt)));
    notifyListeners();
  }
}
