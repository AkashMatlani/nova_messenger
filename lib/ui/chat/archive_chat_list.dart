import 'dart:convert';
import 'package:nova/networking/http_service.dart';
import 'package:nova/ui/groupchats/group_chat.dart';
import 'package:nova/viewmodels/chat_list_viewmodel.dart';
import 'package:nova/viewmodels/chat_viewmodel.dart';
import 'package:nova/models/chats.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/ui/broadcasts/broadcast_chat.dart';
import 'package:flutter/material.dart';
import 'package:nova/ui/chat/chat.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nova/utils/commons.dart';
import 'package:nova/utils/hive_preferences.dart';
import 'package:provider/provider.dart';

class ArchiveChatList extends StatefulWidget {
  List<Chats> messagesArchivedList;

  ArchiveChatList(this.messagesArchivedList);

  @override
  _ArchiveChatListState createState() => _ArchiveChatListState();
}

class _ArchiveChatListState extends State<ArchiveChatList> {
  List searchResult = [];
  TextEditingController controller = TextEditingController();
  bool _onlineStatus = true;
  HttpService _api = serviceLocator<HttpService>();

  final GlobalKey<ScaffoldState> _scaffoldArchiveKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatListViewModel>.value(
        value: serviceLocator<ChatListViewModel>(),
        child: Consumer<ChatListViewModel>(
            builder: (context, model, child) => Scaffold(
                  key: _scaffoldArchiveKey,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: _onlineStatus
                      ? Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    model.mainArchivedChatList != null
                                        ? model.mainArchivedChatList.length > 0
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 0),
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(40),
                                                              topLeft: Radius
                                                                  .circular(
                                                                      40)),
                                                    ),
                                                    child:
                                                        listToArchivedMessages(
                                                            model)),
                                              )
                                            : Center(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Material(
                                                        type: MaterialType
                                                            .transparency,
                                                        elevation: 1.0,
                                                        child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 150,
                                                                    bottom: 50),
                                                            child: Image.asset(
                                                                'assets/images/time.png',
                                                                height: 120,
                                                                fit: BoxFit
                                                                    .fill))),
                                                    Text(
                                                      "The archives are empty.",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16, // light
                                                        fontStyle: FontStyle
                                                            .normal, // italic
                                                      ),
                                                    ),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 20,
                                                                bottom: 10),
                                                        child: Text(
                                                            "Currently you don't have any archived messages.")),
                                                  ],
                                                ),
                                              )
                                        : Container(
                                            height:
                                                SizeConfig.blockSizeVertical *
                                                    50,
                                            child: Center(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Material(
                                                      type: MaterialType
                                                          .transparency,
                                                      elevation: 1.0,
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 150,
                                                                  bottom: 50),
                                                          child: Image.asset(
                                                              'assets/images/time.png',
                                                              height: 120,
                                                              fit: BoxFit
                                                                  .fill))),
                                                  Text(
                                                    "The archives are empty.",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16, // light
                                                      fontStyle: FontStyle
                                                          .normal, // italic
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 20,
                                                              bottom: 10),
                                                      child: Text(
                                                          "Currently you don't have any archived messages.")),
                                                ],
                                              ),
                                            )),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          child:
                              errorMessage("No Internet Connection Available"),
                        ),
                )));
  }

  Widget listToArchivedMessages(ChatListViewModel model) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: searchResult.length != 0 ||
                controller.text.trim().toLowerCase().isNotEmpty
            ? ListView.builder(
                itemCount: searchResult.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, int index) {
                  return buildArchiveItem(searchResult[index], index);
                },
              )
            : ListView.builder(
                itemCount: model.mainArchivedChatList.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, int index) {
                  return buildArchiveItem(
                      model.mainArchivedChatList[index], index);
                },
              ));
  }

  Widget searchBar() {
    return Padding(
        padding: const EdgeInsets.only(top: 10, right: 15, left: 15),
        child: Container(
          decoration: BoxDecoration(
              // color: Colors.green,
              borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          )),
          height: 40,
          child: Center(
            child: TextField(
              controller: controller,
              onChanged: onSearchTextChanged,
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
                    const Radius.circular(15.0),
                  ),
                ),
                filled: true,
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                hintText: "Search",
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

  Widget buildArchiveItem(Chats chat, int index) {
    String chatText = "";
    if (chat.type == "DirectMessage") {
      chatText = chat.user.name;
    } else if (chat.type == "GroupMessage") {
      chatText = chat.group.name;
    } else if (chat.type == "BroadcastList") {
      chatText = chat.list.name;
    }
    return Column(
      children: <Widget>[
        Divider(
          height: 10.0,
        ),
        Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: 'Unarchive',
                color: Colors.purple,
                foregroundColor: Colors.white,
                icon: Icons.archive_outlined,
                onTap: () async {
                  // server //
                  switch (chat.type) {
                    case "DirectMessage":
                      globalSocketService.push(
                          event: "mark_as_active",
                          payload: {"to": chat.user.uuid});
                      break;
                    case "BroadcastList":
                      globalSocketService.push(
                          id: chat.list.uuid,
                          type: "broadcast",
                          event: "activate_list_chat");
                      break;
                    case "GroupMessage":
                      globalSocketService.push(
                          id: chat.group.uuid,
                          type: "group",
                          event: "activate_group_chat");
                  }
                  // local //
                  Chats archiveDirectMessage =
                      serviceLocator<ChatListViewModel>()
                          .mainArchivedChatList
                          .firstWhere((chat) => chat.uuid == chat.uuid);
                  serviceLocator<ChatListViewModel>()
                      .mainChatList
                      .insert(0, archiveDirectMessage);
                  serviceLocator<ChatListViewModel>()
                      .mainArchivedChatList
                      .removeWhere((item) => item.uuid == chat.uuid);
                  serviceLocator<ChatListViewModel>().update();
                  // persist //
                  final preferences = await HivePreferences.getInstance();
                  String archived = jsonEncode(
                      serviceLocator<ChatListViewModel>()
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
              IconSlideAction(
                caption: 'Delete',
                color: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                onTap: () async {
                  switch (chat.type) {
                    case "DirectMessage":
                      globalSocketService.push(
                          event: "delete_chat",
                          payload: {"to": chat.user.uuid});
                      serviceLocator<ChatViewModel>().messages[chat.user.uuid] =
                          [];
                      String encodedDirectMessages =
                          json.encode(serviceLocator<ChatViewModel>().messages);
                      serviceLocator<ChatListViewModel>()
                          .deleteLocalArchiveDirectChat(chat.user.uuid);
                      final preferences = await HivePreferences.getInstance();
                      preferences.setDirectChats(encodedDirectMessages);
                      serviceLocator<ChatViewModel>().update();
                      break;
                    case "BroadcastList":
                      if (chat.list.user.uuid == userUuid) {
                        var response =
                            await _api.deleteBroadCastList(chat.list.uuid);
                        if (response != null) {
                          serviceLocator<ChatListViewModel>()
                              .deleteListArchivedChat(chat.list.uuid);
                        } else {
                          Commons.novaFlushBarError(context,
                              "Error deleting list. Please try again.");
                        }
                      } else {
                        Commons.novaFlushBarError(context,
                            "You are not the owner of this broadcast. Cannot delete list.");
                      }
                      break;
                    case "GroupMessage":
                      if (chat.group.user.uuid == userUuid) {
                        var response = await _api.deleteGroup(chat.group.uuid);
                        if (response != null) {
                          serviceLocator<ChatListViewModel>()
                              .deleteArchivedGroupChat(chat.group.uuid);
                        } else {
                          Commons.novaFlushBarError(context,
                              "Error deleting group. Please try again.");
                        }
                      } else {
                        Commons.novaFlushBarError(context,
                            "You are not the owner of this group. Cannot delete group.");
                      }
                      break;
                  }
                },
              ),
            ],
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    onTap: () {
                      if (chat.type == "GroupMessage") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GroupChat(
                                    groupChatData: chat.group,
                                  )),
                        );
                      } else {
                        if (chat.type == "DirectMessage") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Chat(
                                      peerData: chat.user,
                                    )),
                          );
                        } else if (chat.type == "BroadcastList") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BroadCastChat(
                                      broadcastData: chat.list,
                                    )),
                          );
                        }
                      }
                    },
                    leading: Stack(
                      children: <Widget>[
                        InkWell(
                            onTap: () {},
                            child: Stack(
                              children: [
                                imageWidget(chat.type == "DirectMessage"
                                    ? chat.user.avatar
                                    : chat.list.avatar),
                              ],
                            )),
                      ],
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          chatText,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: Container(
                      padding: const EdgeInsets.only(top: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          chat.lastMessage.contentType == "image"
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
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                )
                              : chat.lastMessage.contentType == "video"
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
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    )
                                  : chat.lastMessage.contentType == "file"
                                      ? Row(
                                          children: [
                                            Icon(
                                              Icons.note,
                                              color: Colors.grey,
                                              size: 17,
                                            ),
                                            Text(
                                              "  File",
                                              maxLines: 2,
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14.0,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                          ],
                                        )
                                      : chat.lastMessage.contentType == "audio"
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
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              chat.lastMessage.content,
                                              maxLines: 2,
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14.0,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          readTimestamp(
                            DateTime.parse(
                              converTime(chat.lastMessage.insertedAt),
                            ).millisecondsSinceEpoch,
                          ),
                          style: TextStyle(
                              color: chat.lastMessage.status != "read"
                                  ? appColor
                                  : Colors.grey,
                              fontSize: 10.0,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        height: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ))
      ],
    );
  }

  Widget imageWidget(image) {
    return image != ""
        ? Container(
            height: 50,
            width: 50,
            child: CircleAvatar(
              //radius: 60,
              foregroundColor: Theme.of(context).primaryColor,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(image),
            ),
          )
        : Container(
            height: 50,
            width: 50,
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

  onSearchTextChanged(String text) async {
    searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    setState(() {});
  }
}
