import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_walkthrough_screen/flutter_walkthrough_screen.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:nova/ui/intro.dart';
import 'package:url_launcher/url_launcher.dart';

class OnBoarding extends StatefulWidget {

  @override
  _OnBoardingState createState() => _OnBoardingState();

}

class _OnBoardingState extends State<OnBoarding> {

  final List<OnbordingData> list = [
    OnbordingData(
      image: AssetImage("assets/walkthrough/hand_nova.png"),
      imageHeight: 152,
      fit: BoxFit.fitHeight,
      titleText: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          children: [],
        ),
      ),
      descText: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          children: [
            TextSpan(
              text: "Welcome to ",
              style: TextStyle(
                fontFamily: "DMSans-Regular",
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 28.0,
              ),
            ),
            TextSpan(
              text: "\nNova messenger ",
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: "DMSans-Regular",
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text:
              "\n\nFast, effective messaging at your fingertips with a focus on privacy and security",
              style: TextStyle(
                color: Colors.black,
                fontFamily: "DMSans-Regular",
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
      descPadding: EdgeInsets.symmetric(horizontal: 22.0),
    ),
    OnbordingData(
      image: AssetImage("assets/walkthrough/connection.png"),
      imageHeight: 152,
      fit: BoxFit.fitHeight,
      titleText: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          children: [],
        ),
      ),
      descText: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          children: [
            TextSpan(
              text: "A world first",
              style: TextStyle(
                color: Colors.black,
                fontFamily: "DMSans-Regular",
                fontWeight: FontWeight.bold,
                fontSize: 28.0,
              ),
            ),
            TextSpan(
              text:
              "\n\nUnlimited group and broadcast list creation, a world first!",
              style: TextStyle(
                color: Colors.black,
                fontFamily: "DMSans-Regular",
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
      descPadding: EdgeInsets.symmetric(horizontal: 22.0),
    ),
    OnbordingData(
      titleText: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          children: [],
        ),
      ),
      image: AssetImage("assets/walkthrough/protection.png"),
      imageHeight: 152,
      fit: BoxFit.fitHeight,
      descText: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          children: [
            TextSpan(
              text: "Security and Privacy",
              style: TextStyle(
                color: Colors.black,
                fontFamily: "DMSans-Regular",
                fontWeight: FontWeight.bold,
                fontSize: 28.0,
              ),
            ),
            TextSpan(
              text:
              "\n\nDon’t worry about your data privacy, Nova messenger protects you and your data, with the highest priority focused on data security and integrity.",
              style: TextStyle(
                color: Colors.black,
                fontFamily: "DMSans-Regular",
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      descPadding: EdgeInsets.symmetric(horizontal: 22.0),
    ),
    OnbordingData(
      titleText: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          children: [],
        ),
      ),
      image: AssetImage("assets/walkthrough/speed.png"),
      imageHeight: 152,
      fit: BoxFit.fitHeight,
      descText: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          children: [
            TextSpan(
              text: "Fast and efficient",
              style: TextStyle(
                color: Colors.black,
                fontFamily: "DMSans-Regular",
                fontWeight: FontWeight.bold,
                fontSize: 28.0,
              ),
            ),
            TextSpan(
              text:
              "\n\nNova messenger delivers messages fast and effectively and ensures all your university, school, or work announcements reach you instantly.",
              style: TextStyle(
                color: Colors.black,
                fontFamily: "DMSans-Regular",
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      descPadding: EdgeInsets.symmetric(horizontal: 22.0),
    ),
    OnbordingData(
      titleText: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          children: [],
        ),
      ),
      image: AssetImage("assets/walkthrough/present.png"),
      imageHeight: 152,
      fit: BoxFit.fitHeight,
      descText: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          children: [
            TextSpan(
              text: "Rewards",
              style: TextStyle(
                color: Colors.black,
                fontFamily: "DMSans-Regular",
                fontWeight: FontWeight.bold,
                fontSize: 28.0,
              ),
            ),
            TextSpan(
              text: "\n\nThe first messenger application to reward its users.",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontFamily: "DMSans-Regular",
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      descPadding: EdgeInsets.symmetric(horizontal: 22.0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
            padding: EdgeInsets.only(left: 14, top: 2),
            child: SvgPicture.asset(
              'assets/images/intrologo.svg',
              fit: BoxFit.contain,
            )), // Icon on the left
        actions: [
          GestureDetector(
            onTap: () {
              _launchURL("https://www.novamessenger.com/privacy.html");
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 16),
              child: Text(
                'Privacy',
                style: TextStyle(
                    color: appColor,
                    fontSize: 12,
                    fontFamily: 'DMSans-Regular'),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.66,
            width: MediaQuery.of(context).size.width,
            child: IntroScreen(
              onbordingDataList: list,
              colors: [],
              pageRoute: MaterialPageRoute(
                builder: (context) => Intro(),
              ),
              selectedDotColor: Colors.black,
              unSelectdDotColor: Colors.grey,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ButtonStyle(
                fixedSize: MaterialStateProperty.all<Size>(const Size(150, 48)),
                elevation: MaterialStateProperty.all<double>(0),
                backgroundColor: MaterialStateProperty.all<Color>(appColor)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Intro()),
              );
            },
            child: Text("Let's get started",style: TextStyle(
              color: Colors.white,
              fontFamily: "DMSans-Regular",
              fontWeight: FontWeight.normal,
              fontSize: 16.0,
            ),),
          ),
        ),
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
