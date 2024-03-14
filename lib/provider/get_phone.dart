import 'package:agconnect_auth/agconnect_auth.dart';
import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart' as authFire;
import 'package:flutter/gestures.dart';
import 'package:nova/ui/registration/studentrequest.dart';
import 'package:nova/ui/terms/policy_dialog.dart';
import 'package:nova/ui/home/homescreen.dart';
import 'package:nova/utils/commons.dart';
import 'package:nova/services/internet_status_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nova/utils/hive_preferences.dart';
import 'package:nova/utils/widgets.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:nova/provider/countries.dart';
import 'package:nova/provider/select_country.dart';
import 'package:nova/provider/verify.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart' as permission;

class PhoneAuthGetPhone extends StatefulWidget {

  @override
  _PhoneAuthGetPhoneState createState() => _PhoneAuthGetPhoneState();

}

class _PhoneAuthGetPhoneState extends State<PhoneAuthGetPhone> {
  double _height, _fixedPadding;

  @override
  void initState() {
    mobNo = '';
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    _height = MediaQuery.of(context).size.height;
    _fixedPadding = _height * 0.025;
    final countriesProvider = Provider.of<CountryProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        key: _scaffoldKey,
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
          centerTitle: true,
          automaticallyImplyLeading: true,
        ),
        body: Builder(builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(bottom: 50),
              child: Stack(
                children: <Widget>[
                  Container(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: _getBody(countriesProvider),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }


  Widget _getBody(CountryProvider countriesProvider) =>
      countriesProvider.countries.length > 0
          ? _getColumnBody(countriesProvider)
          : Center(
              child: CircularProgressIndicator(
              color: appColor,
            ));

  Widget _getColumnBody(CountryProvider countriesProvider) => SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Text(
            'Tell us a bit about yourself',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontFamily: normalStyle,
                fontSize: 30),
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Text(
            'Kindly verify your country code and enter your phone number for confirmation.',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.normal,
                fontFamily: normalStyle,
                fontSize: 16),
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          height: 10,
        ),
        Padding(
          padding: EdgeInsets.only(
              top: _fixedPadding, left: _fixedPadding, bottom: 5),
          child: CustomText(
            text: "Choose a country/region",
            alignment: Alignment.centerLeft,
            fontSize: 16,
            fontWeight: FontWeight.normal,
            fontFamily: "DMSans-Regular",
            color: novaDark,
          ),
        ),
        Padding(
          padding:
          EdgeInsets.only(left: _fixedPadding, right: _fixedPadding),
          child: ShowSelectedCountry(
            country: countriesProvider.selectedCountry,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SelectCountry()),
              );
            },
          ),
        ),
        Container(
          height: 30,
        ),
        Padding(
          padding: EdgeInsets.only(left: _fixedPadding, bottom: 5),
          child: CustomText(
            text: "Enter your phone number",
            alignment: Alignment.centerLeft,
            fontSize: 16,
            fontWeight: FontWeight.normal,
            fontFamily: "DMSans-Regular",
            color: novaDark,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              left: _fixedPadding,
              right: _fixedPadding,
              bottom: _fixedPadding),
          child: PhoneNumberField(
            controller: phoneNumberController,
            prefix: countriesProvider.selectedCountry.dialCode ?? "+91",
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: privacyPolicyLinkAndTermsOfService(),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Padding(
            padding: const EdgeInsets.only(
                right: 20, top: 0, left: 20, bottom: 10),
            child: SizedBox(
              height: 50,
              width: SizeConfig.screenWidth,
              child: CustomButton(
                  title: 'Next',
                  fontSize: 16,
                  fontFamily: "DMSans-Regular",
                  fontWeight: FontWeight.normal,
                  textColor: appColorWhite,
                  color: appColor,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  onPressed: () {
                    if (!InternetStatusService.isOnline) {
                      Commons.novaFlushBarError(context, noInternet);
                    } else {
                      _validateMobileNumber();
                    }
                  }),
            ),
          ),
        ),
      ],
    ),
  );


  String validateMobile(String value) {
    if (value.length == 0) {
      Commons.novaFlushBarError(context, "Please enter a valid mobile number.");
    } else {
      startPhoneAuth();
      // Navigator.of(context).pushReplacement(MaterialPageRoute(
      //     builder: (BuildContext context) => StudentRequest(mobNo)));
    }
    return null;
  }

  void checkIsUserSignedIn(BuildContext context) {
    var countryProvider = Provider.of<CountryProvider>(context, listen: false);
    AGCAuth.instance.currentUser.then((user) {
      if (user != null) {
        print("User is already signed in");
      } else {
        requestHuaweiCode(
            context,
            countryProvider.selectedCountry.dialCode.replaceAll("+", ""),
            phoneNumberController.text);
      }
    });
  }

  // bliss //

  void requestHuaweiCode(
      BuildContext context, String countryCode, String phoneNumber) async {
    if (await checkInternet()) {
      if (phoneNumber[0] == "0") {
        phoneNumber = phoneNumber.substring(1);
      }
      VerifyCodeSettings settings =
          VerifyCodeSettings(VerifyCodeAction.registerLogin, sendInterval: 15);
      PhoneAuthProvider.requestVerifyCode(countryCode, phoneNumber, settings).then((result) {
        Navigator.of(context).pushReplacement(CupertinoPageRoute(
            builder: (BuildContext context) => PhoneAuthVerify()));
      }).catchError((error) {
        Commons.novaFlushBarError(
            context, "Requested verification code failed. Please try again.");
      });
    } else {
      Commons.novaFlushBarError(context, "Please connect your internet.");
    }
  }

