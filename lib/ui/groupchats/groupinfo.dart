import 'package:flutter_svg/flutter_svg.dart';
import 'package:nova/models/contact_data.dart';
import 'package:nova/models/getgroupdata_response.dart';
import 'package:nova/models/group_chat_data.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/ui/groupchats/addgroup_participants.dart';
import 'package:nova/ui/groupchats/edit_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:nova/ui/widgets/iconsvgtext.dart';
import 'package:nova/viewmodels/chat_list_viewmodel.dart';

class GroupInfo extends StatefulWidget {
  final GroupChatData groupData;

  GroupInfo(this.groupData);

  @override
  GroupInfoState createState() {
    return GroupInfoState();
  }
}

class GroupInfoState extends State<GroupInfo> {
  bool isLoading = true;
  HttpService _api = serviceLocator<HttpService>();
  GetGroupDataResponse groupContactData = GetGroupDataResponse();
  GroupChatData groupData = GroupChatData();
  final GlobalKey<ScaffoldState> _scaffoldGroupKey = GlobalKey<ScaffoldState>();
  GetGroupDataResponse groupContactDataResponse = GetGroupDataResponse();
  List<ContactData> contactsDetailsInfo = [];
  List<ContactData> searchInfoResult = [];
  List<String> userIdsList = [];
  bool isSearching = false;
  bool isLoadingContacts = true;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      getGroupContactsData();
      getContacts();
    });
    super.initState();
  }

  void getGroupContactsData() async {
    setState(() {
      isLoading = true;
    });
    groupContactDataResponse =
        await _api.getContactsGroupData(widget.groupData.uuid);
    if (groupContactDataResponse != null) {
      if (mounted) {
        setState(() {
          groupData.uuid = groupContactDataResponse.uuid;
          groupData.avatar = groupContactDataResponse.avatar;
          groupData.name = groupContactDataResponse.name;
          groupContactData = groupContactDataResponse;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldGroupKey,
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
        Expanded(
          child: Container(
            color: Theme.of(context).brightness !=
                Brightness.dark
                ? Colors.grey[200]
                : novaDarkModeBlue,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Material(
                  color: Theme.of(context).brightness !=
                      Brightness.dark
                      ? Colors.grey[200]
                      : novaDarkModeBlue,
                  child: Container(
                    margin:
                        EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 8),
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
                          child: groupContactDataResponse != null
                              ? Text(
                                  groupData.name,
                                  style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 4,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "DMSans-Regular",
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                )
                              : Text(
                                  widget.groupData.name,
                                  style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 4,
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
                          height:
                              widget.groupData.user.uuid == userUuid ? 10 : 0,
                        ),
                        widget.groupData.user.uuid == userUuid
                            ? Divider(
                                thickness: 1,
                              )
                            : Container(),
                        Container(
                          height:
                              widget.groupData.user.uuid == userUuid ? 10 : 0,
                        ),
                        widget.groupData.user.uuid == userUuid
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditGroup(
                                            groupContactData,
                                            groupData,
                                            refresh,
                                          ),
                                        ),
                                      ).then((value) => getGroupContactsData());
                                    },
                                    child: IconSvGWithText(
                                      path: "assets/images/edit_icon.svg",
                                      text: 'Edit group',
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddGroupParticipants(groupData),
                                        ),
                                      ).then((value) => getGroupContactsData());
                                    },
                                    child: IconSvGWithText(
                                      path: "assets/images/person_add.svg",
                                      text: 'Add participants',
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      margin: EdgeInsets.only(left: 16, right: 16),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).brightness !=
                            Brightness.dark
                            ? Colors.white
                            : Colors.grey[800],
                      ),
                      child: groupContactData.users != null
                          ? ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: groupContactData.users.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () {},
                                  child: Column(
                                    children: <Widget>[
                                      ListTile(
                                        onTap: () {},
                                        leading: Stack(
                                          children: <Widget>[
                                            (groupContactData
                                                        .users[index].avatar !=
                                                    "")
                                                ? CircleAvatar(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    backgroundImage: NetworkImage(
                                                        groupContactData
                                                                .users[index]
                                                                .avatar ??
                                                            profilePlaceHolder),
                                                  )
                                                : CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey[400],
                                                    child: Image.asset(
                                                      "assets/images/user.png",
                                                      height: 25,
                                                      color: Colors.white,
                                                    )),
                                          ],
                                        ),
                                        title: Text(
                                          groupContactData.users[index].name ??
                                              "Unknown",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.all(30),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'No group contacts found. Please check your connection..',
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.safeBlockHorizontal * 3,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  refresh() {
    setState(() {
      getGroupContactsData();
    });
  }

  Widget customAppBar() {
    return Container(
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
                      backgroundImage: groupContactDataResponse != null
                          ? groupData.avatar != ""
                              ? NetworkImage(groupData.avatar ?? noImage)
                              : NetworkImage(noImage)
                          : NetworkImage(widget.groupData.avatar ?? noImage),
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
                    if (chat.group != null) {
                      if (chat.group.uuid == widget.groupData.uuid)
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
}
