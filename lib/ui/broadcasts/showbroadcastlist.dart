import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nova/models/broadcast_list.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/utils/commons.dart';
import 'package:nova/viewmodels/chat_list_viewmodel.dart';
import 'package:nova/viewmodels/chat_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nova/ui/broadcasts/broadcast_chat.dart';
import 'package:nova/ui/broadcasts/newbroadcastlist.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';

class ShowBroadcastList extends StatefulWidget {
  @override
  _ShowBroadcastListState createState() => _ShowBroadcastListState();
}

class _ShowBroadcastListState extends State<ShowBroadcastList> {
  bool _showLoader = true;
  bool _onlineStatus = true;
  HttpService _api = serviceLocator<HttpService>();
  List<BroadcastList> broadcastData = [];

  @override
  void initState() {
    super.initState();
    getBroadcastLists();
  }

  void getBroadcastLists() async {
    if (await checkInternet()) {
      List<BroadcastList> response = await _api.getBroadcastLists();
      if (response != null) {
        if (mounted) {
          setState(() {
            broadcastData = response;
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
        color: Theme.of(context).scaffoldBackgroundColor,
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
                            : _broadcasts(context),
                      ],
                    )
                  : Container(
                      child: errorMessage("No Internet Connection Available"),
                    );
            })),
      ),
    );
  }

  Widget _broadcasts(context) {
    if (broadcastData.isNotEmpty) {
      return Expanded(
        child: ListView.builder(
            shrinkWrap: true,
            reverse: false,
            itemCount: broadcastData.length,
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              String title = broadcastData[index].name;
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BroadCastChat(
                              broadcastData: broadcastData[index],
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
                                      'assets/images/sirengray.svg',
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
                                        "Reply of anyone in this broadcast group",
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
                        if (broadcastData[index].user.uuid == userUuid) {
                          showDeleteBroadcastChat(
                              broadcastData[index].uuid, context, index);
                        } else {
                          showBroadcastLeaveChat(
                              broadcastData[index].uuid, context, index);
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
                    child: Image.asset('assets/images/record.png',
                        height: 120, fit: BoxFit.fill))),
            Text(
              "Nothing here.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16, // light
                fontStyle: FontStyle.normal, // italic
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: Text(
                  'You should use a broadcast list to message \nmultiple people at once',
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                )),
            SizedBox(
              height: 30,
            ),
            Text(
              'Only contacts with your number in their \naddress book will receive your broadcast\nmessage ',
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
                    MaterialPageRoute(builder: (context) => NewBroadcastList()),
                  ).then((_) => setState(() {
                        getBroadcastLists();
                      }));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Create new broadcast',
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

  showDeleteBroadcastChat(String uuid, BuildContext context, int index) async {
    containerForSheet<String>(
        context: context,
        child: CupertinoActionSheet(
          title: Text(
            "Are you sure you want to delete this broadcast list?",
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
                var response =
                    await _api.deleteBroadCastList(broadcastData[index].uuid);
                if (response != null) {
                  getBroadcastLists();
                  Navigator.of(context, rootNavigator: true).pop("Discard");
                } else {
                  Commons.novaFlushBarError(
                      context, "Error deleting list. Please try again.");
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

  showBroadcastLeaveChat(String uuid, BuildContext context, int index) async {
    containerForSheet<String>(
        context: context,
        child: CupertinoActionSheet(
          title: Text(
            "Are you sure you want to leave this broadcast list?",
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
                if (await _api.leaveBroadcastList(uuid) != null) {
                  serviceLocator<ChatListViewModel>().deleteListChat(uuid);
                  serviceLocator<ChatViewModel>().deleteBroadcastList(uuid);
                  broadcastData.removeWhere(
                      (element) => element.uuid == broadcastData[index].uuid);
                  setState(() {});
                  Navigator.of(context, rootNavigator: true).pop("Discard");
                } else {
                  Commons.novaFlushBarError(context,
                      "There was an error when trying to leave broadcast list. Please try again.");
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
