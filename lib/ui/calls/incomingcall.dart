import 'package:flutter/material.dart';
import 'package:nova/helper/sizeconfig.dart';

class InComingCall extends StatefulWidget {
  @override
  _InComingCallState createState() => _InComingCallState();
}

class _InComingCallState extends State<InComingCall> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      decoration: BoxDecoration(
        color: Color(0XFF106C6F),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment(
                0.8, 0.0), // 10% of the width, so there are ten blinds.
            colors: [
              const Color(0xFF9E7977),
              const Color(0xFFB9CCBC),
            ], // whitish to gray
            // tileMode: TileMode.repeated, // repeats the gradient over the canvas
          ),
        ),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: new AppBar(
              title: new Text(
                "Nova Voice Call",
                style: TextStyle(color: Colors.black),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
                tooltip: 'Increase volume by 10',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: LayoutBuilder(builder: (context, constraint) {
              return Container(
                child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraint.maxHeight),
                    child: IntrinsicHeight(
                      child: Container(
                        height: SizeConfig.screenHeight,
                        width: SizeConfig.screenWidth,
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 70),
                              child: Column(
                                children: <Widget>[
                                  Center(
                                    child: Text(
                                      'Alexendra Graby',
                                      style: TextStyle(
                                          fontSize:
                                              SizeConfig.safeBlockHorizontal *
                                                  5,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      'Calling +91740587989',
                                      style: TextStyle(
                                          fontSize:
                                              SizeConfig.safeBlockHorizontal *
                                                  3.5,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 200),
                                child: Container(
                                  height: 150,
                                  width: 150,
                                  child: CircleAvatar(
                                    foregroundColor:
                                        Theme.of(context).primaryColor,
                                    backgroundColor: Colors.grey,
                                    backgroundImage: new AssetImage(
                                        'assets/images/man1.jpg'),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 150),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/images/Video_calling_icon.png',
                                      height: 100,
                                      width: 100,
                                    ),
                                    Image.asset(
                                      'assets/images/Video_calling_icon.png',
                                      height: 100,
                                      width: 100,
                                    ),
                                    Image.asset(
                                      'assets/images/Mic_off_icon.png',
                                      height: 100,
                                      width: 100,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 50),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/images/Call_end_icon.png',
                                      height: 100,
                                      width: 100,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              );
            })),
      ),
    );
  }
}
