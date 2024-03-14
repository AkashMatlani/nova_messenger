import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nova/constant/global.dart';

class IconSvGWithText extends StatelessWidget {

  final String path;
  final String text;

  IconSvGWithText({@required this.path, @required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(path,
          color: Theme.of(context).brightness ==
              Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        SizedBox(height: 8),
        Text(text,style: TextStyle(color: Theme.of(context).brightness ==
            Brightness.dark
            ? Colors.white
            : notiGrey)),
      ],
    );
  }
}