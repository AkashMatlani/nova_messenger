import 'package:flutter_svg/flutter_svg.dart';
import 'package:nova/models/admin_contact.dart';
import 'package:nova/models/broadcast_list.dart';
import 'package:nova/models/contact_data.dart';
import 'package:nova/models/get_list_response.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/ui/broadcasts/addlist_participants.dart';
import 'package:nova/ui/broadcasts/edit_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nova/ui/chat/chat.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:nova/ui/widgets/iconsvgtext.dart';
import 'package:nova/viewmodels/chat_list_viewmodel.dart';

class BroadcastInfo extends StatefulWidget {
  final BroadcastList listData;

  BroadcastInfo({this.listData});

  @override
  BroadcastInfoState createState() {
    return BroadcastInfoState();
  }
}

class BroadcastInfoState extends State<BroadcastInfo> {
  bool isLoading = true;
  HttpService _api = serviceLocator<HttpService>();
  GetListDataResponse broadcastContactData = GetListDataResponse();
  BroadcastList broadcastData = BroadcastList();
  final GlobalKey<ScaffoldState> _scaffoldListKey = GlobalKey<ScaffoldState>();
  List<ContactData> contactsDetailsInfo = [];
  List<ContactData> searchInfoResult = [];
  List<String> userIdsList = [];
  List<ContactData> adminContacts = [];
  AdminContacts adminContactsMain;

  bool isSearching = false;
  bool isLoadingContacts = true;
  TextEditingController controller = TextEditingController();
  bool showAdmins = false;
  List<String> listAdminUUIDs = [];

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      getListContactsData();
      getContacts();
      getAdminContacts();
    });
    super.initState();
  }

  void getListContactsData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    GetListDataResponse broadcastContactDataResponse = GetListDataResponse();
    broadcastContactDataResponse =
        await _api.getContactsListData(widget.listData.uuid);
    if (broadcastContactDataResponse != null) {
      if (mounted) {
        setState(() {
          broadcastData.uuid = broadcastContactDataResponse.uuid;
          broadcastData.avatar = broadcastContactDataResponse.avatar;
          broadcastData.name = broadcastContactDataResponse.name;
          broadcastContactData = broadcastContactDataResponse;
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void getContacts() async {
    List<ContactData> contactsResponse = [];
    contactsResponse = await _api.getContacts();
    if (contactsResponse != null) {
      if (mounted) {
        setState(() {
          contactsDetailsInfo = contactsResponse;
          isLoadingContacts = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoadingContacts = false;
        });
      }
    }
  }

  void getAdminContacts() async {
    AdminContacts contactsAdminResponse =
        await _api.getContactsAdmin(widget.listData.uuid);
    if (contactsAdminResponse != null) {
      if (mounted) {
        setState(() {
          adminContactsMain = contactsAdminResponse;
          adminContacts = contactsAdminResponse.users;
          showAdmins = adminContactsMain.canContactAdmins;
          contactsAdminResponse.users.forEach((user) {
            listAdminUUIDs.add(user.uuid);
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldListKey,
        backgroundColor: Theme.of(context).brightness !=
            Brightness.dark
            ? Colors.grey[200]
            : novaDarkModeBlue,
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: appColor,
                ),
              )
            : body());
  }

  Widget body() {
    return Column(
      children: <Widget>[
        customAppBar(),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Material(
              color: Theme.of(context).brightness !=
                  Brightness.dark
                  ? Colors.grey[200]
                  : novaDarkModeBlue,
              child: Container(
                margin: EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 8),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).brightness !=
                      Brightness.dark
                      ? Colors.white
                      : Colors.grey[800],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: broadcastContactData != null
                          ? Text(
                              broadcastData.name,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 4,
                                fontWeight: FontWeight.bold,
                                fontFamily: "DMSans-Regular",
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            )
                          : Text(
                              widget.listData.name,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 4,
                                fontWeight: FontWeight.bold,
                                fontFamily: "DMSans-Regular",
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                    ),
                    Container(
                      height: listAdminUUIDs.contains(userUuid) ? 10 : 0,
                    ),
                    listAdminUUIDs.contains(userUuid)
                        ? Divider(
                            thickness: 1,
                          )
                        : Container(),
                    Container(
                      height: listAdminUUIDs.contains(userUuid) ? 10 : 0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        listAdminUUIDs.contains(userUuid)
                            ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditList(broadcastData, refresh()),
                              ),
                            ).then((value) => getListContactsData());
                          },
                          child: IconSvGWithText(
                            path: "assets/images/edit_icon.svg",
                            text: 'Edit list',
                          ),
                        )
                            : Container(),
                        SizedBox(width: 16),
                        listAdminUUIDs.contains(userUuid)
                            ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddListParticipants(broadcastData),
                              ),
                            ).then((value) => getListContactsData());
                          },
                          child: IconSvGWithText(
                            path: "assets/images/person_add.svg",
                            text: 'Add participants',
                          ),
                        )
                            : Container(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
                margin: EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 0),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).brightness !=
                      Brightness.dark
                      ? Colors.white
                      : Colors.grey[800],
                ),
                child: Column(
                  children: [
                    showAdmins
                        ? ListTile(
                            title: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    'Tap admins name to start chat',
                                    style: TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal * 3.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        : Container(),
                    showAdmins ? adminUsers() : Container(),
                  ],
                )),
          ],
        ),
      ],
    );
  }

  Widget adminUsers() {
    return SingleChildScrollView(
        child: adminContacts != null
            ? ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: adminContacts.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Divider(
                              height: 1,
                            ),
                            ListTile(
                              onTap: () {
                                var existingUser =
                                    contactsGlobalData.firstWhere(
                                        (element) =>
                                            element.uuid ==
                                            adminContacts[index].uuid,
                                        orElse: () => null);
                                existingUser != null
                                    ? Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Chat(
                                                  peerData: existingUser,
                                                )),
                                      )
                                    : Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Chat(
                                                  peerData:
                                                      adminContacts[index],
                                                )));
                              },
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    " " + adminContacts[index].name ?? "",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                },
              )
            : Container());
  }

  Widget customAppBar() {
    return Container(
      color: Theme.of(context).brightness !=
          Brightness.dark
          ? Colors.grey[200]
          : novaDarkModeBlue,
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
                color: Theme.of(context).brightness !=
                    Brightness.dark
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
                      backgroundImage: broadcastContactData != null
                          ? broadcastData.avatar != ""
                              ? NetworkImage(broadcastData.avatar ?? noImage)
                              : NetworkImage(noImage)
                          : NetworkImage(widget.listData.avatar ?? noImage),
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
                  inChatUuid = "";
                  Navigator.pop(context);
                  serviceLocator<ChatListViewModel>()
                      .mainChatList
                      .forEach((chat) {
                    if (chat.list != null) {
                      if (chat.list.uuid == widget.listData.uuid)
                        chat.unreadCount = 0;
                      serviceLocator<ChatListViewModel>().notifyListeners();
                    }
                  });
                }),
          ),
        ],
      ),
    );
  }

  refresh() {}
}
