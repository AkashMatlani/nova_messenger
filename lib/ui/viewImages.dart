import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/models/contact_data.dart';

// ignore: must_be_immutable
class ViewImages extends StatefulWidget {
  List<dynamic> images;
  int number;
  ContactData peerData;

  ViewImages({this.images, this.number, this.peerData});

  @override
  State<StatefulWidget> createState() {
    return _ViewImagesState();
  }
}

class _ViewImagesState extends State<ViewImages> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).brightness != Brightness.dark
          ? Colors.grey[100]
          : novaDarkModeBlue,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).brightness != Brightness.dark
            ? Colors.white
            : novaDarkModeBlue,
        title: Text(
          widget.peerData != null ? widget.peerData.name : "",
          style: TextStyle(
              fontFamily: "DMSans-Regular",
              fontSize: 17,
              color: Theme.of(context).brightness != Brightness.dark
                  ? Colors.black
                  : Colors.white),
        ),
        centerTitle: false,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).brightness == Brightness.dark
                  ? appColor
                  : Colors.black,
            )),
      ),
      body: Stack(
        children: [
          CarouselSlider(
            options: CarouselOptions(
                initialPage: widget.number,
                height: height,
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                }
                // autoPlay: false,
                ),
            items: widget.images
                .map((item) => Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: CachedNetworkImage(
                        placeholder: (context, url) =>
                            Center(child: CupertinoActivityIndicator()),
                        errorWidget: (context, url, error) => Material(
                          child: Center(
                              child: Icon(
                            CupertinoIcons.photo,
                            color: Colors.grey,
                          )),
                          clipBehavior: Clip.hardEdge,
                        ),
                        imageUrl: item,
                        fit: BoxFit.contain,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
