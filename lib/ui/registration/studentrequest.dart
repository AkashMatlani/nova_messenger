import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:nova/models/institution_response.dart';
import 'package:nova/models/publickey_token.dart';
import 'package:nova/models/register_student_mobile.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/provider/countries.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/ui/registration/createpro.dart';
import 'package:nova/utils/commons.dart';
import 'package:nova/utils/hive_preferences.dart';
import 'package:nova/utils/rsa_encrypt_data.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:provider/provider.dart';

class StudentRequest extends StatefulWidget {
  final String mobile;

  StudentRequest(this.mobile);

  @override
  _StudentRequestState createState() => _StudentRequestState();
}

class _StudentRequestState extends State<StudentRequest> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController studentController = TextEditingController();
  var isStudent = false;

  List<Institution> institutions = [];
  Institution selectedValue;
  bool _isButtonDisabled = false;
  bool _isRegistering = false;

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
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          centerTitle: true,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _isRegistering
                ? SizedBox(height: MediaQuery.of(context).size.height / 3)
                : Container(),
            _isRegistering ? Center(child: Commons.novaLoader()) : Container(),
            isStudent
                ? Container()
                : !_isRegistering
                    ? Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Text(
                            'Is this for an institute, or are you doing your own thing with it?',
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                                fontFamily: normalStyle,
                                fontSize: 30)),
                      )
                    : Container(),
            isStudent
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 250),
                    child: !_isRegistering ? studentEntry() : Container())
                : Container(),
            Container(height: 20),
            !isStudent
                ? GestureDetector(
                    onTap: () async {
                      _isButtonDisabled ? null : registerMobile();
                    },
                    child: !_isRegistering
                        ? Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/institute.svg',
                                      fit: BoxFit.fill,
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'I’m a teacher',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  top: 8, bottom: 8, right: 4),
                                              child: Text(
                                                'Select this option if you are a teacher affiliated with a university or school.',
                                                style: TextStyle(
                                                  color: introGrey,
                                                  fontSize: 14,
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_sharp,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ],
                                )))
                        : Container())
                : Container(),
            !isStudent
                ? GestureDetector(
                    onTap: () async {
                      if (await getInstitutions() != null) {
                        setState(() {
                          isStudent = true;
                        });
                      } else {
                        Commons.novaFlushBarError(context,
                            "There was an error getting institutions. Please try again.");
                      }
                    },
                    child: !_isRegistering
                        ? Padding(
                            padding: EdgeInsets.all(16),
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/student.svg',
                                      fit: BoxFit.fill,
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'I’m a student',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 8, bottom: 8, right: 4),
                                            child: Text(
                                                'A student affiliated with a university or school.',
                                                style: TextStyle(
                                                  color: introGrey,
                                                  fontSize: 14,
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_sharp,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ],
                                )))
                        : Container())
                : Container(),
            !isStudent
                ? Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: !_isRegistering
                        ? GestureDetector(
                            onTap: () async {
                              _isButtonDisabled ? null : registerMobile();
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/personal.svg',
                                      fit: BoxFit.fill,
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Personal use',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  top: 8, bottom: 8, right: 4),
                                              child: Text(
                                                'Just for chatting with friends & family.',
                                                style: TextStyle(
                                                  color: introGrey,
                                                  fontSize: 14,
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_sharp,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ],
                                )))
                        : Container(),
                  )
                : Container(),
          ],
        ),
      )),
    );
  }

  void registerMobile() async {
    setState(() {
      _isRegistering = true;
      _isButtonDisabled = true;
    });
    var countryProvider = Provider.of<CountryProvider>(context, listen: false);
    var mobNumber = '';
    mobNumber = countryProvider.selectedCountry.dialCode + phoneNumberController.text;
    HttpService _api = serviceLocator<HttpService>();
    RegisterStudentMobile userData = RegisterStudentMobile();
    userData.mobile = mobNumber;
    userData.externalId = "";
    userData.institutionId = "";
    if (await _api.registerUserStudentMobile(userData) != null) {
      await createEncryptionKeys();
      await Future.delayed(Duration(milliseconds: 50));
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => CreatePro()));
    } else {
      if (mounted) {
        setState(() {
          _isRegistering = false;
          _isButtonDisabled = false;
          Commons.novaFlushBarError(
              context, "Error registering mobile number. Please try again.");
        });
      }
    }
  }

  void registerStudent() async {
    if (studentController.text.isNotEmpty || studentController.text != "") {
      if (selectedValue != null) {
        setState(() {
          _isRegistering = true;
          _isButtonDisabled = true;
        });
        RegisterStudentMobile userData = RegisterStudentMobile();
        userData.mobile = widget.mobile;
        userData.institutionId = selectedValue.uuid;
        userData.externalId = studentController.text;
        HttpService _api = serviceLocator<HttpService>();
        if (await _api.registerUserStudentMobile(userData) != null) {
          await createEncryptionKeys();
          await Future.delayed(Duration(milliseconds: 50));
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => CreatePro()));
        } else {
          if (mounted)
            setState(() {
              _isRegistering = false;
              _isButtonDisabled = false;
              Commons.novaFlushBarError(context,
                  "Your details have not yet been confirmed by your institution. Please contact your teacher / lecturer.");
            });
        }
      } else {
        Commons.novaFlushBarError(
            context, "Please select an institution before continuing.");
      }
    } else {
      Commons.novaFlushBarError(
          context, "Please enter a student number to continue.");
    }
  }

  void createEncryptionKeys() async {
    HttpService _api = serviceLocator<HttpService>();
    await createKeyValuePairs();
    final prefs = await HivePreferences.getInstance();
    PublicKeyToken publicKey = PublicKeyToken();
    User user = User();
    user.publicKey = await prefs.getPublicKey();
    publicKey.user = user;
    await _api.updatePublicKey(publicKey);
  }

  void createKeyValuePairs() async {
    final pair =
        RSAEncryptData.generateRSAkeyPair(RSAEncryptData.secureRandom());
    final RSAPublicKey public = pair.publicKey;
    final RSAPrivateKey private = pair.privateKey;
    final prefs = await HivePreferences.getInstance();
    String privateKeyGenerated = CryptoUtils.encodeRSAPrivateKeyToPem(private);
    String publicKeyGenerated = CryptoUtils.encodeRSAPublicKeyToPem(public);
    prefs.setPrivateKey(privateKeyGenerated);
    prefs.setPublicKey(publicKeyGenerated);
  }

  Widget studentEntry() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            'Just one more thing to wrap it up.',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontFamily: normalStyle,
                fontSize: 30),
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            'Pop in your student number, pick your institute, and voila! Mission accomplished!',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.normal,
                fontFamily: normalStyle,
                fontSize: 16),
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
          child: Text(
            'Student number',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.normal,
                fontFamily: normalStyle,
                fontSize: 16),
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          )),
          height: 40,
          child: Center(
            child: TextField(
              controller: studentController,
              keyboardType: TextInputType.streetAddress,
              style: TextStyle(color: Colors.black),
              textAlignVertical: TextAlignVertical.center,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: textFieldBG),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(6),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: new BorderSide(color: textFieldBG),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(8),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: new BorderSide(color: textFieldBG),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(6.0),
                  ),
                ),
                filled: true,
                hintStyle: TextStyle(color: Colors.black87, fontSize: 16),
                hintText: "Student number",
                contentPadding: EdgeInsets.all(10.0),
                fillColor: Colors.grey[200],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
          child: Text(
            'Select your institution',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.normal,
                fontFamily: normalStyle,
                fontSize: 16),
            textAlign: TextAlign.left,
          ),
        ),
        InkWell(
          onTap: () {
            _showInstituteDropDownModal(context);
          },
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              color: textFieldBG,
              borderRadius: BorderRadius.all(
                Radius.circular(6.0),
              ),
            ),
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedValue != null ? selectedValue.name : 'Select an institute',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.normal,
                        fontFamily: normalStyle,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Container(
          height: 45,
          width: MediaQuery.of(context).size.width,
          child: CustomButton(
              title: 'Submit',
              fontSize: 16,
              fontFamily: "DMSans-Regular",
              fontWeight: FontWeight.normal,
              textColor: appColorWhite,
              color: appColor,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              onPressed: () {
                registerStudent();
              }),
        ),
      ],
    );
  }

  Future<List<Institution>> getInstitutions() async {
    HttpService _api = serviceLocator<HttpService>();
    List<Institution> institutionsResponse = await _api.getInstitutions();
    if (institutionsResponse != null) {
      return institutions = institutionsResponse;
    } else {
      return null;
    }
  }

  void _showInstituteDropDownModal(BuildContext context) {
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
          reverse: true,
          child: Container(
            height: 600,
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
                    text: "Select institute",
                    alignment: Alignment.centerLeft,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "DMSans-Regular",
                    color: novaDark,
                  ),
                ),
                SizedBox(height: 16.0),
                Expanded(
                  child: Scrollbar(
                    child: ListView.builder(
                      itemCount: institutions.length,
                      itemBuilder: (BuildContext context, int index) {
                        Institution institute = institutions[index];
                        bool isSelected = institute == selectedValue; // Check if the current item is selected

                        return ListTile(
                          title: Text(
                            institute.name,
                            style: TextStyle(
                              color: isSelected ? appColor : Colors.black, // Apply different style for selected item
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              selectedValue = institute;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
        );
      },
    );
  }
}
