import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nova/models/updateprofilename.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/services/services_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:nova/ui/home/homescreen.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nova/utils/commons.dart';
import 'package:nova/utils/hive_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as permission;

class CreatePro extends StatefulWidget {
  @override
  _CreateProState createState() => _CreateProState();
}

class _CreateProState extends State<CreatePro> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController nameController = TextEditingController();
  File _image;
  bool isLoading = false;
  bool isButtonEnabled = false;

  isEmpty() {
    if (nameController.text.trim() != "") {
      isButtonEnabled = true;
    } else {
      isButtonEnabled = false;
    }
  }

  Future getImage() async {
    if (await permission.Permission.camera.request().isGranted) {
      final picker = ImagePicker();
      final imageFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (imageFile != null) {
        setState(() {
          if (imageFile != null) {
            _image = File(imageFile.path);
          } else {
            print('No image selected.');
          }
        });
      }
    } else {
      Commons.novaFlushBarError(context,
          "We need permission to access to your photos in order to set a profile image.");
      permission.openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      decoration:
          BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
      child: Container(
        child: Scaffold(
            key: _scaffoldKey,
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                "Create a profile",
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(fontSize: 20),
              ),
              centerTitle: false,
              automaticallyImplyLeading: true,
            ),
            body: Stack(
              children: [
                Center(
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            "  Version: " + buildNumber,
                            style: TextStyle(fontSize: 9),
                          ),
                        ))),
                LayoutBuilder(builder: (context, constraint) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraint.maxHeight),
                        child: IntrinsicHeight(
                          child: Stack(
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                      height:
                                          SizeConfig.blockSizeVertical * 10),
                                  _image == null
                                      ? SizedBox(
                                          height: 142,
                                          width: 142,
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            fit: StackFit.expand,
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: Colors.transparent,
                                                child: SvgPicture.asset(
                                                  'assets/images/createprofile.svg',
                                                  height: 132,
                                                  width: 142,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                              Positioned(
                                                  bottom: 0,
                                                  right: -25,
                                                  child: RawMaterialButton(
                                                    onPressed: () {
                                                      getImage();
                                                    },
                                                    elevation: 1.0,
                                                    fillColor: appColor,
                                                    child: Icon(
                                                      Icons.camera_alt_outlined,
                                                      color: Colors.white,
                                                    ),
                                                    padding:
                                                        EdgeInsets.all(15.0),
                                                    shape: CircleBorder(),
                                                  )),
                                            ],
                                          ))
                                      : SizedBox(
                                          height: 142,
                                          width: 142,
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            fit: StackFit.expand,
                                            children: [
                                              CircleAvatar(
                                                  backgroundImage:
                                                      FileImage(_image)),
                                              Positioned(
                                                  bottom: 0,
                                                  right: -25,
                                                  child: RawMaterialButton(
                                                    onPressed: () {
                                                      getImage();
                                                    },
                                                    elevation: 1.0,
                                                    fillColor: appColor,
                                                    child: Icon(
                                                      Icons.camera_alt_outlined,
                                                      color: Colors.white,
                                                    ),
                                                    padding:
                                                        EdgeInsets.all(15.0),
                                                    shape: CircleBorder(),
                                                  )),
                                            ],
                                          )),
                                  SizedBox(
                                      height: SizeConfig.blockSizeVertical * 5),
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 23, right: 20),
                                          child: Text(
                                            "Name",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6
                                                .copyWith(fontSize: 14),
                                          ))),
                                  SizedBox(
                                      height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: TextField(
                                      maxLength: 25,
                                      onChanged: (val) {
                                        isEmpty();
                                      },
                                      controller: nameController,
                                      style: TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: appColor,
                                          ),
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(6.0),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: appColor,
                                          ),
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(6.0),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                          ),
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(6.0),
                                          ),
                                        ),
                                        filled: true,
                                        contentPadding: EdgeInsets.only(
                                            top: 10.0, left: 10),
                                        fillColor: Colors.grey.withOpacity(0.2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              !isLoading
                                  ? Padding(
                                        padding:
                                            const EdgeInsets.only(top: 400),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 20,
                                              top: 0,
                                              left: 20,
                                              bottom: 10),
                                          child: SizedBox(
                                            height: 40,
                                            width: SizeConfig.screenWidth,
                                            child: CustomButton(
                                                title: 'Next',
                                                fontSize: 16,
                                                fontFamily: "DMSans-Regular",
                                                fontWeight: FontWeight.normal,
                                                textColor: appColorWhite,
                                                color: appColor,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8)),
                                                onPressed: () {
                                                  createProfile();
                                                }),
                                          ),
                                        ),
                                      )
                                  : Container(),
                            ],
                          ),
                        )),
                  );
                }),
                isLoading == true ? Center(child: loader()) : Container(),
              ],
            )),
      ),
    );
  }

  createProfile() async {
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
          checkProfileNameProceed();
          _showSnackBar(context, "Successfully updated profile image.");
        } else {
          setState(() {
            isLoading = false;
          });
          _showSnackBar(context,
              "There was an error updating your profile image. Please try again.");
        }
      });
    } else {
      checkProfileNameProceed();
    }
  }

  void checkProfileNameProceed() async {
    if (nameController.text.length > 0) {
      HttpService _api = serviceLocator<HttpService>();
      UpdateProfileName profileName = UpdateProfileName();
      User user = User();
      user.privacy = true;
      user.name = nameController.text;
      profileName.user = user;
      setState(() {
        isLoading = true;
      });
      if (await _api.updateProfileName(profileName) != null) {
        if (await permission.Permission.contacts.request().isGranted) {
          gotoHomeScreen();
        } else {
          await startAppServices(context);
          await createTrengoId();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        _showSnackBar(context,
            "There was an error creating your profile. Please try again.");
      }
    } else {
      setState(() {
        isLoading = false;
      });
      Commons.novaFlushBarError(context,"Please enter your name");
    }
  }

  void gotoHomeScreen() async {
    try {
      createContactsFromGlobal().then((value) async {
        await startAppServices(context);
        await createTrengoId();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Commons.novaFlushBarError(context, "Error creating profile. Please try again. "+e.toString());
    }
  }

  void createTrengoId() async {
    final preferences = await HivePreferences.getInstance();
    trengoIdentifier = "custom-" + await getRandomString(13);
    preferences.setTrengoId(trengoIdentifier);
  }

  void _showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
