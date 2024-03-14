import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nova/constant/global.dart';

class IconWithTextHorizontal extends StatelessWidget {

  final String path;
  final String text;

  IconWithTextHorizontal({@required this.path, @required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(path,
          color: notiRed,
        ),
        SizedBox(width: 8),
        Text(text, style: TextStyle(color: notiRed)),
      ],
    );
  }
}