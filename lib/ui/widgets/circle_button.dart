import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CircleButton extends StatelessWidget {

  final String assetPath;
  final String text;
  final VoidCallback onTap;
  final Color color;
  final Color colorBorder;

  CircleButton(
      {@required this.assetPath,
      @required this.text,
      @required this.onTap,
      @required this.color,
        @required this.colorBorder});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorBorder,
                  width: 2.0,
                ),
              ),
              child: CircleAvatar(
                  backgroundColor: color,
                  child: Container(
                    width: 19,
                    height: 19,
                    child: SvgPicture.asset(
                      assetPath,
                    ),
                  ))),
          SizedBox(height: 8.0),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}
