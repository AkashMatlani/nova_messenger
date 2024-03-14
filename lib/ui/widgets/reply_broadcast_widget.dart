import 'dart:io';
import 'package:flutter_svg/svg.dart';
import 'package:nova/models/broadcasts.dart';
import 'package:nova/ui/widgets/bubble5new.dart';
import 'package:nova/ui/widgets/bubbletype.dart';
import 'package:path/path.dart' as path;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';

class ReplyBroadcastWidget extends StatelessWidget {
  final Broadcast message;
  final VoidCallback onCancelReply;
  final BuildContext context;
  final bool isPeer;

  const ReplyBroadcastWidget({
    @required this.message,
    this.onCancelReply,
    this.context,
    this.isPeer,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
          child: Container(
        child: Row(
          children: [
            Container(
              color: appColor,
              width: 4,
            ),
            buildReplyMessage(),
          ],
        ),
      ));

  String sepText(String text, int n) {
    String result = '';

    int currentIndex = 0;

    while (currentIndex < text.length) {
      if (currentIndex % n == 0 && currentIndex != 0) result += '\n';
      result += text[currentIndex];
      currentIndex++;
    }

    return result;
  }

  Widget buildReplyMessage() => IntrinsicHeight(
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
          ),
          margin: EdgeInsets.only(left: 8, bottom: 8, right: 4, top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${message.listUserName}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: !isPeer ? Colors.black87 : Colors.white),
              ),
              const SizedBox(height: 4),
              message.contentType == "text"
                  ? Text(
                      sepText(message.content, 30),
                      style: TextStyle(
                          color: !isPeer ? Colors.black87 : Colors.white),
                    )
                  : message.contentType == "image"
                      ? myImageWidget(
                          ChatBubbleClipper5New(
                              type: BubbleTypeNew.receiverBubble),
                          chatLeftColor,
                          chatLeftTextColor,
                          message.file,
                          message.star,
                          message.insertedAt,
                          message.status,
                          0,
                          message.fromUuid,
                          message)
                      : message.contentType == "video"
                          ? myVideoWidget(
                              ChatBubbleClipper5New(
                                  type: BubbleTypeNew.receiverBubble),
                              chatLeftColor,
                              chatLeftTextColor,
                              message.file,
                              message.savedImage,
                              message.insertedAt,
                              message.status,
                              0,
                              message.fromUuid,
                              message)
                          : message.contentType == "file"
                              ? myFileWidget(
                                  ChatBubbleClipper5New(
                                      type: BubbleTypeNew.receiverBubble),
                                  chatLeftColor,
                                  chatLeftTextColor,
                                  message.file,
                                  message.star,
                                  message.insertedAt,
                                  message.status,
                                  0,
                                  message.fromUuid,
                                  context,
                                  message)
                              : message.contentType == "audio"
                                  ? myVoiceWidget(
                                      context,
                                      ChatBubbleClipper5New(
                                          type: BubbleTypeNew.receiverBubble),
                                      message.file,
                                      message.star,
                                      message.insertedAt,
                                      message.status,
                                      0,
                                      message.fromUuid,
                                      false,
                                      message)
                                  : Container()
            ],
          )));

  myVideoWidget(CustomClipper clipper, chatRightColor, chatRightTextColor,
      content, savedImage, timeStamp, read, index, id, Broadcast message) {
    return FutureBuilder<String>(
        future: getImageThumb(message.file),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.62,
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.video_call,
                        color: isPeer ? Colors.white : Colors.black87,
                        size: 20.0,
                      ),
                      SizedBox(width: 50),
                      Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            height: 80,
                            width: 80,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: Center(
                                  child: Container(
                                    color: !isPeer ? Colors.white : appColor,
                                    width: SizeConfig.screenWidth,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        savedImage != null
                                            ? Image.file(
                                                File(snapshot.data),
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                height: 80,
                                                width: 0,
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )),
                    ]));
          } else {
            return Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.62,
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.video_call,
                        color: isPeer ? Colors.white : Colors.black87,
                        size: 20.0,
                      ),
                      Container(
                        height: 80,
                        width: 80,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: Center(
                              child: Container(
                                color: !isPeer ? Colors.white : appColor,
                                width: SizeConfig.screenWidth,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    savedImage != null
                                        ? CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl: savedImage,
                                            placeholder: (context, url) =>
                                                Container(
                                                  height: 80,
                                                  width: 0,
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                                      height: 80,
                                                      width: 0,
                                                    ))
                                        : Container(
                                            height: 80,
                                            width: 0,
                                          ),
                                    Icon(
                                      Icons.play_circle,
                                      size: 20,
                                      color: isPeer
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]));
          }
        });
  }

  Widget myVoiceWidget(BuildContext context, CustomClipper clipper, content,
      star, timeStamp, read, index, id, isPeer, Broadcast message) {
    return FutureBuilder<String>(
        future: getSoundDuration(message.file),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Flexible(
                child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.5,
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.mic,
                            color: !isPeer ? Colors.white : Colors.black87,
                            size: 20.0,
                          ),
                          Text(
                            "Voice message",
                            style: TextStyle(
                              color: !isPeer ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.normal,
                              fontSize: 13.0,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "(" + snapshot.data.toString() + ")",
                            style: TextStyle(
                              color: !isPeer ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.normal,
                              fontSize: 13.0,
                            ),
                          )
                        ])));
          } else {
            return Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.5,
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.mic,
                        color: !isPeer ? Colors.black87 : Colors.white,
                        size: 20.0,
                      ),
                      Text(
                        "Voice message",
                        style: TextStyle(
                          color: !isPeer ? Colors.black87 : Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 13.0,
                        ),
                      )
                    ]));
          }
        });
  }

  Widget myFileWidget(CustomClipper clipper, chatRightColor, chatRightTextColor,
      content, star, timeStamp, read, index, id, context, Broadcast message) {
    return Expanded(
        child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  !content.contains(".pdf")
                      ? Icon(
                          Icons.note,
                          size: 20,
                          color: isPeer ? Colors.white : Colors.black87,
                        )
                      : SvgPicture.asset(
                          'assets/images/filepdf.svg',
                          fit: BoxFit.fill,
                        ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                      child: Text(
                    path.basename(content).substring(0, 30),
                    style: TextStyle(
                      color: isPeer ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.normal,
                      fontSize: 13.0,
                    ),
                  )),
                ])));
  }

  Widget myImageWidget(
      CustomClipper clipper,
      chatRightColor,
      chatRightTextColor,
      content,
      star,
      timeStamp,
      read,
      index,
      id,
      Broadcast message) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                child: CachedNetworkImage(
                  width: 50,
                  height: 50,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    )),
                  ),
                  placeholder: (context, url) => Container(
                    width: 5.0,
                    height: 5.0,
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(appColor),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Material(
                    child: Center(child: Text("Not Available")),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),
                  imageUrl: content,
                  fit: BoxFit.cover,
                ),
              )),
        ]);
  }
}
