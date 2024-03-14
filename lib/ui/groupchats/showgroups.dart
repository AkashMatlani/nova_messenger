import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nova/models/group_chat_data.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/ui/groupchats/create_new_group.dart';
import 'package:nova/ui/groupchats/group_chat.dart';
import 'package:nova/utils/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:nova/viewmodels/chat_viewmodel.dart';
import 'package:nova/viewmodels/chat_list_viewmodel.dart';

class ShowGroups extends StatefulWidget {
  @override
  _ShowGroupsState createState() => _ShowGroupsState();
}

class _ShowGroupsState extends State<ShowGroups> {
  bool _showLoader = true;
  HttpService _api = serviceLocator<HttpService>();
  List<GroupChatData> groupData = [];
  bool _onlineStatus = true;

  @override
  void initState() {
    super.initState();
    getGroups();
  }

  void getGroups() async {
    if (await checkInternet()) {
      List<GroupChatData> response = await _api.getGroups();
      if (response != null) {
        if (mounted) {
          setState(() {
            groupData = response;
            _showLoader = false;
          });
        }
      }
      _onlineStatus = true;
    } else {
      setState(() {
        _showLoader = false;
      });
      _onlineStatus = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Container(
        child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: LayoutBuilder(builder: (context, constraint) {
              return _onlineStatus
                  ? Column(
                      children: <Widget>[
                        _showLoader == true
                            ? Center(child: loader())
                            : _designPage(context),
                      ],
                    )
                  : Container(
                      child: errorMessage("No Internet Connection Available"),
                    );
            })),
      ),
    );
  }

  Widget _designPage(context) {
    if (groupData.isNotEmpty) {
      return Expanded(
        child: ListView.builder(
            shrinkWrap: true,
            reverse: false,
            itemCount: groupData.length,
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              String title = groupData[index].name;
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GroupChat(
                          groupChatData: groupData[index],
                        )),
                  );
                },
                child: Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  child: Column(
                    children: [
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 15, bottom: 15),
                          child: Row(
                            children: [
                              CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.grey[200],
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    child: SvgPicture.asset(
                                      'assets/images/usersgray.svg',
                                      fit: BoxFit.fill,
                                    ),
                                  )),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      //  width: 150,
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              .backgroundColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    SizedBox(
                                      child: Text(
                                        "Reply of anyone in this group",
                                        style: TextStyle(
                                          color:
                                          Color.fromRGBO(129, 136, 152, 1),
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "12:04",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      .backgroundColor,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () async {
                        if (groupData[index].user.uuid == userUuid) {
                          showDeleteGroupChat(
                              groupData[index].uuid, context, index);
                        } else {
                          showLeaveGroupChat(
                              groupData[index].uuid, context, index);
                        }
                      },
                    ),
                  ],
                ),
              );
            }),
      );
    } else {
      return Expanded(
          child: Container(
        alignment: Alignment.center,
        height: SizeConfig.screenHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Material(
                type: MaterialType.transparency,
                elevation: 1.0,
                child: Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 50),
                    child: Image.asset('assets/images/push.png',
                        height: 120, fit: BoxFit.fill))),
            Text(
              "No groups here.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16, // light
                fontStyle: FontStyle.normal, // italic
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: Text(
                  'You should use group list to message \nmultiple people at once',
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                )),
            SizedBox(
              height: 30,
            ),
            Text(
              'Only contact with your number in their \naddress book will receive your broadcast\nmessage ',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            Container(
              width: 300,
              margin: EdgeInsets.all(25),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: appColor, // Background color
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewGroup()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Create new group',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ));
    }
  }

  showDeleteGroupChat(String uuid, BuildContext context, int index) async {
    containerForSheet<String>(
        context: context,
        child: CupertinoActionSheet(
          title: Text(
            "Are you sure you want to delete this group?",
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text(
                "Yes",
                style: TextStyle(
                    color: appColor, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                HttpService _api = serviceLocator<HttpService>();
                var response = await _api.deleteGroup(uuid);
                if (response != null) {
                  getGroups();
                  Navigator.of(context, rootNavigator: true).pop("Discard");
                } else {
                  Commons.novaFlushBarError(
                      context, "Error deleting group. Please try again.");
                  Navigator.of(context, rootNavigator: true).pop("Discard");
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

  showLeaveGroupChat(String uuid, BuildContext context, int index) async {
    containerForSheet<String>(
        context: context,
        child: CupertinoActionSheet(
          title: Text(
            "Are you sure you want to leave this group?",
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text(
                "Yes",
                style: TextStyle(
                    color: appColor, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                HttpService _api = serviceLocator<HttpService>();
                if (await _api.leaveGroup(uuid) != null) {
                  serviceLocator<ChatListViewModel>().deleteGroupChat(uuid);
                  serviceLocator<ChatViewModel>().deleteGroup(uuid);
                  groupData.removeWhere(
                      (element) => element.uuid == groupData[index].uuid);
                  setState(() {});
                  Navigator.of(context, rootNavigator: true).pop("Discard");
                } else {
                  Navigator.of(context).pop();
                  Commons.novaFlushBarError(context,
                      "There was an error when trying to leave group. Please try again.");
                  Navigator.of(context, rootNavigator: true).pop("Discard");
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
}
