import 'package:nova/models/broadcast_list.dart';
import 'package:nova/models/broadcasts.dart';
import 'package:nova/models/contact_data.dart';
import 'package:nova/models/group_chat_data.dart';
import 'package:nova/models/message.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/ui/broadcasts/broadcast_chat.dart';
import 'package:nova/ui/chat/chat.dart';
import 'package:nova/ui/groupchats/group_chat.dart';
import 'package:flutter/material.dart';
import 'package:nova/constant/global.dart';

class ForwardMessage extends StatefulWidget {
  final MessagePhoenix message;
  final String type;

  ForwardMessage(this.message, this.type);

  @override
  ForwardMessageState createState() {
    return ForwardMessageState();
  }
}

class ForwardMessageState extends State<ForwardMessage> {
  TextEditingController searchController = TextEditingController();
  List<ContactData> contactsDetailsInfo = [];
  HttpService _api = serviceLocator<HttpService>();
  FocusNode focusNode = FocusNode();
  String hintText = 'Search';
  List<GroupChatData> groupData = [];
  List<BroadcastList> broadCastData = [];
  List<ContactData> searchResultList = [];
  List<ContactData> oneToOneForwardList = [];
  List<GroupChatData> groupForwardList = [];
  List<BroadcastList> broadCastForwardList = [];

