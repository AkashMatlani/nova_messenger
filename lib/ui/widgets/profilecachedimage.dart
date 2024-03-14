import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:nova/helper/sizeconfig.dart';

class ProfileCachedNetworkImage extends StatelessWidget {

  final String imageUrl;
  final double size;

  const ProfileCachedNetworkImage({
    Key key,
    @required this.imageUrl,@required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
            child: CircleAvatar(
              radius: size,
              child: CachedNetworkImage(
                placeholder: (context, url) => Container(
                  child: CupertinoActivityIndicator(),
                  width: size,
                  height: size,
                  color: Colors.white,
                  padding: EdgeInsets.all(0),
                ),
                errorWidget: (context, url, error) => Material(
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                        color: Colors.white,
                        height: 100,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.grey,
                        ),
                      )),
                  borderRadius: BorderRadius.all(
                    Radius.circular(0),
                  ),
                  clipBehavior: Clip.hardEdge,
                ),
                imageUrl: imageUrl,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 0.5),
                    shape: BoxShape.circle,
                    color: Colors.white,
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                width: SizeConfig.screenWidth,
                fit: BoxFit.cover,
              ), //Text
            ));
  }
}
