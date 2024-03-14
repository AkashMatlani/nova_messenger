import 'package:animations/animations.dart';
import 'package:flutter/gestures.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/services/services_locator.dart';
import 'package:flutter/material.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:nova/provider/get_phone.dart';
import 'package:flutter/scheduler.dart';
import 'package:nova/ui/terms/policy_dialog.dart';
import 'package:nova/utils/hive_preferences.dart';

class Intro extends StatefulWidget {
  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  HttpService _api = serviceLocator<HttpService>();
  bool isLoading = true;
  bool hasRegistered = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => registerUser());
  }

  void registerUser() async {
    var registerResponse = await _api.registerUser();
    if (registerResponse != null) {
      if (mounted) {
        setState(() {
          hasRegistered = true;
          isLoading = false;
        });
      }
    } else {
      // TODO - Show fail for user /
      if (mounted) {
        setState(() {
          hasRegistered = true;
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: LayoutBuilder(builder: (context, constraint) {
          return SingleChildScrollView(
            child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraint.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 10,
                      ),
                      Expanded(
                        child: Container(
                          height: 130,
                          width: double.infinity,
                          decoration: BoxDecoration(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 100,
                                width: 100,
                                child: Image.asset(
                                  'assets/images/applogo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                              color: appColor,
                            ))
                          : hasRegistered
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 50),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 30,
                                        top: 0,
                                        left: 30,
                                        bottom: 10),
                                    child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                              fixedSize: MaterialStateProperty.all<Size>(const Size(400, 48)),
                                              elevation: MaterialStateProperty.all<double>(0),
                                              backgroundColor: MaterialStateProperty.all<Color>(appColor)),
                                          onPressed: () {
                                            showModal(
                                              context: context,
                                              configuration:
                                              FadeScaleTransitionConfiguration(),
                                              builder: (context) {
                                                return PolicyDialog(
                                                  mdFileName:
                                                  'privacy_policy.md',
                                                  contextPolicy: context,
                                                );
                                              },
                                            ).whenComplete(() {
                                              _checkTerms();
                                            });
                                          },
                                          child: Text("Get started"),
                                        ),
                                      ),
                                    ),
                                )
                              : Center(
                                  child: Column(
                                  children: [
                                    Container(
                                        child: Padding(
                                      padding: EdgeInsets.all(50),
                                      child: Center(
                                          child: Text(
                                              "Error with app registration. Please check your connection and retry.")),
                                    )),
                                    Container(
                                      height: SizeConfig.blockSizeVertical * 6,
                                      width:
                                          SizeConfig.blockSizeHorizontal * 70,
                                      // ignore: deprecated_member_use
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          registerUser();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          primary: appColor,
                                          onPrimary: Colors.white,
                                        ),
                                        child: Text(
                                          "Retry registration".toUpperCase(),
                                          style: TextStyle(
                                            fontSize: SizeConfig.blockSizeHorizontal * 3,
                                            fontFamily: "DMSans-Regular",
                                            color: appColorWhite,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 10,
                      ),
                      Padding(
                          padding: EdgeInsets.all(18),
                          child: privacyPolicyLinkAndTermsOfService()),
                    ],
                  ),
                )),
          );
        }));
  }

  Widget privacyPolicyLinkAndTermsOfService() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(8),
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

  _checkTerms() async {
    final preferences = await HivePreferences.getInstance();
    if (preferences.getTermsAcceptance())
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhoneAuthGetPhone(),
        ),
      );
  }
}
