import 'package:flutter/material.dart';

class UserProfilePic extends StatelessWidget {
  
  final String image;
  final double picSize;

  const UserProfilePic({Key key, this.image, this.picSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: picSize,
      width: picSize,
      decoration: BoxDecoration(
          shape: BoxShape.circle, border: Border.all(color: Colors.grey)),
      child: image != null
          ? Container(
        margin: const EdgeInsets.all(2),
        height:30,
        width: 30,
        //  size.height * 0.35,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                image: NetworkImage(image), fit: BoxFit.cover)),
      )
          : Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(2),
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(Icons.image)),

    );
  }
}