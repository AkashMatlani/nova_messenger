import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nova/models/updateprofilename.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/services/internet_status_service.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/utils/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class EditProfile extends StatefulWidget {
  Function refresh;

  EditProfile({this.refresh});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isLoading = true;
  final TextEditingController nameController = TextEditingController();
  HttpService _api = serviceLocator<HttpService>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  File _image;
  bool imagePicked = false;

  Future getImage() async {
    final picker = ImagePicker();
    final imageFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (imageFile != null) {
      setState(() {
        imagePicked = true;
        if (imageFile != null) {
          _image = File(imageFile.path);
        } else {
          print('No image selected.');
        }
      });
    }
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
            if (imagePicked) {
              updateProfileImage();
            } else {
              updateProfileName();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Update profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: <Widget>[
          isLoading == true ? Center(child: loader()) : _userInfo(),
        ],
      ),
    );
  }

  Widget _userInfo() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: <Widget>[
          customAppBar(),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20,bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your name',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16, right: 16),
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
                hintText: globalName,
              ),
            ),
          ),
        ],
      ),
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
                              : globalImage != ""
                                  ? NetworkImage(globalImage)
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
                ],
              )),
        ],
      ),
    );
  }

  updateProfileImage() async {
    if (_image != null) {
      final dir = await getTemporaryDirectory();
      final targetPath = dir.absolute.path +
          "/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

      await FlutterImageCompress.compressAndGetFile(
        _image.absolute.path,
        targetPath,
        quality: 20,
      ).then((value) async {
        setState(() {
          isLoading = true;
        });
        HttpService _api = serviceLocator<HttpService>();
        if (await _api.updateProfileImage(value.path) != null) {
          setState(() {
            isLoading = false;
          });
          _showSnackBar(context, "Successfully updated profile image.");
          updateProfileName();
        } else {
          setState(() {
            isLoading = false;
          });
          _showSnackBar(context,
              "There was an error updating your profile image. Please try again.");
        }
      });
    } else {
      _showSnackBar(context, "Please select a profile image to continue.");
    }
  }

  updateProfileName() async {
    if (nameController.text.length > 0) {
      HttpService _api = serviceLocator<HttpService>();
      UpdateProfileName profileName = UpdateProfileName();
      User user = User();
      user.name = nameController.text;
      profileName.user = user;
      setState(() {
        isLoading = true;
      });
      if (await _api.updateProfileName(profileName) != null) {
        _showSnackBar(context, "Successfully updated your profile name.");
        Navigator.pop(context);
        widget.refresh();
      } else {
        setState(() {
          isLoading = false;
        });
        _showSnackBar(context,
            "There was an error updating your profile name. Please try again.");
      }
    }
  }

  getUserData() async {
    var userResponse = await _api.getUser();
    if (userResponse != null) {
      globalName = userResponse.name;
      globalImage = userResponse.avatar;
      setState(() {
        isLoading = false;
      });
    } else {
      Commons.novaFlushBarError(
          context, "Error Getting Profile Data. Please try again.");
    }
  }

  void _showSnackBar(BuildContext context, String text) {
    // ignore: deprecated_member_use
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
