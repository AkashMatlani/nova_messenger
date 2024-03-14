import 'dart:async';
import 'package:agconnect_auth/agconnect_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as authFire;
import 'package:nova/provider/get_phone.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/provider/countries.dart';
import 'package:nova/ui/registration/studentrequest.dart';
import 'package:nova/utils/commons.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';

class PhoneAuthVerify extends StatefulWidget {
  final Color cardBackgroundColor = Color(0xFFFCA967);
  final String appName = "Nova Messenger";

  @override
  _PhoneAuthVerifyState createState() => _PhoneAuthVerifyState();
}

class _PhoneAuthVerifyState extends State<PhoneAuthVerify> {

  BuildContext scaffoldContext;
  String code = "";
  int endTime;

  var _authCredential;
  String _actualCode;

  @override
  void initState() {
    endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 120;
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          automaticallyImplyLeading: true,
        ),
        body: Builder(builder: (BuildContext context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ListView(
                  children: <Widget>[
                    Padding(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 50),
                        child: Text(
                          'Verification number',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: "DMSans-Regular",
                              fontSize: 28),
                        )),
                    SizedBox(height: 50.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20, left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enter 6 digits verification code sent to',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontFamily: "DMSans-Regular",
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  mobNo,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontFamily: "DMSans-Regular",
                                    color: appColor,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 42.0),
                      ],
                    ),
                    SizedBox(height: 60.0),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 30),
                        child: PinCodeTextField(
                          appContext: context,
                          pastedTextStyle: TextStyle(
                            color: appColor,
                            fontWeight: FontWeight.bold,
                          ),
                          length: 6,
                          obscureText: false,
                          obscuringCharacter: '*',
                          blinkWhenObscuring: true,
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            activeColor: appColor,
                            borderRadius: BorderRadius.circular(5),
                            fieldHeight: 50,
                            fieldWidth: 40,
                            inactiveFillColor: appColor,
                            inactiveColor: appColor,
                            selectedColor: appColor,
                            activeFillColor: Colors.white,
                          ),
                          cursorColor: appColor,
                          animationDuration: const Duration(milliseconds: 300),
                          enableActiveFill: false,
                          controller: textEditingController,
                          keyboardType: TextInputType.number,
                          onCompleted: (v) {
                            signIn();
                          },
                          onChanged: (value) {
                            debugPrint(value);
                            setState(() {
                              code = value;
                            });
                          },
                          beforeTextPaste: (text) {
                            return true;
                          },
                        )),
                    SizedBox(height: 32.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CountdownTimer(
                          endTime: endTime,
                          widgetBuilder: (BuildContext context,
                              CurrentRemainingTime time) {
                            if (time == null) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      startPhoneAuth();
                                    },
                                    child: Text(
                                      'Resend SMS',
                                      style: TextStyle(
                                          color: appColor,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16),
                                    ),
                                  ),
                                ],
                              );
                            }
                            List<Widget> list = [];

                            if (time.min != null) {
                              list.add(Row(
                                children: <Widget>[
                                  Text(time.min.toString()),
                                  Text(":"),
                                ],
                              ));
                            }
                            if (time.sec != null) {
                              list.add(Row(
                                children: <Widget>[
                                  Text(time.sec.toString()),
                                ],
                              ));
                            }
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: list,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }));
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

  signIn() async {
    if (code.length != 6) {
      Commons.novaFlushBarError(context, "Invalid OTP");
    }
    if (await isHuawei()) {
      var countryProvider =
          Provider.of<CountryProvider>(context, listen: false);
      String phoneNumber = mobNo;
      if (phoneNumber[0] == "0") {
        phoneNumber = phoneNumber.substring(1);
      }
      AGCAuthCredential credential = PhoneAuthProvider.credentialWithVerifyCode(
          countryProvider.selectedCountry.dialCode.replaceAll("+", ""),
          phoneNumber,
          code);
      AGCAuth.instance.signIn(credential).then((signInResult) {
        AGCUser user = signInResult.user;
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => StudentRequest(mobNo)));
      }).catchError((error) {
        Commons.novaFlushBarError(context, "Verification OTP failed.");
      });
    } else {
      _authCredential = authFire.PhoneAuthProvider.credential(
        smsCode: code,
        verificationId: _actualCode,
      );
      try {
        await auth.signInWithCredential(_authCredential);
      } on Exception catch (e) {
        Commons.novaFlushBarError(context,
            'Something has gone wrong, issue with your OTP. Please recheck and try again.');
      }
    }
  }

  onAutoRetrievalTimeOut() {
    _showSnackBar(context, "PhoneAuth auto-retrieval timeout");
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => PhoneAuthGetPhone()));
    });
  }

  startPhoneAuth() async {
    if (await isHuawei()) {
      checkIsUserSignedIn(context);
    } else {
      _startAuth();
    }
  }

  void checkIsUserSignedIn(BuildContext context) {
    var countryProvider = Provider.of<CountryProvider>(context, listen: false);
    AGCAuth.instance.currentUser.then((user) {
      if (user != null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => StudentRequest(mobNo)));
      } else {
        requestHuaweiCode(
            context,
            countryProvider.selectedCountry.dialCode.replaceAll("+", ""),
            phoneNumberController.text);
      }
    });
  }

  void requestHuaweiCode(
      BuildContext context, String countryCode, String phoneNumber) {
    VerifyCodeSettings settings =
        VerifyCodeSettings(VerifyCodeAction.registerLogin, sendInterval: 15);
    PhoneAuthProvider.requestVerifyCode(countryCode, phoneNumber, settings)
        .then((result) {
      Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (BuildContext context) => PhoneAuthVerify()));
    }).catchError((error) {
      Commons.novaFlushBarError(context, "Requested verification code failed.");
    });
  }

  _startAuth() {
    final authFire.PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      _actualCode = verificationId;
      cCode = code;
    };

    final authFire.PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _actualCode = verificationId;
    };

    final authFire.PhoneVerificationFailed verificationFailed =
        (authFire.FirebaseAuthException authException) {
      if (authException.message.contains('not authorized'))
        Commons.novaFlushBarError(context, 'App not authorized');
      else if (authException.message.contains('Network'))
        Commons.novaFlushBarError(context, 'Please check your internet connection and try again');
      else
        Commons.novaFlushBarError(
            context,
            'Phone authentication failed ' +
                authException.message);
      Timer(Duration(seconds: 3), () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => PhoneAuthGetPhone()));
      });
    };

    final authFire.PhoneVerificationCompleted verificationCompleted =
        (authFire.AuthCredential auth) async {
      // await auth.signInWithCredential(auth).then((user) async {
      //   if (user != null) {
      //     Navigator.of(context).pushReplacement(MaterialPageRoute(
      //         builder: (BuildContext context) => StudentRequest(mobNo)));
      //   } else {
      //     _showSnackBar(context, "Phone authentication failed");
      //     Timer(Duration(seconds: 3), () {
      //       Navigator.of(context).pushReplacement(MaterialPageRoute(
      //           builder: (BuildContext context) => PhoneAuthGetPhone()));
      //     });
      //   }
      // }).catchError((error) {
      //   Commons.novaFlushBarError(context,'Something has gone wrong, please try later $error');
      // });
    };

    auth.verifyPhoneNumber(
        phoneNumber: mobNo.toString(),
        timeout: Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout)
        .then((value) {
      _showSnackBar(context, "OTP sent");
    }).catchError((error) {
      Commons.novaFlushBarError(
          context, 'Something has gone wrong, please try later $error');
    });
  }
}
