import 'package:flutter/material.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';

class AppTheme extends StatefulWidget {
  @override
  AppThemeState createState() {
    return new AppThemeState();
  }
}

class AppThemeState extends State<AppTheme> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColorWhite,
        title: Text(
          "Theme",
          style: TextStyle(
              fontFamily: "DMSans-Regular", fontSize: 17, color: appColorBlack),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: appColor,
            )),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Container(
                color: appColorWhite,
                child: Column(
                  children: <Widget>[
                    Container(
                      height: SizeConfig.blockSizeVertical * 6.4,
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(width: 15),
                                  new Text(
                                    'Light Theme',
                                    style: new TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Icon(
                              Icons.check,
                              color: appColor,
                              size: 20,
                            ),
                          ),
                          Container(width: 10)
                        ],
                      ),
                    ),
                    Container(
                      height: 0.5,
                      color: Colors.grey[400],
                    ),
                    Container(
                      height: SizeConfig.blockSizeVertical * 6.4,
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(width: 15),
                                  new Text(
                                    'Dark Theme',
                                    style: new TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 0.5,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
