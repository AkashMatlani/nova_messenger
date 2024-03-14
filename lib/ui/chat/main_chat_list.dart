import 'dart:async';
import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nova/models/broadcast_list.dart';
import 'package:nova/models/chats.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/ui/broadcasts/broadcast_chat.dart';
import 'package:nova/ui/chat/chat.dart';
import 'package:nova/ui/groupchats/group_chat.dart';
import 'package:nova/utils/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:nova/utils/hive_preferences.dart';
import 'package:nova/viewmodels/chat_list_viewmodel.dart';
import 'package:nova/viewmodels/chat_viewmodel.dart';
import 'package:provider/provider.dart';

class ChatList extends StatefulWidget {
  ChatList();

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList>
    with AutomaticKeepAliveClientMixin<ChatList> {
  @override
  bool get wantKeepAlive => true;

  List<Chats> searchResult = [];
  TextEditingController controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldChatListKey =
      GlobalKey<ScaffoldState>();

  FocusNode focusNode = FocusNode();
  String hintText = 'Search';

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // gotoPreviousSavedPage();
    });
    inHome = true;
    inChatUuid = "";
    print("InHome = " + inHome.toString());
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        hintText = '';
      } else {
        hintText = 'Search';
      }
      setState(() {});
    });
    startApp();
    initDeepLinks();
    super.initState();
  }

  void startApp() async {
    try {
      await startAppServices(context);
      isOffline = false;
    } catch (e) {
      isOffline = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatListViewModel>.value(
        value: serviceLocator<ChatListViewModel>(),
        child: Consumer<ChatListViewModel>(
            builder: (context, model, child) => Scaffold(
                key: _scaffoldChatListKey,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            !appServicesInitialStart
                                ? Center(
                                    child: Commons.novaLoading(),
                                  )
                                : Container(),
                            Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: searchBar(model.mainChatList)),
                            model.mainChatList.length > 0
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(40),
                                              topLeft: Radius.circular(40)),
                                        ),
                                        child:
                                            listToMessages(model.mainChatList)),
                                  )
                                : Container(
                                    height: SizeConfig.blockSizeVertical * 50,
                                    child: Center(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Material(
                                              type: MaterialType.transparency,
                                              elevation: 1.0,
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 50, bottom: 50),
                                                  child: Image.asset(
                                                      'assets/images/search_icon.png',
                                                      height: 120,
                                                      fit: BoxFit.fill))),
                                          Text(
                                            "No messages here.",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16, // light
                                              fontStyle:
                                                  FontStyle.normal, // italic
                                            ),
                                          ),
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20, bottom: 10),
                                              child: Text(
                                                  "Currently you don't have any messages.")),
                                        ],
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ))));
  }

  Widget listToMessages(List<dynamic> messages) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: searchResult.length != 0 ||
                controller.text.trim().toLowerCase().isNotEmpty
            ? ListView.builder(
                itemCount: searchResult.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, int index) {
                  return buildItem(searchResult, index);
                },
              )
            : ListView.builder(
                itemCount: messages.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, int index) {
                  return buildItem(messages, index);
                },
              ));
  }

  Widget searchBar(List<Chats> messages) {
    messagesSearchChat = messages;
    return Padding(
        padding: const EdgeInsets.only(top: 10, right: 15, left: 15),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          )),
          height: 40,
          child: Center(
            child: TextField(
              controller: controller,
              onChanged: onSearchTextChanged,
              focusNode: focusNode,
              style: TextStyle(color: Colors.grey),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(15.0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(15.0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(6.0),
                  ),
                ),
                filled: true,
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                hintText: hintText,
                contentPadding: EdgeInsets.only(top: 10.0),
                fillColor: Colors.grey.withOpacity(0.2),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[600],
                  size: 25.0,
                ),
              ),
            ),
          ),
        ));
  }

  Widget buildItem(List<Chats> messageList, int index) {
    return Column(
      children: <Widget>[
        Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: Row(
            children: [
              Expanded(
                child: ListTile(
                  onTap: () async {
                    gotoPage(messageList, messageList[index]);
                  },
                  leading: Stack(
                    children: <Widget>[
                      InkWell(
                          onTap: () {},
                          child: Stack(
                            children: [
                              messageList[index].type == "DirectMessage"
                                  ? imageWidget(messageList[index].user.avatar)
                                  : messageList[index].type == "GroupMessage"
                                      ? imageWidget(
                                          messageList[index].group.avatar)
                                      : messageList[index].type ==
                                              "BroadcastList"
                                          ? imageWidget(
                                              messageList[index].list.avatar)
                                          : Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[400],
                                                  shape: BoxShape.circle),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Image.asset(
                                                  "assets/images/user.png",
                                                  height: 10,
                                                  color: Colors.white,
                                                ),
                                              )),
                            ],
                          )),
                    ],
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: messageList[index].type == "DirectMessage"
                            ? Text(
                                messageList[index].user.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: chatMainChatsTitleFontSize,
                                ),
                              )
                            : messageList[index].type == "GroupMessage"
                                ? Text(
                                    messageList[index].group.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: chatMainChatsTitleFontSize,
                                    ),
                                  )
                                : messageList[index].type == "BroadcastList"
                                    ? Text(
                                        messageList[index].list.name,
                                        style: TextStyle(
                                            fontSize: chatMainChatsTitleFontSize,
                                            fontWeight: FontWeight.w600),
                                      )
                                    : Container(),
                      )
                    ],
                  ),
                  subtitle: Container(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        messageList[index].lastMessage.contentType == "image"
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    color: Colors.grey,
                                    size: 17,
                                  ),
                                  Text(
                                    "  Photo",
                                    maxLines: 2,
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              )
                            : messageList[index].lastMessage.contentType ==
                                    "video"
                                ? Row(
                                    children: [
                                      Icon(
                                        Icons.video_call,
                                        color: Colors.grey,
                                        size: 17,
                                      ),
                                      Text(
                                        "  Video",
                                        maxLines: 2,
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  )
                                : messageList[index].lastMessage.contentType ==
                                        "file"
                                    ? Row(
                                        children: [
                                          !messageList[index]
                                                  .lastMessage
                                                  .file
                                                  .contains(".pdf")
                                              ? Icon(
                                                  Icons.note,
                                                  size: 17,
                                                  color: Colors.grey,
                                                )
                                              : SvgPicture.asset(
                                                  'assets/images/filepdf.svg',
                                                  fit: BoxFit.fill,
                                                ),
                                          messageList[index]
                                                  .lastMessage
                                                  .file
                                                  .contains(".pdf")
                                              ? Text(
                                                  "",
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                )
                                              : Text(
                                                  "  File",
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                        ],
                                      )
                                    : messageList[index]
                                                .lastMessage
                                                .contentType ==
                                            "audio"
                                        ? Row(
                                            children: [
                                              Icon(
                                                Icons.audiotrack,
                                                color: Colors.grey,
                                                size: 17,
                                              ),
                                              Text(
                                                "  Audio",
                                                maxLines: 2,
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 15.0,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            messageList[index]
                                                .lastMessage
                                                .content,
                                            maxLines: 1,
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.normal),
                                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10, top: 5),
                child: Column(
                  children: [
                    messageList[index].unreadCount != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              readTimestamp(
                                DateTime.parse(
                                  converTime(messageList[index]
                                      .lastMessage
                                      .insertedAt),
                                ).millisecondsSinceEpoch,
                              ),
                              style: TextStyle(
                                  color: messageList[index].unreadCount > 0
                                      ? appColor
                                      : Colors.grey,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              readTimestamp(
                                DateTime.parse(
                                  converTime(messageList[index]
                                      .lastMessage
                                      .insertedAt),
                                ).millisecondsSinceEpoch,
                              ),
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                    Container(
                      height: 5,
                    ),
                    Row(
                      children: [
                        messageList[index].muted != null
                            ? messageList[index].muted
                                ? Icon(
                                    Icons.volume_mute_outlined,
                                    color: Colors.grey,
                                    size: 20.0,
                                  )
                                : Container()
                            : Container(),
                        messageList[index].unreadCount != null
                            ? messageList[index].unreadCount > 0
                                ? Row(
                                    children: [
                                      Container(
                                        height: 15,
                                        width: 15,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: appColor),
                                        child: Center(
                                            child: Text(
                                          messageList[index]
                                              .unreadCount
                                              .toString(),
                                          style: TextStyle(
                                              color: messageList[index]
                                                          .unreadCount >
                                                      0
                                                  ? Colors.white
                                                  : Colors.grey,
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.w500),
                                        )),
                                      ),
                                    ],
                                  )
                                : Container()
                            : Container(child: Text("")),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: 'More',
              color: Colors.grey[400],
              foregroundColor: Colors.white,
              icon: Icons.more_horiz,
              onTap: () {
                String userUuid = "";
                String typeUuid = "";
                switch (messageList[index].type) {
                  case "BroadcastList":
                    userUuid = messageList[index].list.user.uuid;
                    typeUuid = messageList[index].list.uuid;
                    break;
                  case "GroupMessage":
                    userUuid = messageList[index].group.user.uuid;
                    typeUuid = messageList[index].group.uuid;
                    break;
                  case "DirectMessage":
                    userUuid = messageList[index].user.uuid;
                    typeUuid = messageList[index].uuid;
                    break;
                }
                _settingModalBottomSheet(
                  context,
                  userUuid,
                  typeUuid,
                  messageList[index].muted,
                  messageList[index].type,
                );
              },
            ),
            IconSlideAction(
              caption: 'Archive',
              color: appColor,
              foregroundColor: Colors.white,
              icon: Icons.archive,
              onTap: () async {
                // set server //
                switch (messageList[index].type) {
                  case "DirectMessage":
                    await globalSocketService.push(
                        event: "mark_as_archived",
                        payload: {"to": messageList[index].user.uuid});
                    break;
                  case "BroadcastList":
                    await globalSocketService.push(
                        id: messageList[index].list.uuid,
                        type: "broadcast",
                        event: "archive_list_chat");
                    break;
                  case "GroupMessage":
                    await globalSocketService.push(
                        id: messageList[index].group.uuid,
                        type: "group",
                        event: "archive_group_chat");
                    break;
                }
                // local //
                Chats archiveDirectMessage = serviceLocator<ChatListViewModel>()
                    .mainChatList
                    .firstWhere((chat) => chat.uuid == messageList[index].uuid);
                serviceLocator<ChatListViewModel>()
                    .mainArchivedChatList
                    .insert(0, archiveDirectMessage);
                serviceLocator<ChatListViewModel>().mainChatList.removeWhere(
                    (item) => item.uuid == messageList[index].uuid);
                serviceLocator<ChatListViewModel>().update();
                // serviceLocator<ChatListViewModel>().mainArchivedChatList = [];
                // persist //
                final preferences = await HivePreferences.getInstance();
                String archived = jsonEncode(serviceLocator<ChatListViewModel>()
                    .mainArchivedChatList
                    .map<Map<String, dynamic>>(
                        (messages) => Chats.toMap(messages))
                    .toList());
                preferences.setArchivedChats(archived);
                //
                String chats = jsonEncode(serviceLocator<ChatListViewModel>()
                    .mainChatList
                    .map<Map<String, dynamic>>((chats) => Chats.toMap(chats))
                    .toList());
                preferences.setCurrentChats(chats);
              },
            ),
          ],
        )
      ],
    );
  }

  Widget imageWidget(image) {
    return image != ""
        ? Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: customImage(image),
            ))
        : Container(
            height: 60,
            width: 60,
            decoration:
                BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                "assets/images/user.png",
                height: 10,
                color: Colors.white,
              ),
            ));
  }

  Widget friendName(AsyncSnapshot friendListSnapshot, int index) {
    return Container(
      width: 200,
      alignment: Alignment.topLeft,
      child: RichText(
        text: TextSpan(children: <TextSpan>[
          TextSpan(
            text:
                "${friendListSnapshot.data["firstname"]} ${friendListSnapshot.data["lastname"]}",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
          )
        ]),
      ),
    );
  }

  List<Chats> messagesSearchChat = [];

  onSearchTextChanged(String text) async {
    searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    messagesSearchChat.forEach((chatData) {
      if (chatData.lastMessage.content
          .toLowerCase()
          .contains(text.toLowerCase())) {
        searchResult.add(chatData);
      } else {
        switch (chatData.type) {
          case "DirectMessage":
            if (chatData.user.name.toLowerCase().contains(text.toLowerCase()))
              searchResult.add(chatData);
            break;
          case "BroadcastList":
            if (chatData.list.name.toLowerCase().contains(text.toLowerCase()))
              searchResult.add(chatData);
            break;
          case "GroupMessage":
            if (chatData.group.name.toLowerCase().contains(text.toLowerCase()))
              searchResult.add(chatData);
            break;
        }
      }
    });

    setState(() {});
  }

  void _settingModalBottomSheet(context, userUuidChat, typeUuid, mute, type) {
    containerForSheet<String>(
        context: context,
        child: CupertinoActionSheet(
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: mute == true
                  ? Text(
                      "Unmute ",
                      style: TextStyle(
                          color: appColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    )
                  : Text(
                      "Mute ",
                      style: TextStyle(
                          color: appColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
              onPressed: () async {
                if (mute == true) {
                  Navigator.of(context, rootNavigator: true).pop("Discard");
                  switch (type) {
                    case "DirectMessage":
                      await globalSocketService
                          .push(event: "unmute", payload: {"to": userUuidChat});
                      break;
                    case "BroadcastList":
                      await globalSocketService
                          .getBroadcastChannel(typeUuid)
                          .push(event: "unmute_list_chat");
                      break;
                    case "GroupMessage":
                      await globalSocketService.push(
                          id: typeUuid,
                          type: "group",
                          event: "unmute_group_chat");
                      break;
                  }
                  serviceLocator<ChatListViewModel>()
                      .updateMutedStatus(type, typeUuid, false);
                } else {
                  Navigator.of(context, rootNavigator: true).pop("Discard");
                  switch (type) {
                    case "DirectMessage":
                      await globalSocketService
                          .push(event: "mute", payload: {"to": userUuidChat});
                      break;
                    case "BroadcastList":
                      await globalSocketService
                          .getBroadcastChannel(typeUuid)
                          .push(event: "mute_list_chat");
                      break;
                    case "GroupMessage":
                      await globalSocketService.push(
                          id: typeUuid,
                          type: "group",
                          event: "mute_group_chat");
                      break;
                  }
                  serviceLocator<ChatListViewModel>()
                      .updateMutedStatus(type, typeUuid, true);
                }
              },
            ),
            CupertinoActionSheetAction(
              child: Text(
                "Delete",
                style: TextStyle(
                    color: appColor, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop("Discard");
                switch (type) {
                  case "DirectMessage":
                    globalSocketService
                        .push(event: "delete_chat", payload: {"to": typeUuid});
                    serviceLocator<ChatViewModel>().messages[userUuidChat] = [];
                    String encodedDirectMessages =
                        json.encode(serviceLocator<ChatViewModel>().messages);
                    serviceLocator<ChatListViewModel>()
                        .deleteLocalDirectChat(typeUuid);
                    final preferences = await HivePreferences.getInstance();
                    preferences.setDirectChats(encodedDirectMessages);
                    serviceLocator<ChatViewModel>().update();
                    break;
                  case "BroadcastList":
                    if (userUuidChat == userUuid) {
                      showDeleteChat(typeUuid, context, "broadcast list");
                    } else {
                      showLeaveChat(typeUuid, context, "broadcast list");
                    }
                    break;
                  case "GroupMessage":
                    if (userUuidChat == userUuid) {
                      showDeleteChat(typeUuid, context, "group");
                    } else {
                      showLeaveChat(typeUuid, context, "group");
                    }
                    break;
                }
              },
            )
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(
              "Cancel",
              style: TextStyle(
                  color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop("Discard");
            },
          ),
        ));
  }

  void gotoPage(List<Chats> messageList, Chats chat) {
    if (mounted) {
      Chats savedpage = Chats();
      serviceLocator<ChatViewModel>().lastPageData["savedPage"] = savedpage;
      serviceLocator<ChatViewModel>().lastPageData["savedPage"] = chat;
      serviceLocator<ChatViewModel>().updateLastSavedPage();
      if (chat.type == "GroupMessage") {
        inHome = false;
        if (messageList.length > 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GroupChat(
                      groupChatData: chat.group,
                    )),
          ).then((value) => inHome = true);
        }
        globalAmplitudeService?.getAnalyticService().logEvent('GroupChat',
            eventProperties: {
              'in group chat pushed': true,
              "group chat uuid": chat.group.uuid
            });
      } else if (chat.type == "DirectMessage") {
        if (messageList.length > 0) {
          inHome = false;
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Chat(
                      peerData: chat.user,
                      chatData: chat,
                    )),
          ).then((value) => inHome = true);
          globalAmplitudeService?.getAnalyticService().logEvent('Chat',
              eventProperties: {
                'in direct chat pushed': true,
                "chat uuid": chat.uuid
              });
        }
      } else if (chat.type == "BroadcastList") {
        if (messageList.length > 0) {
          BroadcastList broadcastData = BroadcastList();
          broadcastData = chat.list;
          inHome = false;
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BroadCastChat(
                      broadcastData: broadcastData,
                    )),
          ).then((value) => inHome = true);
          globalAmplitudeService?.getAnalyticService().logEvent('BroadcastChat',
              eventProperties: {
                'in list chat pushed': true,
                "list uuid": broadcastData.uuid
              });
        }
      }
    }
  }

  void gotoPreviousSavedPage() {
    if (serviceLocator<ChatViewModel>().lastPageData["savedPage"] != null &&
        fromPushUuid == "") {
      Chats chat = serviceLocator<ChatViewModel>().lastPageData["savedPage"];
      if (mounted) {
        if (chat.type == "GroupMessage") {
          inHome = false;
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GroupChat(
                      groupChatData: chat.group,
                    )),
          );
        } else if (chat.type == "DirectMessage") {
          inHome = false;
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Chat(
                      peerData: chat.user,
                      chatData: chat,
                    )),
          );
        } else if (chat.type == "BroadcastList") {
          inHome = false;
          BroadcastList broadcastData = BroadcastList();
          broadcastData = chat.list;
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BroadCastChat(
                      broadcastData: broadcastData,
                    )),
          );
        }
      }
    }
  }

  AppLinks _appLinks;
  StreamSubscription<Uri> _linkSubscription;

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();
    final appLink = await _appLinks.getLatestAppLink();
    if (appLink != null) {
      openAppLink(appLink);
    }

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      openAppLink(uri);
    });
  }

  void openAppLink(Uri uri) {
    if (uri.queryParameters.containsKey('peerUuid')) {
      String storeMessageParams = uri.queryParameters['storeMessage'];
      String chatPeerUuidParams = uri.queryParameters['peerUuid'];
      var peerUser = contactsGlobalData.firstWhere(
          (element) => element.uuid == chatPeerUuidParams,
          orElse: () => null);
      if (peerUser != null) {
        inHome = false;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Chat(
                    peerData: peerUser,
                    storeMessage: storeMessageParams,
                  )),
        );
      }
    }
  }
}