  @override
  void initState() {
    contactsDetailsInfo = contactsGlobalData;
    searchResultList = contactsDetailsInfo;
    super.initState();
    inHome = false;
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        hintText = '';
      } else {
        hintText = 'Search';
      }
      setState(() {});
    });
    getGroups();
    getBroadcast();
  }

  void getGroups() async {
    if (await checkInternet()) {
      List<GroupChatData> response = await _api.getGroups();
      if (response != null) {
        if (mounted) {
          setState(() {
            groupData = response;
          });
        }
      }
    }
  }

  void getBroadcast() async {
    if (await checkInternet()) {
      List<BroadcastList> response = await _api.getBroadcastLists();
      if (response != null) {
        if (mounted) {
          setState(() {
            broadCastData = response;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Forward to...',
            style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 20),
          ),
          centerTitle: false,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 10),
                child: TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: appColor),
                  ),
                  onPressed: () {
                    for (int i = 0; i < oneToOneForwardList.length; i++) {
                      clearOneToOneData(oneToOneForwardList[i]);
                    }
                    oneToOneForwardList = [];
                    for (int j = 0; j < groupForwardList.length; j++) {
                      clearGroupData(groupForwardList[j]);
                    }
                    groupForwardList = [];
                    for (int k = 0; k < broadCastForwardList.length; k++) {
                      clearBroadCastData(broadCastForwardList[k]);
                    }
                    broadCastForwardList = [];
                    Navigator.pop(context);
                    inHome = true;
                  },
                )),
          ]),
      body: Column(children: <Widget>[
        Padding(
            padding: const EdgeInsets.all(15),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(
                    Radius.circular(15.0),
                  )),
              height: 40,
              child: Center(
                child: TextField(
                  controller: searchController,
                  focusNode: focusNode,
                  onChanged: (query) {
                    searchResultData(query);
                  },
                  style: TextStyle(color: Colors.grey),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[200]),
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(15.0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[200]),
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(15.0),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[200]),
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(15.0),
                      ),
                    ),
                    filled: true,
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                    hintText: hintText,
                    contentPadding: EdgeInsets.only(top: 10.0),
                    fillColor: Colors.grey[200],
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                      size: 25.0,
                    ),
                  ),
                ),
              ),
            )),

        // Combine two list into one list
        Expanded(
            child: ListView(
                shrinkWrap: true,
                children: searchResultList.map((ContactData contactData) {
                  return InkWell(
                      onTap: () {
                          addOrRemoveItem(contactData);
                      },
                      child: Container(
                        color: contactData.isSelected != null &&
                                contactData.isSelected
                            ? appColor
                            : Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0, left: 10),
                          child: Row(
                            children: [
                              (contactData.avatar != "")
                                  ? CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(contactData.avatar),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: Colors.grey[400],
                                      child: Image.asset(
                                        "assets/images/user.png",
                                        height: 25,
                                        color: Colors.white,
                                      )),
                              Expanded(
                                child: ListTile(
                                  title: Container(
                                    child: Text(contactData.name ?? "Unknown",
                                        style: TextStyle(
                                          color: contactData.isSelected != null &&
                                              contactData.isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  subtitle: Row(children: [
                                    Expanded(
                                      child: Text(
                                        contactData.mobile ?? "",
                                        style: TextStyle(
                                            color: contactData.isSelected != null &&
                                                contactData.isSelected
                                                ? Colors.white
                                                : Colors.black87,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ));
                }).toList()
                  ..addAll(groupData.map((GroupChatData groupChatData) {
                    return InkWell(
                        onTap: () {
                          addOrRemoveItemGroup(groupChatData);
                        },
                        child: Container(
                            color: groupChatData.isSelected != null &&
                                    groupChatData.isSelected
                                ? appColor
                                : Colors.transparent,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 8.0, left: 10),
                              child: Row(
                                children: [
                                  (groupChatData.avatar != "")
                                      ? CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              groupChatData.avatar),
                                        )
                                      : CircleAvatar(
                                          backgroundColor: Colors.grey[400],
                                          child: Image.asset(
                                            "assets/images/user.png",
                                            height: 25,
                                            color: Colors.white,
                                          )),
                                  Expanded(
                                    child: ListTile(
                                      title: Text(
                                          groupChatData.name ?? "Unknown",
                                          style: TextStyle(
                                            color: groupChatData.isSelected != null &&
                                                groupChatData.isSelected
                                                ? Colors.white
                                                : Colors.black87,
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Row(children: [
                                        Expanded(
                                          child: Text(
                                            groupChatData.status ?? "",
                                            style: TextStyle(
                                                color: groupChatData.isSelected != null &&
                                                    groupChatData.isSelected
                                                    ? Colors.white
                                                    : Colors.black87,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ),
                                ],
                              ),
                            )));
                  }).toList()
                    ..addAll(broadCastData.map((BroadcastList broadChatData) {
                      return InkWell(
                          onTap: () {
                            addOrRemoveItemBroadCast(broadChatData);
                          },
                          child: Container(
                              color: broadChatData.isSelected != null &&
                                      broadChatData.isSelected
                                  ? appColor
                                  : Colors.transparent,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(right: 8.0, left: 10),
                                child: Row(
                                  children: [
                                    (broadChatData.avatar != "")
                                        ? CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                broadChatData.avatar),
                                          )
                                        : CircleAvatar(
                                            backgroundColor: Colors.grey[400],
                                            child: Image.asset(
                                              "assets/images/user.png",
                                              height: 25,
                                              color: Colors.white,
                                            )),
                                    Expanded(
                                      child: ListTile(
                                        title: Text(
                                            broadChatData.name ?? "Unknown",
                                            style: TextStyle(
                                                color: broadChatData.isSelected != null &&
                                                    broadChatData.isSelected
                                                    ? Colors.white
                                                    : Colors.black87,
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Row(children: [
                                          Expanded(
                                            child: Text(
                                              broadChatData.status ?? "",
                                              style: TextStyle(
                                                  color: broadChatData.isSelected != null &&
                                                      broadChatData.isSelected
                                                      ? Colors.white
                                                      : Colors.black87,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                  ],
                                ),
                              )));
                    }).toList())))),

        Container(
          height: 60,
          width: MediaQuery.of(context).size.width * 0.95,
          padding: EdgeInsets.only(right: 40),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            primary: true,
            child: Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                alignment: WrapAlignment.start,
                textDirection: TextDirection.ltr,
                children: [
                  for (int i = 0; i < oneToOneForwardList.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        " " + oneToOneForwardList[i].name + ",",
                      ),
                    ),
                  for (int j = 0; j < groupForwardList.length; j++)
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        " " + groupForwardList[j].name + ",",
                      ),
                    ),
                  for (int m = 0; m < broadCastForwardList.length; m++)
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        " " + broadCastForwardList[m].name + ",",
                      ),
                    ),
                ],
              ),
            ),
          ),
        )
      ]),
      floatingActionButton: Container(
        transform: Matrix4.translationValues(20.0, 10.0, 40.0),
        child: ElevatedButton(
            onPressed: () {
              if (oneToOneForwardList.isNotEmpty) {
                for (int i = 0; i < oneToOneForwardList.length; i++) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Chat(
                            peerData: oneToOneForwardList[i],
                            isForwarded: true,
                            forwardedMessage: widget.message)),
                  );
                }
              }
              if (groupForwardList.isNotEmpty) {
                for (int i = 0; i < groupForwardList.length; i++) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GroupChat(
                            groupChatData: groupForwardList[i],
                            isForwarded: true,
                            forwardedMessage: widget.message)),
                  );
                }
              }
              if (broadCastForwardList.isNotEmpty) {
                for (int i = 0; i < broadCastForwardList.length; i++) {
                  Broadcast broadCast = new Broadcast();
                  broadCast.fromUuid = widget.message.fromUuid;
                  broadCast.content = widget.message.content;
                  broadCast.contentType = widget.message.contentType;
                  if (widget.message.file != null &&
                      widget.message.file.isNotEmpty) {
                    broadCast.file = widget.message.file;
                  } else {
                    broadCast.file = "";
                  }
                  broadCast.fromUuid = userUuid;
                  broadCast.insertedAt = widget.message.insertedAt;
                  broadCast.ownerUuid = widget.message.uuid;
                  broadCast.status = "sent";
                  broadCast.hasReplied = widget.message.hasReplied;
                  broadCast.repliedMessageUuid =
                      widget.message.repliedMessageUuid;
                  broadCast.replyIndex = widget.message.replyIndex;
                  broadCast.senderUuid = userUuid;
                  broadCast.uuid = widget.message.uuid;
                  broadCast.listUserName = globalName;
                  broadCast.clientUuid = widget.message.clientUuid;
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BroadCastChat(
                              broadcastData: broadCastForwardList[i],
                              isForwarded: true,
                              forwardedMessage: broadCast)));
                }
              }
              if (oneToOneForwardList != null &&
                  oneToOneForwardList.isNotEmpty) {
                for (int i = 0; i < oneToOneForwardList.length; i++) {
                  clearOneToOneData(oneToOneForwardList[i]);
                }
              }

              if (groupForwardList != null && groupForwardList.isNotEmpty) {
                for (int j = 0; j < groupForwardList.length; j++) {
                  clearGroupData(groupForwardList[j]);
                }
              }

              if (broadCastForwardList != null &&
                  broadCastForwardList.isNotEmpty) {
                for (int k = 0; k < broadCastForwardList.length; k++) {
                  clearBroadCastData(broadCastForwardList[k]);
                }
              }
            },
            child: Icon(Icons.send, color: Colors.white),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              backgroundColor: appColor,
            )),
      ),
    );
  }

  void clearOneToOneData(ContactData item) {
    item.isSelected = false;
  }

  void clearGroupData(GroupChatData item) {
    item.isSelected = false;
  }

  void clearBroadCastData(BroadcastList item) {
    item.isSelected = false;
  }

  void addOrRemoveItem(ContactData item) {
    setState(() {
      if (oneToOneForwardList.contains(item)) {
        oneToOneForwardList.remove(item);
        item.isSelected = false;
      } else {
        oneToOneForwardList.add(item);
        item.isSelected = true;
      }
    });
  }

  void addOrRemoveItemGroup(GroupChatData item) {
    setState(() {
      if (groupForwardList.contains(item)) {
        groupForwardList.remove(item);
        item.isSelected = false;
      } else {
        groupForwardList.add(item);
        item.isSelected = true;
      }
    });
  }

  void addOrRemoveItemBroadCast(BroadcastList item) {
    setState(() {
      if (broadCastForwardList.contains(item)) {
        broadCastForwardList.remove(item);
        item.isSelected = false;
      } else {
        broadCastForwardList.add(item);
        item.isSelected = true;
      }
    });
  }

  void searchResultData(String query) {
    List<ContactData> tempContactData = [];
    if (query.isEmpty) {
      tempContactData = contactsDetailsInfo;
    } else {
      tempContactData = contactsDetailsInfo
          .where(
              (user) => user.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      setState(() {
        searchResultList = tempContactData;
      });
    }
  }
}
