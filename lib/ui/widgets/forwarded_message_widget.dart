import 'package:flutter/material.dart';

class ForwardingWidget extends StatefulWidget {
  final bool isForwarded;

  ForwardingWidget(this.isForwarded);

  @override
  _ForwardingWidgetState createState() => _ForwardingWidgetState();
}

class _ForwardingWidgetState extends State<ForwardingWidget> {
  @override
  Widget build(BuildContext context) {
    return (widget.isForwarded != null && widget.isForwarded)
        ? Container(
            width: 130,
            height: 40,
            child: Row(
              children: [
                Icon(
                  Icons.forward,
                  color: Colors.grey,
                ),
                SizedBox(width: 8),
                Text(
                  "Forwarded",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ))
        : Container();
  }
}
