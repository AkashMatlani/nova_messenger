import 'package:flutter/material.dart';
import 'package:nova/constant/global.dart';

class IconWithText extends StatelessWidget {

  final IconData icon;
  final String text;

  IconWithText({@required this.icon, @required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Colors.black,
        ),
        SizedBox(height: 8),
        Text(text,style: TextStyle(color: notiGrey)),
      ],
    );
  }
}