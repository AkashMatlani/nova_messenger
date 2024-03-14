import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:nova/models/contact_data.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/services/services_locator.dart';

class BlockContacts extends StatefulWidget {
  @override
  BlockContactsState createState() {
    return new BlockContactsState();
  }
}

class BlockContactsState extends State<BlockContacts> {
  bool isLoading = true;
  List<ContactData> contactsDetailsInfo = [];
  HttpService _api = serviceLocator<HttpService>();

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      getContacts();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            "Blocked",
            style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 20),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: appColor,
              )),
        ),
        body: isLoading == true
            ? Center(
                child: loader(),
              )
            : _body());
  }

  Widget _body() {
    return Container(
        child: SingleChildScrollView(
      child: Column(
        children: <Widget>[
          ListView.builder(
            itemCount: contactsDetailsInfo.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, i) {
              return Container(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      onTap: () {
                        openMenu(context, contactsDetailsInfo[i]);
                      },
                      leading: new Stack(
                        children: <Widget>[
                          InkWell(
                            onLongPress: () {},
                            child: CircleAvatar(
                              foregroundColor: Theme.of(context).primaryColor,
                              backgroundColor: Colors.grey,
                              backgroundImage: new NetworkImage(
                                noImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text(
                            contactsDetailsInfo[i].name,
                            style: new TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 0.5, color: Colors.grey),
                  ],
                ),
              );
            },
          ),
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  'Blocked contacts will no longer be able to call you or send you messages',
                  style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                      color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  openMenu(BuildContext context, ContactData data) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "Unblock",
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontFamily: "DMSans-Regular"),
            ),
            onPressed: () {
              unBlockCall(data.uuid);
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.black, fontFamily: "DMSans-Regular"),
          ),
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ),
    );
  }

  void containerForSheet<T>({BuildContext context, Widget child}) {
    showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {});
  }

  unBlockCall(id) {
    setState(() {
      isLoading = true;
      getContacts();
      globalSocketService.push(event: "unblock", payload: {"to": id});
    });
  }
}
