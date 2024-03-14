import 'package:flutter/material.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';

class HelpOptions extends StatefulWidget {
  @override
  HelpOptionsState createState() {
    return new HelpOptionsState();
  }
}

class HelpOptionsState extends State<HelpOptions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColorWhite,
        title: Text(
          "Help",
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
                color: Colors.white,
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
                                    'FAQ',
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
                              Icons.arrow_forward_ios,
                              color: appColorGrey,
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
                                    'Tearms and privacy policy',
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
                              Icons.arrow_forward_ios,
                              color: appColorGrey,
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
                                    'App info',
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
                              Icons.arrow_forward_ios,
                              color: appColorGrey,
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
