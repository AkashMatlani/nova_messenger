import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nova/ui/fullScreenvideo.dart';
import 'package:nova/ui/videoview.dart';
import 'package:nova/ui/viewImages.dart';
import 'package:nova/constant/global.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/contact_data.dart';

// ignore: must_be_immutable
class MediaScreen extends StatefulWidget {
  var imageMedia;
  var videoMedia;
  var docsMedia;
  ContactData peerData;

  MediaScreen(
      {this.imageMedia, this.videoMedia, this.docsMedia, this.peerData});

  @override
  ContactInfoState createState() {
    return new ContactInfoState();
  }
}

TabController tabController;

class ContactInfoState extends State<MediaScreen>
    with SingleTickerProviderStateMixin {
  List imageMedia = [];
  List videoMedia = [];
  List docsMedia = [];

  bool viewImage = true;
  bool viewVideo = false;
  bool viewDocs = false;

  @override
  void initState() {
    tabController = new TabController(length: 3, vsync: this);
    imageMedia = [];
    videoMedia = [];
    docsMedia = [];
    imageMedia.addAll(widget.imageMedia);
    videoMedia.addAll(widget.videoMedia);
    docsMedia.addAll(widget.docsMedia);

    super.initState();
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          widget.peerData != null ? widget.peerData.name : "Media",
          style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 18),
        ),
        centerTitle: false,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).brightness == Brightness.dark
                  ? appColor
                  : Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, value) {
          return [
            SliverToBoxAdapter(
              child: TabBar(
                controller: tabController,
                labelColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: appColor,
                tabs: [
                  Tab(icon: Text("Image")),
                  Tab(icon: Text("Video")),
                  Tab(icon: Text("Docs")),
                ],
              ),
            ),
          ];
        },
        body: Container(
          child: TabBarView(
            controller: tabController,
            children: <Widget>[
              myImages(),
              myVideo(),
              myDocs(),
            ],
          ),
        ),
      ),
    );
  }

  Widget myImages() {
    if (imageMedia.length > 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.all(5),
          itemCount: imageMedia.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 200 / 200,
          ),
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.all(5.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => ViewImages(
                        images: imageMedia,
                        number: index,
                        peerData: widget.peerData,
                      ),
                    ),
                  );
                },
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CupertinoActivityIndicator(),
                    width: 35.0,
                    height: 35.0,
                    padding: EdgeInsets.all(10.0),
                  ),
                  errorWidget: (context, url, error) => Material(
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),
                  imageUrl: imageMedia[index],
                  width: 35.0,
                  height: 35.0,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Center(child: Text("No Images"));
    }
  }

  Widget myVideo() {
    if (videoMedia.length > 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: GridView.builder(
          shrinkWrap: true,
          //physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(5),
          itemCount: videoMedia.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 200 / 200,
          ),
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.all(5.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FullScreenVideo(video: videoMedia[index])),
                  );
                },
                child: Container(
                    child: VideoView(
                  url: videoMedia[index],
                  play: false,
                )),
              ),
            );
          },
        ),
      );
    } else {
      return Center(child: Text("No Videos"));
    }
  }

  Widget myDocs() {
    if (docsMedia.length > 0) {
      return Padding(
          padding: const EdgeInsets.only(left: 10, top: 10),
          child: ListView.builder(
            itemCount: docsMedia.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  _launchURL(
                    docsMedia[index],
                  );
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/images/docs.png',
                            height: 40,
                          ),
                          Container(width: 10),
                          Text(docsMedia[index]
                                  .substring(docsMedia[index].length - 20) +
                              ".doc"),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(height: 1, color: Colors.grey),
                    )
                  ],
                ),
              );
            },
          ));
    } else {
      return Center(child: Text("No Documents"));
    }
  }
}
