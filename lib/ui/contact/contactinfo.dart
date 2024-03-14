import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nova/models/contact_data.dart';
import 'package:nova/ui/chat/chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nova/ui/mediascreen.dart';
import 'package:nova/ui/viewImages.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';

// ignore: must_be_immutable
class ContactInfo extends StatefulWidget {
  ContactData peerData;
  var imageMedia;
  var videoMedia;
  var docsMedia;
  bool chat;

  ContactInfo(
      {this.peerData,
      this.imageMedia,
      this.videoMedia,
      this.docsMedia,
      this.chat});

  @override
  ContactInfoState createState() {
    return ContactInfoState();
  }
}

class ContactInfoState extends State<ContactInfo> {
  String name = '';
  String image = '';
  String lastOnline;

  String userId = '';
  List blocksId = [];

  //Share Contact
  var newPersonId = [];
  var newPersonName = [];
  var newPersonImage = [];

  String token = '';

  var isBlocked = false;

  @override
  void initState() {
    isBlocked = widget.peerData.statusContact == "blocked";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).brightness != Brightness.dark
            ? Colors.grey[200]
            : novaDarkModeBlue,
        body: body());
  }

  Widget body() {
    return Column(children: [
      Container(
        height: 180,
        child: Stack(
          children: <Widget>[
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 134,
                  child: SvgPicture.asset(
                    'assets/images/profilebanner.svg',
                    fit: BoxFit.fill,
                  ),
                ),
                Container(
                  height: 40,
                  color: Theme.of(context).brightness != Brightness.dark
                      ? Colors.grey[200]
                      : novaDarkModeBlue,
                ),
              ],
            ),
            Positioned(
                top: 94,
                left: 16,
                child: SizedBox(
                  height: 80,
                  width: 80,
                  child: Stack(
                    clipBehavior: Clip.none,
                    fit: StackFit.expand,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: widget.peerData.avatar != null
                            ? widget.peerData.avatar != ""
                                ? NetworkImage(
                                    widget.peerData.avatar ?? noImage)
                                : NetworkImage(noImage)
                            : NetworkImage(widget.peerData.avatar ?? noImage),
                        radius: 20,
                      ),
                    ],
                  ),
                )),
            Positioned(
              top: 40.0,
              child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ),
          ],
        ),
      ),
      Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
          child: Card(
            color: Theme.of(context).brightness == Brightness.dark
                ? novaDark
                : Theme.of(context).scaffoldBackgroundColor,
            child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.peerData.name,
                          style: TextStyle(
                              fontSize: SizeConfig.blockSizeHorizontal * 6,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans-Regular",
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black),
                        ),
                        Flexible(fit: FlexFit.tight, child: SizedBox()),
                        Text(
                          widget.peerData.mobile,
                          style: TextStyle(
                              color: Color.fromRGBO(129, 136, 152, 1)),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                        height: 1,
                        child: Container(
                            color: Color.fromARGB(242, 242, 242, 242))),
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 0, right: 0, top: 30, bottom: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Chat(
                                              peerData: widget.peerData,
                                            )),
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/images/contactchat.svg",
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      height: 30,
                                    ),
                                    Text(
                                      "Message",
                                      style: TextStyle(
                                        color: Color.fromRGBO(131, 131, 136, 1),
                                      ),
                                    )
                                  ],
                                )),
                            InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Chat(
                                              searchActive: true,
                                              peerData: widget.peerData,
                                            )),
                                  ).then((value) => Navigator.pop(context));
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/images/contactsearch.svg",
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      height: 30,
                                    ),
                                    Text(
                                      "Search",
                                      style: TextStyle(
                                        color: Color.fromRGBO(131, 131, 136, 1),
                                      ),
                                    )
                                  ],
                                ))
                          ],
                        )),
                  ],
                )),
          )),
      Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
          child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MediaScreen(
                            imageMedia: widget.imageMedia,
                            videoMedia: widget.videoMedia,
                            docsMedia: widget.docsMedia,
                            peerData: widget.peerData,
                          )),
                );
              },
              child: Card(
                color: Theme.of(context).brightness == Brightness.dark
                    ? novaDark
                    : Theme.of(context).scaffoldBackgroundColor,
                child: Padding(
                    padding: const EdgeInsets.only(
                        left: 15, right: 15, top: 20, bottom: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                'Media, Links and Docs',
                                style: TextStyle(
                                  color: Color.fromRGBO(131, 131, 136, 1),
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            Text(
                                '${widget.imageMedia.length + widget.videoMedia.length + widget.docsMedia.length}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color.fromRGBO(131, 131, 136, 1),
                                )),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? appColor
                                  : Colors.black,
                              size: 20,
                            ),
                          ],
                        ),
                        myImages()
                      ],
                    )),
              ))),
      Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
          child: InkWell(
              onTap: () {
                openReportMenu(context);
              },
              child: Card(
                color: Theme.of(context).brightness == Brightness.dark
                    ? novaDark
                    : Theme.of(context).scaffoldBackgroundColor,
                child: Padding(
                    padding: const EdgeInsets.only(
                        left: 0, right: 0, top: 3, bottom: 3),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const ListTile(
                          minLeadingWidth: 10,
                          iconColor: Colors.red,
                          textColor: Colors.red,
                          leading: Icon(
                            Icons.thumb_down_alt_outlined,
                            size: 25,
                          ),
                          title: Text(
                            'Report Contact',
                            style: TextStyle(
                                fontSize: 14, fontFamily: 'DMSans-Regular'),
                          ),
                        ),
                      ],
                    )),
              ))),
    ]);
  }

  Widget myImages() {
    if (widget.imageMedia.length > 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.all(0),
          itemCount: widget.imageMedia.length.clamp(1, 3),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 200 / 200,
          ),
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.all(5.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => ViewImages(
                        peerData: widget.peerData,
                        images: widget.imageMedia,
                        number: index,
                      ),
                    ),
                  );
                },
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CupertinoActivityIndicator(),
                    width: 35.0,
                    height: 35.0,
                    padding: EdgeInsets.all(10.0),
                  ),
                  errorWidget: (context, url, error) => Material(
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),
                  imageUrl: widget.imageMedia[index],
                  width: 35.0,
                  height: 35.0,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 20),
          child: Center(child: Text("No Images")));
    }
  }

  openMenu(BuildContext context) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "Block",
              style: TextStyle(
                  color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop("Discard");
              globalSocketService
                  .push(event: "block", payload: {"to": widget.peerData.uuid});
              globalSocketService.push(
                  event: "load_messages",
                  payload: {"to": widget.peerData.uuid});
              setState(() {
                isBlocked = true;
              });
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop("Discard");
          },
        ),
      ),
    );
  }

  openUnblockMenu(BuildContext context) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "Unblock",
              style: TextStyle(
                  color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop("Discard");
              globalSocketService.push(
                  event: "unblock", payload: {"to": widget.peerData.uuid});
              setState(() {
                isBlocked = false;
              });
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop("Discard");
          },
        ),
      ),
    );
  }

  openReportMenu(BuildContext context) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "Report",
              style: TextStyle(
                  color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop("Discard");
              _displayTextInputDialog(context);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop("Discard");
          },
        ),
      ),
    );
  }

  String codeDialog;
  String valueText;
  TextEditingController _textFieldController = TextEditingController();

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Report user: Please give us more information.'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Text Field in dialog"),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  onPrimary: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                child: Text('CANCEL'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    codeDialog = valueText;
                    globalSocketService.push(
                      event: "report",
                      payload: {
                        "to": widget.peerData.uuid,
                        "report_msg": codeDialog
                      },
                    );
                    Navigator.pop(context);
                  });
                },
                child: Text('OK'),
              ),
            ],
          );
        });
  }

  void containerForSheet<T>({BuildContext context, Widget child}) {
    showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {});
  }

  shareContact() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState1) {
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  height: SizeConfig.screenHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0),
                          ),
                        ),
                        height: 60,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Cancel",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(color: appColor),
                                  )),
                              Text(
                                "Share Contact",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    color: Colors.black),
                              ),
                              newPersonId.length > 0
                                  ? InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Text(
                                          "Share",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: appColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ))
                                  : Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Text(
                                        "Share",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          });
        });
  }

  Widget shareItemWidget(lists, index, setState1) {
    return mobileContacts.contains(lists[index]["mobile"]) &&
            userId != lists[index]["userId"]
        ? Row(
            children: [
              Expanded(
                child: Column(
                  children: <Widget>[
                    Divider(
                      height: 1,
                    ),
                    ListTile(
                      onTap: () {},
                      leading: Stack(
                        children: <Widget>[
                          (lists[index]["img"] != null &&
                                  lists[index]["img"].length > 0)
                              ? CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  backgroundImage:
                                      NetworkImage(lists[index]["img"]),
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                  child: Text(
                                    "",
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  )),
                        ],
                      ),
                      title: Text(
                        getContactName(lists[index]["mobile"]),
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(fontSize: 15),
                      ),
                      subtitle: Container(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Row(
                          children: [Text(lists[index]["mobile"])],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              newPersonId.contains(lists[index]["userId"])
                  ? InkWell(
                      onTap: () {},
                      child: IconButton(
                        onPressed: () {
                          setState1(() {
                            newPersonId.remove(lists[index]["userId"]);
                            newPersonName.remove(lists[index]["name"]);
                            newPersonImage.remove(lists[index]["img"]);
                          });
                        },
                        icon: Icon(
                          Icons.check_circle,
                          color: appColor,
                          size: 28,
                        ),
                      ))
                  : IconButton(
                      onPressed: () {
                        setState1(() {
                          newPersonId.add(lists[index]["userId"]);
                          newPersonName.add(lists[index]["name"]);
                          newPersonImage.add(lists[index]["img"]);
                        });
                      },
                      icon: Icon(
                        Icons.radio_button_off_outlined,
                        color: Colors.grey,
                        size: 28,
                      ),
                    ),
              Container(
                width: 20,
              )
            ],
          )
        : Container();
  }
}
