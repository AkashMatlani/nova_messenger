import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/models/message.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/ui/viewImages.dart';
import 'package:nova/ui/widgets/bubble5new.dart';
import 'package:nova/ui/widgets/reply_message_widget.dart';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:nova/ui/widgets/bubbletype.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:nova/ui/videoplayerscreen.dart';
import 'package:nova/ui/voice_notes_swipe/audio_bubble.dart';
import 'package:nova/utils/pdf_viewer.dart';
import 'package:nova/viewmodels/chat_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageWidget extends StatelessWidget {
  final MessagePhoenix message;
  final MessagePhoenix messageReply;
  final BuildContext context;
  final bool isMe;
  final String timestamp;
  final String read;
  final int index;
  final bool isGroup;

  const MessageWidget(
      {@required this.message,
      @required this.messageReply,
      @required this.context,
      @required this.isMe,
      @required this.timestamp,
      @required this.read,
      @required this.index,
      @required this.isGroup});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        ChatBubble(
            clipper: isMe
                ? ChatBubbleClipper5New(type: BubbleTypeNew.sendBubble)
                : ChatBubbleClipper5New(type: BubbleTypeNew.receiverBubble),
            elevation: 0,
            backGroundColor: isMe ? appColor : Colors.white,
            child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: buildMessage()))
      ],
    );
  }

  Widget buildMessage() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
              onTap: () => {handleScroll()},
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                      color: isMe ? userreplyBG : replyColor,
                      child: buildReplyMessage()))),
          messageWidget(),
          timeWidget(timestamp, read, chatRightTextColor, message.user.uuid),
        ]);
  }

  void handleScroll() {
    ChatViewModel viewModel = serviceLocator<ChatViewModel>();
    viewModel.handleHighLight(index, isGroup);
    itemGlobalScrollController.scrollTo(
        index: index,
        duration: Duration(milliseconds: 500),
        curve: Curves.linear);
  }

  Widget buildReplyMessage() {
    final replyMessage = messageReply;
    final isReplying = replyMessage != null;

    if (!isReplying) {
      return Container();
    } else {
      return Container(
        child: ReplyMessageWidget(
          message: replyMessage,
          isMe: isMe,
          context: context,
        ),
      );
    }
  }

  Widget timeWidget(timeStamp, read, chatRightTextColor, id) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          readTimestamp(
            DateTime.parse(
              converTime(timeStamp),
            ).millisecondsSinceEpoch,
          ),
          style: TextStyle(
              color: !isMe ? Colors.black87 : Colors.white,
              fontSize: 11,
              fontStyle: FontStyle.normal),
        ),
        Container(width: 3),
        id == userUuid
            ? read == "read"
                ? Icon(
                    Icons.done_all,
                    size: 17,
                    color: Colors.purpleAccent,
                  )
                : read == "sent"
                    ? Icon(
                        Icons.done,
                        size: 17,
                        color: chatRightTextColor,
                      )
                    : Icon(
                        Icons.done_all,
                        size: 17,
                        color: chatRightTextColor,
                      )
            : Container(),
      ],
    );
  }

  Widget messageWidget() {
    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          isMe == false
              ? Text(
                  '${message.user.name}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: chatFontLabelSize),
                )
              : Container(),
          const SizedBox(height: 8),
          message.contentType == "text"
              ? Text(
                  message.content,
                  style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: chatFontSize),
                )
              : message.contentType == "image"
                  ? myImageWidget(
                      ChatBubbleClipper5New(type: BubbleTypeNew.receiverBubble),
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
      ),
    );
  }

  myVideoWidget(CustomClipper clipper, chatRightColor, chatRightTextColor,
      content, savedImage, timeStamp, read, index, id, MessagePhoenix message) {
    return TextButton(
      onPressed: () async {
        Timer.run(() async {
          if (savedImage == "" || savedImage == null)
            await saveVideoImage(
                "GroupMessage", message.group.uuid, message, message.uuid);
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoNovaPlayer(url: content),
          ),
        );
        globalAmplitudeService?.sendAmplitudeData(
          'VideoPlayerTap',
          "Video player tapped.",
          true,
        );
      },
      style: TextButton.styleFrom(
        backgroundColor: chatRightColor,
        padding: EdgeInsets.zero,
      ),
      child: Container(
        height: 150,
        padding: EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(
            color: novaDarkModeBlue,
            borderRadius: BorderRadius.all(
              Radius.circular(4.0),
            ),
            border: Border.all(
              color: novaDarkModeBlue,
            )),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: FittedBox(
            fit: BoxFit.cover,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                    color: novaDarkModeBlue,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: novaDarkModeBlue,
                    )),
                width: SizeConfig.screenWidth,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    savedImage != null
                        ? CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: savedImage,
                            placeholder: (context, url) => Container(
                              height: 250,
                              width: 0,
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 250,
                              width: 0,
                            ),
                          )
                        : Container(
                            height: 250,
                            width: 0,
                          ),
                    Icon(
                      Icons.play_circle,
                      size: 60,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget myVoiceWidget(BuildContext context, CustomClipper clipper, content,
      star, timeStamp, read, index, id, isPeer, MessagePhoenix message) {
    return Container(
        decoration:
            BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: AudioBubble(
                    filepath: content,
                    key: ValueKey(content),
                    isPeer: isPeer,
                    uuid: timeStamp,
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Widget myFileWidget(
      CustomClipper clipper,
      chatRightColor,
      chatRightTextColor,
      content,
      star,
      timeStamp,
      read,
      index,
      id,
      context,
      MessagePhoenix message) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: TextButton(
        onPressed: () {
          if (content.contains(".pdf")) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PdfViewScreen(content)),
            );
          } else {
            launchUrl(content);
          }
        },
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.all(0)),
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: !content.contains(".pdf")
                          ? Icon(
                              Icons.note,
                              color: !isMe ? Colors.black87 : Colors.white,
                            )
                          : SvgPicture.asset(
                              'assets/images/filepdf.svg',
                              fit: BoxFit.fill,
                            )),
                  Container(
                    width: 5,
                  ),
                  Container(
                    width: 120,
                    child: content.contains(".pdf")
                        ? !isMe
                            ? Expanded(
                                child: Text(
                                path.basename(content).substring(0, 30),
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13.0,
                                ),
                              ))
                            : Expanded(
                                child: Text(
                                path.basename(content).substring(0, 30),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13.0,
                                ),
                              ))
                        : Text(
                            "FILE",
                            maxLines: 1,
                            style: TextStyle(
                              color: !isMe ? Colors.black87 : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  myImageWidget(CustomClipper clipper, chatRightColor, chatRightTextColor,
      content, star, timeStamp, read, index, id, MessagePhoenix message) {
    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.all(2.0),
              child: InkWell(
                onTap: () {
                  var imageMedia = [];
                  imageMedia.insert(0, content);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ViewImages(images: imageMedia, number: 0)),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                      width: 30.0,
                      height: 30.0,
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
                    height: MediaQuery.of(context).size.width * 0.5,
                    width: MediaQuery.of(context).size.width * 0.5,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
