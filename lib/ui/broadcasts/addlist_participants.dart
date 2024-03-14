import 'package:nova/models/broadcast_list.dart';
import 'package:nova/models/contact_data.dart';
import 'package:nova/models/create_broadcast_list.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/services/services_locator.dart';
import 'package:flutter/material.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:nova/ui/widgets/customtoast.dart';
import 'package:nova/ui/widgets/customtoasterror.dart';
import 'package:nova/ui/widgets/selectedusertile.dart';

class AddListParticipants extends StatefulWidget {
  final BroadcastList listData;

  AddListParticipants(this.listData);

  @override
  AddListParticipantsState createState() {
    return AddListParticipantsState();
  }
}

class AddListParticipantsState extends State<AddListParticipants> {
  TextEditingController controller = TextEditingController();
  List<ContactData> contactsDetailsInfo = [];
  List<ContactData> searchInfoResult = [];
  bool isSearching = false;
  HttpService _api = serviceLocator<HttpService>();
  FocusNode focusNode = FocusNode();
  String hintText = 'Search';

  List<String> userIdsList = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: Container(
        width: 300,
        margin: EdgeInsets.all(25),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: appColor, // Background color
          ),
          onPressed: () {
            addParticipantsToList();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Add participants',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Padding(
            padding: EdgeInsets.only(right: 10, top: 20, bottom: 10),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: 25,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    inHome = true;
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add participants',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontSize: 20),
                    ),
                    Text(
                      userIdsList.length > 0
                          ? userIdsList.length.toString() + " " + "Selected"
                          : "Select your participants",
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontSize: 14),
                    ),
                    SizedBox(height: 10)
                  ],
                ),
              ],
            )),
        centerTitle: false,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: contactsDetailsInfo == null
          ? Container()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      userIdsList.length > 0
                          ? buildParticipantGrid()
                          : Container(),
                      Container(
                        child: Column(
                          children: <Widget>[
                            Padding(
                                padding:
                                    const EdgeInsets.only(right: 15, left: 15),
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
                                      focusNode: focusNode,
                                      onChanged: onSearchTextChanged,
                                      style: TextStyle(color: Colors.grey),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey[200]),
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(15.0),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey[200]),
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(15.0),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey[200]),
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(15.0),
                                          ),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14),
                                        hintText: hintText,
                                        contentPadding:
                                            EdgeInsets.only(top: 10.0),
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
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      !isSearching ? contactsWidget() : searchContactsWidget(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildParticipantGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 0.85,
      ),
      itemCount: userIdsList.length,
      itemBuilder: (context, index) {
        var participant = contactsGlobalData.firstWhere(
            (element) => userIdsList[index] == element.uuid,
            orElse: () => null);
        return SelectedUserTile(
            user: participant,
            onRemoveUser: () {
              setState(() {
                userIdsList.remove(participant.uuid);
              });
            });
      },
    );
  }

  Widget contactsWidget() {
    return contactsDetailsInfo != null
        ? SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Column(
              children: <Widget>[
                ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: contactsDetailsInfo.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return !userIdsList
                            .contains(contactsDetailsInfo[index].uuid)
                        ? Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      onTap: () {
                                        setState(() {
                                          userIdsList.add(
                                              contactsDetailsInfo[index].uuid);
                                        });
                                      },
                                      leading: Stack(
                                        children: <Widget>[
                                          contactsDetailsInfo[index].avatar !=
                                                  ""
                                              ? CircleAvatar(
                                                  radius: 25.0,
                                                  backgroundColor: Colors.grey,
                                                  backgroundImage: NetworkImage(
                                                      contactsDetailsInfo[index]
                                                          .avatar),
                                                )
                                              : CircleAvatar(
                                                  radius: 25.0,
                                                  backgroundColor:
                                                      Colors.grey[300],
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
                                        ],
                                      ),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            contactsDetailsInfo[index].name ??
                                                "",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      subtitle: Container(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Row(
                                          children: [
                                            Text(contactsDetailsInfo[index]
                                                    .mobile ??
                                                "")
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                  child: Stack(children: [
                                Column(
                                  children: <Widget>[
                                    ListTile(
                                      onTap: () {
                                        setState(() {
                                          userIdsList.remove(
                                              contactsDetailsInfo[index].uuid);
                                        });
                                      },
                                      leading: Container(
                                          padding: EdgeInsets.all(2.0),
                                          // Add margin here
                                          child: Stack(
                                            children: <Widget>[
                                              contactsDetailsInfo[index]
                                                          .avatar !=
                                                      ""
                                                  ? Container(
                                                      padding:
                                                          EdgeInsets.all(4.0),
                                                      // Add margin here
                                                      child: CircleAvatar(
                                                        radius: 25.0,
                                                        backgroundColor:
                                                            Colors.grey,
                                                        backgroundImage:
                                                            NetworkImage(
                                                                contactsDetailsInfo[
                                                                        index]
                                                                    .avatar),
                                                      ))
                                                  : Container(
                                                      padding:
                                                          EdgeInsets.all(4.0),
                                                      // Add margin here
                                                      child: CircleAvatar(
                                                          radius: 25.0,
                                                          backgroundColor:
                                                              Colors.grey[300],
                                                          backgroundImage:
                                                              NetworkImage(
                                                                  noImage),
                                                          child: Text(
                                                            "",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ))),
                                              Positioned(
                                                  top: 25,
                                                  right: 0,
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.green,
                                                          width: 1.0,
                                                        ),
                                                        color:
                                                            tickColor, // Fill color with opacity
                                                      ),
                                                      child: Icon(
                                                        Icons.check_circle,
                                                        color: tickBGColor,
                                                        size: 13,
                                                      )))
                                            ],
                                          )),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            contactsDetailsInfo[index].name ??
                                                "",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      subtitle: Container(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Row(
                                          children: [
                                            Text(contactsDetailsInfo[index]
                                                    .mobile ??
                                                "")
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ])),
                            ],
                          );
                  },
                )
              ],
            ),
          )
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
    return searchInfoResult != null
        ? SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Column(
              children: <Widget>[
                ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: searchInfoResult.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return !userIdsList.contains(searchInfoResult[index].uuid)
                        ? Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      onTap: () {
                                        setState(() {
                                          userIdsList.add(
                                              searchInfoResult[index].uuid);
                                        });
                                      },
                                      leading: Stack(
                                        children: <Widget>[
                                          searchInfoResult[index].avatar != ""
                                              ? CircleAvatar(
                                                  radius: 25.0,
                                                  backgroundColor: Colors.grey,
                                                  backgroundImage: NetworkImage(
                                                      searchInfoResult[index]
                                                          .avatar),
                                                )
                                              : CircleAvatar(
                                                  radius: 25.0,
                                                  backgroundImage:
                                                      NetworkImage(noImage),
                                                  backgroundColor:
                                                      Colors.grey[300],
                                                  child: Text(
                                                    "",
                                                    style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                        ],
                                      ),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            searchInfoResult[index].name ?? "",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      subtitle: Container(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Row(
                                          children: [
                                            Text(searchInfoResult[index]
                                                    .mobile ??
                                                "")
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                  child: Stack(children: [
                                Column(
                                  children: <Widget>[
                                    ListTile(
                                      onTap: () {
                                        setState(() {
                                          userIdsList.remove(
                                              searchInfoResult[index].uuid);
                                        });
                                      },
                                      leading: Container(
                                          padding: EdgeInsets.all(2.0),
                                          // Add margin here
                                          child: Stack(
                                            children: <Widget>[
                                              searchInfoResult[index].avatar !=
                                                      ""
                                                  ? Container(
                                                      padding:
                                                          EdgeInsets.all(4.0),
                                                      // Add margin here
                                                      child: CircleAvatar(
                                                        radius: 25.0,
                                                        backgroundColor:
                                                            Colors.grey,
                                                        backgroundImage:
                                                            NetworkImage(
                                                                searchInfoResult[
                                                                        index]
                                                                    .avatar),
                                                      ))
                                                  : Container(
                                                      padding:
                                                          EdgeInsets.all(4.0),
                                                      // Add margin here
                                                      child: CircleAvatar(
                                                          radius: 25.0,
                                                          backgroundColor:
                                                              Colors.grey[300],
                                                          backgroundImage:
                                                              NetworkImage(
                                                                  noImage),
                                                          child: Text(
                                                            "",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ))),
                                              Positioned(
                                                  top: 25,
                                                  right: 0,
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.green,
                                                          width: 1.0,
                                                        ),
                                                        color:
                                                            tickColor, // Fill color with opacity
                                                      ),
                                                      child: Icon(
                                                        Icons.check_circle,
                                                        color: tickBGColor,
                                                        size: 13,
                                                      )))
                                            ],
                                          )),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            searchInfoResult[index].name ?? "",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      subtitle: Container(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Row(
                                          children: [
                                            Text(searchInfoResult[index]
                                                    .mobile ??
                                                "")
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ])),
                            ],
                          );
                  },
                )
              ],
            ),
          )
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

  addParticipantsToList() async {
    if (userIdsList.length <= 0) {
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
    } else {
      CreateBroadcastList broadcastList = CreateBroadcastList();
      BroadcastListCreate broadcastListData = BroadcastListCreate();
      broadcastListData.name = widget.listData.name;
      broadcastListData.description = "";
      broadcastList.contacts = userIdsList;
      broadcastList.broadcastList = broadcastListData;
      if (await _api.updateBroadcastList(broadcastList, widget.listData.uuid) !=
          null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.transparent,
          builder: (BuildContext context) {
            return Dialog(
              elevation: 0,
              backgroundColor: Colors.white.withOpacity(0),
              child: CustomToast(
                message1: 'Added participants',
                message2: "Successfully added participants",
              ),
            );
          },
        );
        setState(() {
          contactsDetailsInfo = [];
          searchInfoResult = [];
        });
        await Future.delayed(Duration(milliseconds: 3000));
        Navigator.pop(context);
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
                message2:
                    "There was an error updating your list information. Please try again.",
              ),
            );
          },
        );
        await Future.delayed(Duration(milliseconds: 3000));
        Navigator.pop(context);
        setState(() {});
      }
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
