import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nova/models/getgroupdata_response.dart';
import 'package:nova/models/group_chat_data.dart';
import 'package:nova/models/create_group.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/services/internet_status_service.dart';
import 'package:nova/services/services_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nova/ui/widgets/customtoast.dart';
import 'package:nova/ui/widgets/customtoasterror.dart';
import 'package:nova/utils/commons.dart';
import 'package:path_provider/path_provider.dart';

class EditGroup extends StatefulWidget {
  final GetGroupDataResponse groupContactData;
  final GroupChatData groupData;
  final Function refresh;

  EditGroup(this.groupContactData, this.groupData, this.refresh);

  @override
  _EditGroupState createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {
  final TextEditingController nameController = TextEditingController();
  HttpService _api = serviceLocator<HttpService>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  File _image;
  bool imagePickedGroup = false;

  Future getImage() async {
    imagePicked = true;
    final picker = ImagePicker();
    final imageFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (imageFile != null) {
      imagePickedGroup = true;
      if (imageFile != null) {
        _image = File(imageFile.path);
      } else {
        print('No image selected.');
      }
      setState(() {});
      imagePicked = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      bottomNavigationBar: Container(
        width: 300,
        margin: EdgeInsets.all(25),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: appColor, // Background color
          ),
          onPressed: () {
            if (imagePickedGroup) {
              updateGroupImage();
            } else {
              updateGroupName();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Save changes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).brightness != Brightness.dark
          ? Colors.grey[100]
          : novaDarkModeBlue,
      body: _groupInfo(),
    );
  }

  Widget _groupInfo() {
    return Column(
      children: <Widget>[
        customAppBar(),
        Container(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Name of group',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 16, right: 16, top: 10),
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).brightness != Brightness.dark
                ? Colors.grey[200]
                : Colors.grey[800],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: CustomtextField3(
              textAlign: TextAlign.start,
              controller: nameController,
              maxLines: 1,
              textInputAction: TextInputAction.next,
              hintText: widget.groupData.name,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 10,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'People in this group',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 16, right: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).brightness != Brightness.dark
                  ? Colors.white
                  : Colors.grey[800],
            ),
            child: widget.groupContactData.users != null
                ? ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: widget.groupContactData.users.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {},
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              onTap: () {},
                              leading: Stack(
                                children: <Widget>[
                                  (widget.groupContactData.users[index]
                                              .avatar !=
                                          "")
                                      ? CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: NetworkImage(
                                            widget.groupContactData.users[index]
                                                    .avatar ??
                                                profilePlaceHolder,
                                          ),
                                        )
                                      : CircleAvatar(
                                          backgroundColor: Colors.grey[400],
                                          child: Image.asset(
                                            "assets/images/user.png",
                                            height: 25,
                                            color: Colors.white,
                                          ),
                                        ),
                                ],
                              ),
                              title: Text(
                                widget.groupContactData.users[index].name ??
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
                          Flexible(
                            child: Text(
                              'No group contacts found. Please check your connection..',
                              style: TextStyle(
                                fontSize: SizeConfig.safeBlockHorizontal * 3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
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
                color: Theme.of(context).brightness != Brightness.dark
                    ? Colors.grey[100]
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
                    GestureDetector(
                        onTap: () {
                          if (!InternetStatusService.isOnline) {
                            Commons.novaFlushBarError(context, noInternet);
                          } else {
                            getImage();
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: _image != null
                              ? FileImage(_image)
                              : widget.groupData.avatar != ""
                                  ? NetworkImage(
                                      widget.groupData.avatar ?? noImage)
                                  : NetworkImage(noImage),
                          radius: 20,
                        )),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            if (!InternetStatusService.isOnline) {
                              Commons.novaFlushBarError(context, noInternet);
                            } else {
                              getImage();
                            }
                          },
                          child: ClipOval(
                              child: SvgPicture.asset(
                                  "assets/images/penedit.svg")),
                        )),
                  ],
                ),
              )),
          Positioned(
              top: 40.0,
              child: Row(
                children: [
                  IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.refresh();
                      }),
                  Text(
                    "Edit group",
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  updateGroupImage() async {
    if (_image != null) {
      final dir = await getTemporaryDirectory();
      final targetPath = dir.absolute.path +
          "/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

      await FlutterImageCompress.compressAndGetFile(
        _image.absolute.path,
        targetPath,
        quality: 20,
      ).then((value) async {
        HttpService _api = serviceLocator<HttpService>();
        if (await _api.updateGroupAvatar(value.path, widget.groupData.uuid) !=
            null) {
          await globalSocketService.push(event: "load_chats");
          updateGroupName();
          showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.transparent,
            builder: (BuildContext context) {
              return Dialog(
                elevation: 0,
                backgroundColor: Colors.white.withOpacity(0),
                child: CustomToast(
                  message1: 'Updated',
                  message2: "Successfully updated group",
                ),
              );
            },
          );
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
                  message2: "Error updating group, please try again.",
                ),
              );
            },
          );
        }
      });
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
              message2: "Please select a group profile image to continue.",
            ),
          );
        },
      );
    }
  }

  updateGroupName() async {
    if (nameController.text.length > 0) {
      CreateGroup groupList = CreateGroup();
      GroupData groupData = GroupData();
      groupData.name = nameController.text;
      groupList.contacts = [];
      groupList.group = groupData;
      if (await _api.updateGroup(groupList, widget.groupData.uuid) != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.transparent,
          builder: (BuildContext context) {
            return Dialog(
              elevation: 0,
              backgroundColor: Colors.white.withOpacity(0),
              child: CustomToast(
                message1: 'Updated',
                message2: "Successfully updated group",
              ),
            );
          },
        );
        await globalSocketService.push(event: "load_chats");
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
                    "There was an error updating your group information. Please try again.",
              ),
            );
          },
        );
      }
    }
  }
}
