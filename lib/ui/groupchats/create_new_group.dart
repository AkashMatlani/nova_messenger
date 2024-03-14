import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/models/contact_data.dart';
import 'package:nova/models/group_chat_data.dart';
import 'package:nova/models/create_group.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/ui/groupchats/group_chat.dart';
import 'package:nova/utils/commons.dart';
import 'package:flutter/material.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:nova/viewmodels/chat_viewmodel.dart';

import '../widgets/customtoasterror.dart';

class NewGroup extends StatefulWidget {
  NewGroup();

  @override
  NewGroupState createState() {
    return NewGroupState();
  }
}

class NewGroupState extends State<NewGroup> {
  TextEditingController controller = TextEditingController();
  TextEditingController titleController = TextEditingController();
  List<ContactData> contactsDetailsInfo = [];
  List<String> userIdsList = [];
  List<ContactData> searchInfoResult = [];
  bool isSearching = false;
  List<ContactData> selectedUsers = [];
  FocusNode focusNode = FocusNode();
  String hintText = 'Search';

  @override
  void initState() {
    contactsDetailsInfo = contactsGlobalData;
    super.initState();
    inHome = false;
    print("InHome = " + inHome.toString());
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        hintText = '';
      } else {
        hintText = 'Search';
      }
      setState(() {});
    });
  }

  void updateSelectedUsers() {
    selectedUsers = [];
    for (ContactData contact in contactsDetailsInfo) {
      if (userIdsList.contains(contact.uuid)) {
        selectedUsers.add(contact);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).brightness == Brightness.dark
              ? novaDarkModeBlue
              : Colors.white,
          height: 100,
          elevation: 0,
          padding: EdgeInsets.all(0),
          child: Container(
            width: 300,
            margin: EdgeInsets.only(left: 40, right: 40, top: 5, bottom: 5),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: appColor, // Background color
              ),
              onPressed: () {
                if (userIdsList.length > 0) {
                  _showCreateGroupModal(context);
                } else {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    barrierColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return Dialog(
                        elevation: 0,
                        backgroundColor: Colors.white.withOpacity(0),
                        child: CustomToastError(
                          message1: 'Not enough participants',
                          message2: "At least 1 contact must be selected",
                        ),
                      );
                    },
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: Text(
                  'Create Group',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          )),
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? novaDarkModeBlue
            : Color.fromRGBO(235, 235, 235, 1),
        elevation: 0,
        centerTitle: false,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "New Group",
              style: TextStyle(
                  fontSize: 17,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  fontFamily: 'DMSans-Medium',
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 5),
            Text(
              userIdsList.length > 0
                  ? userIdsList.length.toString() +
                      " of " +
                      contactsDetailsInfo.length.toString() +
                      " selected"
                  : "Select your participants",
              style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'DMSans-Regular',
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Color.fromRGBO(130, 136, 152, 1)
                      : Color.fromRGBO(23, 23, 54, 1)),
            ),
          ],
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_sharp,
              color: Theme.of(context).brightness == Brightness.dark
                  ? appColor
                  : Colors.black,
              size: 30,
            )),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Material(
          elevation: 1,
          child: Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? novaDarkModeBlue
                : Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: <Widget>[
                selectedContactsWidget(),
                Padding(
                    padding: const EdgeInsets.only(
                        right: 15, left: 15, bottom: 20, top: 20),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.green,
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
                            hintStyle: TextStyle(
                                color: Colors.grey[600], fontSize: 14),
                            hintText: "Search",
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
                contactsDetailsInfo.length > 0
                    ? Expanded(
                        child: !isSearching
                            ? contactsWidget()
                            : searchContactsWidget(),
                      )
                    : SizedBox(
                        height: 0,
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget selectedContactsWidget() {
    return selectedUsers.length != 0
        ? Container(
            // color: Color.fromRGBO(213, 215, 221, 0.56),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color.fromRGBO(213, 215, 221, 0.56), // Border color
                  width: 1.0, // Border width
                ),
              ),
            ),
            child: Container(
                color: Theme.of(context).brightness == Brightness.dark
                    ? novaDarkModeBlue
                    : Color.fromRGBO(245, 245, 245, 1),
                width: SizeConfig.screenWidth,
                child: Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 15),
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: selectedUsers.map((item) {
                            return Padding(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                child: Column(children: [
                                  Stack(
                                    children: <Widget>[
                                      (item.avatar != "")
                                          ? CircleAvatar(
                                              radius: 25.0,
                                              backgroundColor: Colors.grey,
                                              backgroundImage:
                                                  NetworkImage(item.avatar),
                                            )
                                          : CircleAvatar(
                                              radius: 25.0,
                                              backgroundColor: Colors.grey[300],
                                              backgroundImage:
                                                  NetworkImage(noImage),
                                              child: Text(
                                                "",
                                                style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                      Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  userIdsList.remove(item.uuid);
                                                  updateSelectedUsers();
                                                });
                                              },
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                child: SvgPicture.asset(
                                                  'assets/images/bclose.svg',
                                                  fit: BoxFit.fill,
                                                ),
                                              ))),
                                    ],
                                  ),
                                  Text(
                                      (item.name.length > 6)
                                          ? item.name.substring(0, 6) + '...'
                                          : item.name ?? "",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              Color.fromRGBO(129, 136, 152, 1)))
                                ])); // Replace this with your custom widget for each item
                          }).toList(),
                        )))))
        : Container();
  }

  Widget contactsWidget() {
    return contactsDetailsInfo != null
        ? SingleChildScrollView(
            child: ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: contactsDetailsInfo.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          onTap: () {
                            setState(() {
                              if (userIdsList
                                  .contains(contactsDetailsInfo[index].uuid)) {
                                userIdsList
                                    .remove(contactsDetailsInfo[index].uuid);
                              } else {
                                userIdsList
                                    .add(contactsDetailsInfo[index].uuid);
                              }
                              updateSelectedUsers();
                            });
                          },
                          leading: Stack(
                            children: <Widget>[
                              (contactsDetailsInfo[index].avatar != "")
                                  ? CircleAvatar(
                                      radius: 25.0,
                                      backgroundColor: Colors.grey,
                                      backgroundImage: NetworkImage(
                                          contactsDetailsInfo[index].avatar),
                                    )
                                  : CircleAvatar(
                                      radius: 25.0,
                                      backgroundColor: Colors.grey[300],
                                      backgroundImage: NetworkImage(noImage),
                                      child: Text(
                                        "",
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      )),
                              (userIdsList.contains(
                                      contactsDetailsInfo[index].uuid))
                                  ? Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 15,
                                        height: 15,
                                        child: SvgPicture.asset(
                                          'assets/images/bticked.svg',
                                          fit: BoxFit.fill,
                                        ),
                                      ))
                                  : SizedBox(height: 0, width: 0),
                            ],
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  contactsDetailsInfo[index].name ?? "",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 65,
                    width: 0,
                  )
                ],
              );
            },
          ))
        : Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'No contacts available.\n Please check your connection and retry.',
                    style: TextStyle(
                      fontSize: SizeConfig.safeBlockHorizontal * 3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Padding(
                        padding: const EdgeInsets.only(
                            right: 30, top: 0, left: 30, bottom: 10),
                        child: SizedBox(
                          height: SizeConfig.blockSizeVertical * 7,
                          width: SizeConfig.screenWidth,
                          child: CustomButton(
                              title: 'Retry',
                              fontSize: 16,
                              fontFamily: "DMSans-Regular",
                              fontWeight: FontWeight.bold,
                              textColor: appColorWhite,
                              color: appColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              onPressed: () {
                                getContacts();
                              }),
                        )),
                  ),
                ],
              ),
            ),
          );
  }

  Widget searchContactsWidget() {
    return SingleChildScrollView(
        child: searchInfoResult != null
            ? ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: searchInfoResult.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              onTap: () {
                                setState(() {
                                  if (userIdsList
                                      .contains(searchInfoResult[index].uuid)) {
                                    userIdsList
                                        .remove(searchInfoResult[index].uuid);
                                  } else {
                                    userIdsList
                                        .add(searchInfoResult[index].uuid);
                                  }
                                  updateSelectedUsers();
                                });
                              },
                              leading: Stack(
                                children: <Widget>[
                                  (searchInfoResult[index].avatar != "")
                                      ? CircleAvatar(
                                          radius: 25.0,
                                          backgroundColor: Colors.grey,
                                          backgroundImage: NetworkImage(
                                              searchInfoResult[index].avatar),
                                        )
                                      : CircleAvatar(
                                          radius: 25.0,
                                          backgroundColor: Colors.grey[300],
                                          backgroundImage:
                                              NetworkImage(noImage),
                                          child: Text(
                                            "",
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          )),
                                  (userIdsList.contains(
                                          searchInfoResult[index].uuid))
                                      ? Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            width: 15,
                                            height: 15,
                                            child: SvgPicture.asset(
                                              'assets/images/bticked.svg',
                                              fit: BoxFit.fill,
                                            ),
                                          ))
                                      : SizedBox(height: 0, width: 0),
                                ],
                              ),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Flexible(
                                    child: Text(
                                      searchInfoResult[index].name ?? "",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              )
            : Center(
                child: CircularProgressIndicator(
                  color: appColor,
                ),
              ));
  }

  void _showCreateGroupModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(48.0),
          topRight: Radius.circular(48.0),
        ),
      ),
      builder: (BuildContext context) {
        return KeyboardVisibilityBuilder(
          builder: (BuildContext context, bool isKeyboardVisible) {
            return SingleChildScrollView(
                reverse: true,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                  ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: bgGrey,
                  borderRadius: BorderRadius.circular(2.0),
                ),
                width: 80,
                height: 5,
              ),
              SizedBox(height: 20.0),
              Padding(
                  padding: EdgeInsets.only(left: 5, bottom: 5),
                  child: CustomText(
                    text: "Group name",
                    alignment: Alignment.centerLeft,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "DMSans-Regular",
                    color: novaDark,
                  )),
              SizedBox(height: 16.0),
              Padding(
                  padding: EdgeInsets.only(left: 5, bottom: 5),
                  child: CustomText(
                    text: "Name of your group",
                    alignment: Alignment.centerLeft,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    fontFamily: "DMSans-Regular",
                    color: novaDark,
                  )),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextField(
                  controller: titleController,
                  cursorColor: appColor,
                  decoration: InputDecoration(
                    labelText: 'Enter group name',
                    labelStyle: TextStyle(
                        color: Colors.black
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: appColor,
                        borderRadius: BorderRadius.circular(
                            6.0), // Adjust the radius as needed
                      ),
                      width: SizeConfig.screenWidth,
                      // Match the width of the screen
                      child: InkWell(
                        onTap: () async {
                          if (titleController.text.length > 0) {
                            Navigator.pop(context);
                            createGroups();
                          } else {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              barrierColor: Colors.transparent,
                              builder: (BuildContext context) {
                                return Dialog(
                                  elevation: 0,
                                  backgroundColor: Colors.white.withOpacity(0),
                                  child: CustomToastError(
                                    message1: 'Error',
                                    message2: "Please enter a group name",
                                  ),
                                );
                              },
                            );
                          }
                        },
                        child: Center(
                            child: Text('Create group',
                                style: TextStyle(color: Colors.white))),
                      )),
                  SizedBox(height: 30.0),
                ],
              ),
              SizedBox(height: 18.0),
            ],
          ),
        ));
          },
        );
      },
    );
  }

  void createGroups() async {
    HttpService _api = serviceLocator<HttpService>();
    CreateGroup group = CreateGroup();
    GroupData groupData = GroupData();
    groupData.name = titleController.text;
    group.contacts = userIdsList;
    group.group = groupData;
    GroupChatData groupResponse = await _api.createNewGroup(group);
    if (groupResponse != null) {
      Navigator.pop(context);
      groupGlobalData.add(groupResponse);
      globalSocketService.bindGroupChannel(groupResponse.uuid);
      serviceLocator<ChatViewModel>().groupMessages[groupResponse.uuid] = [];
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GroupChat(groupChatData: groupResponse)),
      );
    } else {
      Commons.novaFlushBarError(
          context, "Error creating group. Please try again.");
    }
  }

  onSearchTextChanged(String text) async {
    isSearching = true;
    searchInfoResult.clear();
    if (text.isEmpty) {
      setState(() {
        isSearching = false;
      });
      return;
    }
    contactsDetailsInfo.forEach((userDetail) {
      if (userDetail.name.toLowerCase().contains(text.toLowerCase()) ||
          userDetail.mobile.toLowerCase().contains(text.toLowerCase())) {
        setState(() {
          searchInfoResult.add(userDetail);
        });
      }
    });
  }
}
