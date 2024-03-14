import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nova/constant/global.dart';

class CustomToastError extends StatefulWidget {
  final String message1;
  final String message2;

  CustomToastError({@required this.message1, @required this.message2});

  @override
  _CustomToastErrorState createState() => _CustomToastErrorState();
}

class _CustomToastErrorState extends State<CustomToastError>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        _animationController.reverse();
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final popupHeight = widget.message2 != null ? 110.0 : 65.0;
    final animationOffset = screenHeight - popupHeight;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0.0, animationOffset * (1.0 - _animation.value)),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: popupHeight,
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: boxErrorBGColor,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: boxErrorBGColor,
                  width: 1.0,
                ),
                shape: BoxShape.rectangle, // Set the shape to rectangle
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    child: SvgPicture.asset(
                      'assets/images/eyeerror.svg',
                      fit: BoxFit.fill,
                    ),
                  ),
                  SizedBox(width: 15.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.message1,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        widget.message2 != null
                            ? SizedBox(height: 5.0)
                            : SizedBox(
                                height: 0,
                              ),
                        widget.message2 != null
                            ? Text(
                                widget.message2,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                ),
                              )
                            : SizedBox(
                                height: 0,
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