// joy //

  startPhoneAuth() async {
    if (await isHuawei()) {
      checkIsUserSignedIn(context);
    } else {
      var countryProvider =
          Provider.of<CountryProvider>(context, listen: false);
      var mobNo = countryProvider.selectedCountry.dialCode + phoneNumberController.text;
      await auth.verifyPhoneNumber(
        phoneNumber:mobNo,
        verificationFailed: (authFire.FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            Commons.novaFlushBarError(context, "Oops! Number seems invalid.");
          } else {
            Commons.novaFlushBarError(context, e.toString());
          }
        },
        verificationCompleted: (authFire.PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        codeSent: (String verificationId, int resendToken) {
          Navigator.of(context).pushReplacement(CupertinoPageRoute(
              builder: (BuildContext context) => PhoneAuthVerify()));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    }
  }


  void _validateMobileNumber() async {
    mobNo = '';
    mobNo = phoneNumberController.text;
    if (mobNo == "735555555") {
      final preferences = await HivePreferences.getInstance();
      preferences.setUserToken(appleAuthToken);
      preferences.setUserId(appleUuid);
      //
      userUuid = appleUuid;
      userToken = appleAuthToken;
      navHomeScreen();
    } else if (mobNo == "795555555") {
      final preferences = await HivePreferences.getInstance();
      preferences.setUserToken(googleAuthToken);
      preferences.setUserId(googleUuid);
      //
      userUuid = googleUuid;
      userToken = googleAuthToken;
      navHomeScreen();
    } else if (mobNo == "797555555") {
      final preferences = await HivePreferences.getInstance();
      preferences.setUserToken(testAuthToken);
      preferences.setUserId(testUuid);
      //
      userUuid = testUuid;
      userToken = testAuthToken;
      navHomeScreen();
    } else if (mobNo == "786555555") {
      final preferences = await HivePreferences.getInstance();
      preferences.setUserToken(huaweiAuthToken);
      preferences.setUserId(huaweiUuid);
      //
      userUuid = huaweiUuid;
      userToken = huaweiUuid;
      navHomeScreen();
    } else {
      setState(() {});
      validateMobile(phoneNumberController.text);
    }
  }

  void navHomeScreen() async {
    if (await permission.Permission.contacts.request().isGranted) {
      createContactsFromGlobal().then((value) async {
        await startAppServices(context);
        final preferences = await HivePreferences.getInstance();
        preferences.setIsLoggedIn(true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      });
    } else {
      await startAppServices(context);
      final preferences = await HivePreferences.getInstance();
      preferences.setIsLoggedIn(true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  Widget privacyPolicyLinkAndTermsOfService() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(5),
      child: Center(
          child: Text.rich(TextSpan(
              text: 'By continuing, you agree to our ',
              style: TextStyle(fontSize: 16, color: Colors.black),
              children: <TextSpan>[
            TextSpan(
                text: 'Terms of Service',
                style: TextStyle(
                  fontSize: 16,
                  color: appColor,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    showModal(
                      context: context,
                      configuration: FadeScaleTransitionConfiguration(),
                      builder: (context) {
                        return PolicyDialog(
                          mdFileName: 'terms_and_conditions.md',
                          contextPolicy: context,
                        );
                      },
                    );
                  }),
            TextSpan(
                text: ' and ',
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                          fontSize: 16,
                          color: appColor,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return PolicyDialog(
                                contextPolicy: context,
                                mdFileName: 'privacy_policy.md',
                              );
                            },
                          );
                        })
                ])
          ]))),
    );
  }
}
