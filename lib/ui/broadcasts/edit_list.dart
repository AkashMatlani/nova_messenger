import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nova/models/broadcast_list.dart';
import 'package:nova/models/create_broadcast_list.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/services/internet_status_service.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/ui/widgets/customtoast.dart';
import 'package:nova/ui/widgets/customtoasterror.dart';
import 'package:nova/utils/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:nova/constant/global.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class EditList extends StatefulWidget {
  final BroadcastList listData;
  final Function refresh;

  EditList(this.listData, this.refresh);

  @override
  _EditListState createState() => _EditListState();
}

class _EditListState extends State<EditList> {
  final TextEditingController nameController = TextEditingController();
  HttpService _api = serviceLocator<HttpService>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  File _image;
  bool imagePickedList = false;

  Future getImage() async {
    imagePicked = true;
    final picker = ImagePicker();
    final imageFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (imageFile != null) {
      imagePickedList = true;
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
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: Container(
        width: 300,
        margin: EdgeInsets.all(25),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: appColor, // Background color
          ),
          onPressed: () {
            if (imagePickedList) {
              updateListImage();
            } else {
              updateListName();
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
      body: _broadcastInfo(),
    );
  }

  Widget _broadcastInfo() {
    return Column(
      children: <Widget>[
        customAppBar(),
        Container(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Name of broadcast list',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(16),
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
              hintText: widget.listData.name,
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
                              : widget.listData.avatar != null
                                  ? NetworkImage(
                                      widget.listData.avatar ?? noImage)
                                  : NetworkImage(noImage),
                          radius: 40,
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
                    "Edit list",
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  updateListImage() async {
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
        if (await _api.updateBroadcastListAvatar(
                value.path, widget.listData.uuid) !=
            null) {
          await globalSocketService.push(event: "load_chats");
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
                  message2: "Successfully updated list",
                ),
              );
            },
          );
          updateListName();
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
                  message2: "Error updating list, please try again.",
                ),
              );
            },
          );
        }
      });
    }
  }

  updateListName() async {
    if (nameController.text.length > 0) {
      CreateBroadcastList broadcastList = CreateBroadcastList();
      BroadcastListCreate broadcastData = BroadcastListCreate();
      broadcastData.name = nameController.text;
      broadcastData.description = "";
      broadcastList.contacts = [];
      broadcastList.broadcastList = broadcastData;
      if (await _api.updateBroadcastList(broadcastList, widget.listData.uuid) !=
          null) {
        await globalSocketService.push(event: "load_chats");
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
                message2: "Successfully updated list",
              ),
            );
          },
        );
        await Future.delayed(Duration(milliseconds: 3000));
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
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
      }
    }
  }
}
