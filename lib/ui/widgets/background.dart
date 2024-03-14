import 'package:flutter/material.dart';
import 'package:nova/constant/global.dart';

class Background extends StatelessWidget {
  final Widget child;

  const Background({
    Key key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness != Brightness.dark
            ? chatBackgroundColor
            : Colors.transparent,
        image: DecorationImage(
          image: AssetImage("assets/images/chatbg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(alignment: Alignment.center, children: <Widget>[child]),
    );
  }
}
