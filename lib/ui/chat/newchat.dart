import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nova/models/contact_data.dart';
import 'package:nova/models/contact_detail.dart';
import 'package:nova/models/create_contacts.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/ui/broadcasts/newbroadcastlist.dart';
import 'package:nova/ui/widgets/customtoasterror.dart';
import 'package:nova/utils/commons.dart';
import 'package:flutter/material.dart';
import 'package:nova/ui/chat/chat.dart';
import 'package:nova/ui/groupchats/create_new_group.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NewChat extends StatefulWidget {
  @override
  NewChatState createState() {
    return NewChatState();
  }
}

class NewChatState extends State<NewChat> {
  Contact contact = Contact();

  String mobile = "";
  String email = "";

  TextEditingController controller = TextEditingController();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  List<ContactData> contactsDetailsInfo = [];
  List<ContactData> searchInfoResult = [];
  bool isSearching = false;
  HttpService _api = serviceLocator<HttpService>();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              "Contacts",
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
              "${contactsDetailsInfo.length} contacts",
              style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'DMSans-Regular',
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Color.fromRGBO(130, 136, 152, 1)
                      : Color.fromRGBO(23, 23, 54, 1)),
            )
          ],
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              inHome = true;
            },
            icon: Icon(
              Icons.arrow_back_sharp,
              color: Theme.of(context).brightness == Brightness.dark
                  ? appColor
                  : Colors.black,
              size: 30,
            )),
      ),
      body: contactsDetailsInfo == null
          ? Container()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        // height: SizeConfig.blockSizeVertical * 15,
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
                        height: 20,
                      ),
                      Container(
                        child: Column(
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NewGroup()),
                                );
                              },
                              child: Container(
                                height: SizeConfig.blockSizeVertical * 7,
                                child: Center(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Colors.grey[200],
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          child: SvgPicture.asset(
                                            'assets/images/usersgray.svg',
                                            fit: BoxFit.fill,
                                          ),
                                        )),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        new Text(
                                          'New Group',
                                          style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                _showModalContactForm(context);
                              },
                              child: Container(
                                height: SizeConfig.blockSizeVertical * 7,
                                child: Center(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Colors.grey[200],
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          child: SvgPicture.asset(
                                            'assets/images/personaddgray.svg',
                                            fit: BoxFit.fill,
                                          ),
                                        )),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          'New Contact',
                                          style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NewBroadcastList()),
                                ).then((value) => getContacts());
                              },
                              child: Container(
                                height: SizeConfig.blockSizeVertical * 7,
                                child: Center(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Colors.grey[200],
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          child: SvgPicture.asset(
                                            'assets/images/sirengray.svg',
                                            fit: BoxFit.fill,
                                          ),
                                        )),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          'New Broadcast list',
                                          style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(height: 5),
                          ],
                        ),
                      ),
                      Divider(
                        thickness: 1,
                      ),
                      !isSearching ? contactsWidget() : searchContactsWidget(),
                    ],
                  ),
                ),
              ),
            ),
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
                    return InkWell(
                      onTap: () {
                        if (contactsDetailsInfo[index].status == "pending") {
                          Commons.novaFlushBarError(context,
                              "You cannot message this contact yet as they are not registered on Nova.");
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Chat(
                                      peerData: contactsDetailsInfo[index],
                                    )),
                          );
                        }
                      },
                      child: Slidable(
                        actionPane: SlidableDrawerActionPane(),
                        actionExtentRatio: 0.25,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              onTap: () {
                                if (contactsDetailsInfo[index].status ==
                                    "pending") {
                                  Commons.novaFlushBarError(context,
                                      "You cannot message this contact yet as they are not registered on Nova.");
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Chat(
                                              peerData:
                                                  contactsDetailsInfo[index],
                                            )),
                                  );
                                }
                              },
                              leading: Stack(
                                children: <Widget>[
                                  (contactsDetailsInfo[index].avatar != "")
                                      ? CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              contactsDetailsInfo[index]
                                                  .avatar),
                                        )
                                      : CircleAvatar(
                                          backgroundColor: Colors.grey[400],
                                          child: Image.asset(
                                            "assets/images/user.png",
                                            height: 25,
                                            color: Colors.white,
                                          )),
                                ],
                              ),
                              title: Text(
                                contactsDetailsInfo[index].name ?? "Unknown",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Container(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Row(
                                  children: [
                                    Text(
                                      contactsDetailsInfo[index].mobile ?? "",
                                      style: TextStyle(fontSize: 14),
                                    )
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
                              var response = await _api.deleteContact(
                                  contactsDetailsInfo[index].uuid);
                              if (response != null) {
                                await getContacts();
                                setState(() {
                                  contactsDetailsInfo = contactsGlobalData;
                                });
                              } else {
                                Commons.novaFlushBarError(context,
                                    "Error deleting list. Please try again.");
                              }
                            },
                          ),
                        ],
                      ),
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
                    'Only contacts with your number in their address book \nwill receive your messages. \nNo contacts available. Please check your connection and retry.',
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
                    return InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Chat(
                                    peerData: searchInfoResult[index],
                                  )),
                        );
                      },
                      child: Slidable(
                        actionPane: SlidableDrawerActionPane(),
                        actionExtentRatio: 0.25,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              onTap: () {
                                if (searchInfoResult[index] != null) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Chat(
                                              peerData: searchInfoResult[index],
                                            )),
                                  );
                                }
                              },
                              leading: Stack(
                                children: <Widget>[
                                  (searchInfoResult[index].avatar != "")
                                      ? CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              searchInfoResult[index].avatar),
                                        )
                                      : CircleAvatar(
                                          backgroundColor: Colors.grey[400],
                                          child: Image.asset(
                                            "assets/images/user.png",
                                            height: 25,
                                            color: Colors.white,
                                          )),
                                ],
                              ),
                              title: Text(
                                searchInfoResult[index].name ?? "Unknown",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Container(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Row(
                                  children: [
                                    Text(
                                      searchInfoResult[index].mobile ?? "",
                                      style: TextStyle(fontSize: 14),
                                    )
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
                              var response = await _api
                                  .deleteContact(searchInfoResult[index].uuid);
                              if (response != null) {
                                getContacts();
                              } else {
                                Commons.novaFlushBarError(context,
                                    "Error deleting list. Please try again.");
                              }
                            },
                          ),
                        ],
                      ),
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
                    'Only contacts with your number in their address book \nwill receive your messages. \nNo contacts available. Please check your connection and retry.',
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

  Widget groupWidget() {
    return Container(
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NewGroup()),
              );
            },
            child: Container(
              height: SizeConfig.blockSizeVertical * 6.2,
              child: Center(
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[200],
                    child: IconButton(
                      icon: Icon(
                        Icons.people,
                        size: 25,
                        color: appColor,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => NewGroup()),
                        );
                      },
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Group',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: appColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(height: 5),
        ],
      ),
    );
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

  void _showModalContactForm(BuildContext context) {
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
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16.0,
              right: 16.0,
              top: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16.0),
                Container(
                  decoration: BoxDecoration(
                    color: bgGrey,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  width: 60,
                  height: 5,
                ),
                SizedBox(height: 16.0),
                SizedBox(height: 16.0),
                Padding(
                    padding: EdgeInsets.only(left: 5, bottom: 5),
                    child: CustomText(
                      text: "New contact",
                      alignment: Alignment.centerLeft,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "DMSans-Regular",
                      color: novaDark,
                    )),
                SizedBox(height: 16.0),
                SizedBox(height: 16.0),
                Padding(
                    padding: EdgeInsets.only(left: 5, bottom: 5),
                    child: CustomText(
                      text: "First name",
                      alignment: Alignment.centerLeft,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      fontFamily: "DMSans-Regular",
                      color: novaDark,
                    )),
                TextFieldWidget(
                  label: "First name",
                  controller: firstNameController,
                ),
                SizedBox(height: 8.0),
                Padding(
                    padding: EdgeInsets.only(left: 5, bottom: 5),
                    child: CustomText(
                      text: "Last name",
                      alignment: Alignment.centerLeft,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      fontFamily: "DMSans-Regular",
                      color: novaDark,
                    )),
                TextFieldWidget(
                  label: "Last name",
                  controller: lastNameController,
                ),
                SizedBox(height: 8.0),
                Padding(
                    padding: EdgeInsets.only(left: 5, bottom: 5),
                    child: CustomText(
                      text: "Country",
                      alignment: Alignment.centerLeft,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      fontFamily: "DMSans-Regular",
                      color: novaDark,
                    )),
                TextFieldWidget(
                  label: "Country",
                ),
                SizedBox(height: 8.0),
                Padding(
                    padding: EdgeInsets.only(left: 5, bottom: 5),
                    child: CustomText(
                      text: "Mobile number",
                      alignment: Alignment.centerLeft,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      fontFamily: "DMSans-Regular",
                      color: novaDark,
                    )),
                TextFieldWidget(
                  label: "Mobile number",
                  controller: mobileController,
                ),
                SizedBox(height: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: appColor,
                          borderRadius: BorderRadius.circular(
                              6.0), // Adjust the radius as needed
                        ),
                        width: 288, // Match the width of the screen
                        child: InkWell(
                          onTap: () async {
                            if (firstNameController.text != "" ||
                                mobileController.text != "") {
                              HttpService _api = serviceLocator<HttpService>();
                              ContactDetail contactDetail = ContactDetail();
                              contactDetail.number = mobileController.text;
                              contactDetail.name = firstNameController.text +
                                  " " +
                                  lastNameController.text;
                              contactDetail.email = "";
                              List<ContactDetail> contacts = [];
                              contacts.add(contactDetail);

                              CreateContacts contactsNew = CreateContacts();
                              contactsNew.contacts = contacts;

                              await _api.createContacts(contactsNew);
                              await getContacts();
                              setState(() {
                                contactsDetailsInfo = contactsGlobalData;
                              });
                              firstNameController.text = "";
                              lastNameController.text = "";
                              mobileController.text = "";
                              Navigator.of(context).pop();
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
                                      message2: "Please fill in name and mobile details.",
                                    ),
                                  );
                                },
                              );

                            } // Close the modal
                          },
                          child: Center(
                              child: Text('Save',
                                  style: TextStyle(color: Colors.white))),
                        )),
                    SizedBox(height: 18.0),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: appColor),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.0),
              ],
            ),
          ),
        );
      },
    );
  }

}

class TextFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const TextFieldWidget({
    Key key,
    @required this.label,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextField(
        cursorColor: appColor,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.black
          ),
          border: InputBorder.none,
          hintStyle: TextStyle(color: appColor),
          contentPadding: EdgeInsets.all(16.0),
        ),
      ),
    );
  }
}
