import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:eraser/eraser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkable/linkable.dart';
import 'package:nova/models/queue.dart';
import 'package:nova/models/thumbnail_response.dart';
import 'package:nova/push/firebasepush/firebase_listener.dart';
import 'package:nova/push/huaweipush/huawei_listener.dart';
import 'package:nova/services/amplitude_service.dart';
import 'package:nova/utils/commons.dart';
import 'package:nova/utils/encryptdata.dart';
import 'package:nova/utils/rsa_encrypt_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/gestures.dart';
import 'package:nova/models/broadcast_list.dart';
import 'package:nova/models/contact_data.dart';
import 'package:nova/models/chats.dart';
import 'package:nova/models/group_chat_data.dart';
import 'package:nova/models/contact_detail.dart';
import 'package:nova/models/create_contacts.dart';
import 'package:nova/networking/http_service.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/services/socket_service.dart';
import 'package:nova/ui/broadcasts/broadcast_chat.dart';
import 'package:nova/ui/chat/chat.dart';
import 'package:nova/ui/groupchats/group_chat.dart';
import 'package:nova/utils/hive_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nova/main.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phoenix_wings/phoenix_wings.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nova/viewmodels/chat_viewmodel.dart';
import 'package:nova/viewmodels/chat_list_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:just_audio/just_audio.dart';

String appName = 'Nova Messenger';
String userVisibility = 'On';
bool passCodeStatus = false;
const Color appColor = Color(0XFF642CE8);
const Color bgReplyGrayColor = Color(0XFFEBEBEB);
Color chatBackgroundColor = Color(0xFFECE5DD);
Color chatLeftColor2 = Colors.grey[300];
Color chatLeftColor = Colors.white;
Color chatLeftTextColor = Colors.black87;
Color chatRightColor = appColor;
Color audioRightColor = Color(0XFFC3B1E1);
Color replyColor = Color(0XFFEBEBEB);
Color audioLeftColor = Color(0XFFC3B1E1);
Color chatRightTextColor = Colors.white;
Color textFieldBG = Color(0XFFEBEBEB);
Color novaDark = Color(0XFF14141F);
Color novaErrorRed = Color(0XFFCD274B);
Color novaDarkModeBlue = Color(0XFF171736);

double chatFontSize = 16;
double chatFontLabelSize = 14;
double emojiSize = 25;
double chatMainChatsTitleFontSize = 16;
double chatFontDateSize = 14;
double appBarFontTitleSize = 20;
double maxImageSize = 8;
double maxVideoSize = 8;
int badgeCount = 0;
double genericPadding = 8;
double genericSpacing = 14;

String userToken = "";
String userUuid = "";
bool isTrengoClient = false;
String trengoIdentifier = "";
HttpService _api = serviceLocator<HttpService>();
//
String profilePlaceHolder =
    "https://www.pngall.com/wp-content/uploads/5/Profile-PNG-File.png";
//
String appleAuthToken =
    "SFMyNTY.g2gDbQAAACl1c2VyLWNiNzgwZGZhLTFlMzMtNGFkZS1hNGExLTUwYzE0MmJmZWI2MG4GANedP-uAAWIAAVGA.BHHgscxXxKFf5RF0-If2_ZJ3XO55WxUD1sxy7JMREI8";
String appleUuid = "user-cb780dfa-1e33-4ade-a4a1-50c142bfeb60";
//
String googleAuthToken =
    "SFMyNTY.g2gDbQAAACl1c2VyLTIzNjIwMTMyLWM4ZDgtNGI4Zi1hZWZlLWRiYzg3YTIxNzdjM24GADqCQOuAAWIAAVGA.iDyKlEl6TgQ9CeymcdJP5pgChXSi7tt3ztykvPC4Euw";
String googleUuid = "user-23620132-c8d8-4b8f-aefe-dbc87a2177c3";
//
String testAuthToken =
    "SFMyNTY.g2gDbQAAACl1c2VyLTY5ZDNmM2Q3LWYwYWYtNGE2Ni05NjRhLTBhM2RhM2QwN2U2OW4GANNmPfKBAWIAAVGA.EbVO2S8iOKIUrcD3L_WJaNZ9JvC3o8bm7UBtvO6NNso";
String testUuid = "user-69d3f3d7-f0af-4a66-964a-0a3da3d07e69";
//
String huaweiAuthToken =
    "SFMyNTY.g2gDbQAAACl1c2VyLTQ0MGFjMjg2LTYyNzUtNDdmNC1iYTdhLWY3MDMxYzE2NjFmOW4GAMQrU_2BAWIAAVGA.UmfS9bmEMuJCfofb1p4V_f7ysHLcC-9eTDAbTU2BZrA";
String huaweiUuid = "user-440ac286-6275-47f4-ba7a-f7031c1661f9";

final RegExp REGEX_EMOJI = RegExp(
    r'(\u00a9|\u00ae|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000])');

bool hasEmoji(String text) {
  RegExp emojiRegex = RegExp(r"[\u{1F600}-\u{1F64F}]" // Emoticons
      r"|[\u{1F300}-\u{1F5FF}]" // Miscellaneous Symbols and Pictographs
      r"|[\u{1F680}-\u{1F6FF}]" // Transport and Map Symbols
      r"|[\u{2600}-\u{26FF}]" // Miscellaneous Symbols
      r"|[\u{2700}-\u{27BF}]" // Dingbats
      r"|[\u{1F900}-\u{1F9FF}]" // Supplemental Symbols and Pictographs
      );
  return emojiRegex.hasMatch(text);
}

Widget contentText(String content, String id) {
  final Iterable<Match> matches = REGEX_EMOJI.allMatches(content);
  RegExp _numeric = RegExp(r'^-?[0-9]+$');
  if (matches.isEmpty)
    return _numeric.hasMatch(content) && content.length >= 10
        ? InkWell(
            onTap: () {
              launch('tel:$content');
            },
            child: Text(
              content + " ",
              style: TextStyle(
                  color: id == userUuid ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.normal,
                  fontFamily: normalStyle,
                  height: 1.6,
                  fontSize: chatFontSize),
            ),
          )
        : Linkable(
            style: TextStyle(
                color: id == userUuid ? Colors.white : Colors.black87,
                fontWeight: FontWeight.normal,
                fontFamily: normalStyle,
                fontSize: chatFontSize),
            text: content,
            textColor: id == userUuid ? Colors.white : Colors.black87,
          );

  return RichText(
      text: TextSpan(children: [
    for (var t in content.characters)
      TextSpan(
          text: t,
          style: TextStyle(
              fontSize: REGEX_EMOJI.allMatches(t).isNotEmpty ? 23.0 : emojiSize,
              color: id == userUuid ? Colors.white : Colors.black87,
              height: 1.6,
              fontWeight: FontWeight.normal,
              fontFamily: normalStyle),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              launch('tel:$content');
            }),
  ]));
}

var audioPlayersMap = Map<String, dynamic>();
ItemScrollController itemGlobalScrollController = ItemScrollController();

TextEditingController phoneNumberController = TextEditingController();
FirebaseAuth auth = FirebaseAuth.instance;

double globalMinThreshold = 0.1;
double globalMaxTranslation = .1;

stopAllOtherAudio(String uuid) {
  for (var v in audioPlayersMap.keys) {
    if (!v.contains(uuid)) {
      audioPlayersMap[v].stop();
    }
  }
}

stopAllAudio() {
  for (var v in audioPlayersMap.keys) {
    audioPlayersMap[v].stop();
  }
}

String getUserName(String uuid) {
  if (uuid == userUuid) {
    return globalName;
  } else {
    ContactData contact = contactsAdminContactData
        .firstWhere((element) => uuid == element.uuid, orElse: () => null);
    return contact.name ?? "User";
  }
}

var broadcastChannels = Map<String, PhoenixChannel>();
var groupChannels = Map<String, PhoenixChannel>();
PhoenixChannel channelGeneralUser;

const String noInternet = "Please connect your device to the internet.";
const appColor1 = Color(0xFF024FA4);
const appColor2 = Color(0xFF002263);
const appColor3 = Color(0xFF013D64);
const appColor4 = Color(0xFF4D1D59);
const appColor5 = Color(0xFFE20489);
const notiRed = Color(0xFFFF0400);
const notiGrey = Color(0xFF818898);
const bgGrey = Color(0xFF818898);

const Color appColorBlack = Color(0xFF0a1247);
const Color drawerBackColor = Color(0XFFfcfcfc);
const Color appColorBlue = Color(0XFF4354AE);

const Color appColorGreen = Color(0xFF34C759);
const Color appColorWhite = Colors.white;
const Color appColorGrey = Colors.grey;

const Color settingtile = Color(0xFF262628);
const Color chatReplyRightColor = Color(0XFFcee8ba);

String normalStyle = 'DMSans-Regular';
String boldFamily = 'DMSans-Regular';

const Color settingColoryellow = Color(0xFFf6cd00);
const Color settingColorGreen = Color(0xFF002263);
const Color settingColorBlue = Color(0xFF007dff);
const Color settingColorRed = Color(0xFFff3429);
const Color settingColorpink = Color(0xFFff2b54);
const Color settingColorChat = Color(0xFF47d86a);
const Color tickBGColor = Color(0xFF00D495);
const Color boxBGColor = Color(0xFFCCFFF0);
const Color boxBorderColor = Color(0xFF00D495);
const Color tickColor = Color(0xFF171736);
const Color waveColor = Color(0xFF818898);
const Color vnuserBG = Color(0xFF4514B8);
const Color vnpeerBG = Color(0xFFD5D7DD);
const Color userreplyBG = Color(0xFF4514B8);
const Color introGrey = Color(0xFF505662);
const Color inputGrey = Color(0xFFEBEBEB);

const Color callColor1 = Color(0XFF738464);
const Color callColor2 = Color(0XFF9b7573);

const Color boxErrorBorderColor = Color(0xFFFFDA3C);
const Color boxErrorBGColor = Color(0xFFFFF5CC);
const Color microphoneRed = Color(0xFFCD274B);

void setBrightness(Brightness brightness) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  brightness == Brightness.dark
      ? prefs.setBool("isDark", true)
      : prefs.setBool("isDark", false);
}

String userID = '';
String mobNo = '';
String cCode = '';
String fullMob = '';
String globalName = '';
String globalMobile = '';
String globalImage = '';
String serverKey =
    "AAAAlcGF_5k:APA91bE6rrIsDBbpyipQJbqAZZggY7FsoPOKiMbbcm4UEKQNN4j0o_AD31sk9owcXTWj2BAwWB5yu9VNRG-1RYBC-nTJxZQ0MkXFYnurfhnr5flsPBU6H_BXAjCDPWwHImomVAciusOS";
String noImage = 'https://i.stack.imgur.com/l60Hf.png';

var mobileContacts = [];
List<Contact> allContacts;

Timer contactUpdateTimer;
List<ContactData> contactsGlobalData = [];
List<ContactData> contactsAdminContactData = [];
List<GroupChatData> groupGlobalData = [];
List<BroadcastList> listGlobalData = [];

List<String> localImage = [];
var savedContactUserId = [];
String userName = "";

class CustomText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final Alignment alignment;
  final String fontFamily;

  const CustomText(
      {Key key,
      this.text,
      this.color,
      this.fontSize,
      this.fontWeight,
      this.alignment,
      this.fontFamily})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: alignment,
        child: Text('$text',
            style: TextStyle(
                color: color,
                fontSize: fontSize,
                fontWeight: fontWeight,
                fontFamily: fontFamily)));
  }
}

class CustomButton extends StatelessWidget {
  final Color color;
  final String title;
  final Function onPressed;
  final double fontSize;
  final FontWeight fontWeight;
  final Color textColor;
  final BorderRadius borderRadius;
  final String fontFamily;
  final double width;

  CustomButton(
      {this.color,
      this.title,
      this.onPressed,
      this.fontSize,
      this.fontWeight,
      this.textColor,
      this.borderRadius,
      this.fontFamily,
      this.width});

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return ButtonTheme(
        minWidth: 300.0,
        height: 40,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(color),
            elevation:
                MaterialStateProperty.all<double>(0), // Set elevation to zero
          ),
          onPressed: onPressed,
          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: textColor,
              fontFamily: fontFamily,
            ),
          ),
        ));
  }
}

bool isAppMinimized = false;

String convertedTime(String timeDate) {
  return DateTime.parse(
    converTime(timeDate),
  ).millisecondsSinceEpoch.toString();
}

Widget loader() {
  return Container(
    height: 60,
    width: 60,
    padding: EdgeInsets.all(15.0),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6), color: Colors.transparent),
    child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(appColor)),
  );
}

// ignore: must_be_immutable
class CustomtextField extends StatefulWidget {
  final TextInputType keyboardType;
  final Function onTap;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final Function onEditingComplate;
  final Function onSubmitted;
  final dynamic controller;
  final int maxLines;
  final dynamic onChange;
  final String errorText;
  final String hintText;
  final String labelText;
  bool obscureText = false;
  bool readOnly = false;
  bool autoFocus = false;
  final Widget suffixIcon;

  final Widget prefixIcon;

  CustomtextField({
    this.keyboardType,
    this.onTap,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplate,
    this.onSubmitted,
    this.controller,
    this.maxLines,
    this.onChange,
    this.errorText,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.readOnly = false,
    this.autoFocus = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  _CustomtextFieldState createState() => _CustomtextFieldState();
}

class _CustomtextFieldState extends State<CustomtextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: widget.focusNode,
      readOnly: widget.readOnly,
      textInputAction: widget.textInputAction,
      onTap: widget.onTap,
      autofocus: widget.autoFocus,
      maxLines: widget.maxLines,
      onEditingComplete: widget.onEditingComplate,
      onSubmitted: widget.onSubmitted,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      controller: widget.controller,
      onChanged: widget.onChange,
      style: TextStyle(
          color: Colors.black, fontFamily: 'DMSans-Regular', fontSize: 14),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        labelText: widget.labelText,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
        errorStyle: TextStyle(color: Colors.black),
        errorText: widget.errorText,
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(6),
        ),
        hintText: widget.hintText,
        focusColor: Colors.black,
        labelStyle: TextStyle(color: Colors.black),
        hintStyle: TextStyle(
            color: Colors.grey[600],
            fontFamily: 'DMSans-Regular',
            fontSize: 13),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: appColor, width: 1.8),
          borderRadius: BorderRadius.circular(5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 0.5),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class CustomtextField3 extends StatefulWidget {
  final TextInputType keyboardType;
  final Function onTap;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final Function onEditingComplate;
  final Function onSubmitted;
  final dynamic controller;
  final int maxLines;
  final dynamic onChange;
  final String errorText;
  final String hintText;
  final String labelText;
  bool obscureText = false;
  bool readOnly = false;
  bool autoFocus = false;
  final Widget suffixIcon;
  final textAlign;

  final Widget prefixIcon;

  CustomtextField3(
      {this.keyboardType,
      this.onTap,
      this.focusNode,
      this.textInputAction,
      this.onEditingComplate,
      this.onSubmitted,
      this.controller,
      this.maxLines,
      this.onChange,
      this.errorText,
      this.hintText,
      this.labelText,
      this.obscureText = false,
      this.readOnly = false,
      this.autoFocus = false,
      this.prefixIcon,
      this.suffixIcon,
      this.textAlign});

  @override
  _CustomtextFieldState3 createState() => _CustomtextFieldState3();
}

class _CustomtextFieldState3 extends State<CustomtextField3> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlign: widget.textAlign,
      focusNode: widget.focusNode,
      readOnly: widget.readOnly,
      textInputAction: widget.textInputAction,
      onTap: widget.onTap,
      autofocus: widget.autoFocus,
      maxLines: widget.maxLines,
      onEditingComplete: widget.onEditingComplate,
      onSubmitted: widget.onSubmitted,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      controller: widget.controller,
      onChanged: widget.onChange,
      style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold),
      cursorColor: appColor,
      decoration: InputDecoration(
        filled: false,
        //  fillColor: Colors.black.withOpacity(0.5),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        labelText: widget.labelText,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        errorStyle: TextStyle(color: Colors.white),
        errorText: widget.errorText,

        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        hintText: widget.hintText,
        labelStyle: TextStyle(color: Colors.white),
        hintStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontSize: 13),

        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
      ),
    );
  }
}

List<ContactDetail> contactsDetails = [];
List<ContactData> contactsDetailsResponse = [];

Future createContactsFromGlobal() async {
  contactsDetails.clear();
  var getContacts = [];
  var newContacts = [];
  List<dynamic> retrievedContactsName = [];
  List<dynamic> retrievedContactsMobile = [];
  List<dynamic> retrievedContactsEmail = [];

  var contacts = (await ContactsService.getContacts(
          withThumbnails: false, iOSLocalizedLabels: iOSLocalizedLabels))
      .toList();

  final preferences = await HivePreferences.getInstance();
  String uuid = preferences.getUserId();
  CreateContacts contactsCreate = CreateContacts();
  allContacts = contacts;
  contactsCreate.uuid = uuid;
  if (allContacts != null) {
    print("TOTAL:>>>>>>>>>>>" + allContacts.length.toString());
    for (int i = 0; i < allContacts.length; i++) {
      Contact c = allContacts?.elementAt(i);
      if (c.phones.isNotEmpty) {
        retrievedContactsMobile.add(c.phones[0].value.toString() ?? "");
        retrievedContactsName.add(allContacts[i].displayName ?? "");
        if (c.emails.isNotEmpty) {
          retrievedContactsEmail.add(c.emails[0].value.toString() ?? "");
        } else {
          retrievedContactsEmail.add("");
        }
      }

      getContacts.add(c.phones.map(
          (e) => e.value.replaceAll(new RegExp(r"\s+\b|\b\s"), "").toString()));
    }
  }

  mobileContacts.addAll(newContacts);
  print('NEW>>>>>>>>>>>>>>>>>>>>>>');
  print(mobileContacts);
  print('NEW>>>>>>>>>>>>>>>>>>>>>>');

  for (int i = 0; i < retrievedContactsName.length; i++) {
    ContactDetail contactDetail = ContactDetail();
    contactDetail.number = retrievedContactsMobile[i].toString();
    contactDetail.name = retrievedContactsName[i].toString();
    contactDetail.email = retrievedContactsEmail[i].toString();
    contactsDetails.add(contactDetail);
  }

  contactsCreate.contacts = contactsDetails;

  await _api.createContacts(contactsCreate);
}

String readTimestamp(int timestamp) {
  var now = DateTime.now();
  var format = DateFormat('h:mma');
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
  var diff = now.difference(date);
  var time = '';

  if (diff.inSeconds <= 0 ||
      diff.inSeconds > 0 && diff.inMinutes == 0 ||
      diff.inMinutes > 0 && diff.inHours == 0 ||
      diff.inHours > 0 && diff.inDays == 0 && diff.inHours < 20) {
    time = format.format(date);
  } else if (diff.inHours >= 20 && diff.inDays < 7) {
    time = DateFormat('EEEE').format(date);
  } else {
    var format = DateFormat('dd/MM/yy');
    time = format.format(date);
  }

  return time;
}

String time(String insertedAt) {
  DateFormat dateFormat = DateFormat.Hms(insertedAt);
  DateTime dateTime = dateFormat.parse("2019-07-19 8:40:23");
  return dateFormat.format(dateTime);
}

converTime(time) {
  if (time != null) {
    final DateTime dt = DateTime.parse(time);
    return dt.toString();
  } else {
    return DateTime.now().toString();
  }
}

getContactName(mobile) {
  if (allContacts != null && mobile != null) {
    var name = mobile;
    for (var i = 0; i < allContacts.length; i++) {
      if (allContacts[i]
          .phones
          .map((e) => e.value)
          .toString()
          .replaceAll(new RegExp(r"\s+\b|\b\s"), "")
          .contains(mobile)) {
        name = allContacts[i].displayName;
      }
    }
    return name;
  } else {
    return mobile;
  }
}

Widget customImage(String url) {
  return CachedNetworkImage(
    placeholder: (context, url) => Center(child: CupertinoActivityIndicator()),
    errorWidget: (context, url, error) => Material(
        child: Container(
      child: Center(
        child: SvgPicture.asset(
          'assets/images/account_circle_full.svg',
          fit: BoxFit.fill,
        ),
      ),
      clipBehavior: Clip.hardEdge,
    )),
    imageUrl: url,
    fit: BoxFit.cover,
  );
}

Future<String> getSoundDuration(content) async {
  final player = AudioPlayer();
  final duration = await player.setUrl(content);
  var minutes = duration.inMilliseconds / 100000;
  return '${minutes.toStringAsFixed(2)}';
}

Future<String> getImageThumb(content) async {
  final fileName = await VideoThumbnail.thumbnailFile(
    video: content,
    thumbnailPath: (await getTemporaryDirectory()).path,
    imageFormat: ImageFormat.WEBP,
    maxHeight: 80,
    // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
    quality: 75,
  );
  return fileName;
}

Widget timeWidget(timeStamp, read, chatRightTextColor, id) {
  return Padding(
    padding: EdgeInsets.only(top: genericPadding),
    child: Row(
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
              color: chatRightTextColor,
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
    ),
  );
}

bool openedSocket = false;
bool inChat = false;
bool inHome = true;
String inChatUuid = "";
String inChatType = "";

SocketService globalSocketService;
AmplitudeService globalAmplitudeService;

String packageName = "";
String version = "";
String buildNumber = "";

final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

void getBuild() {
  PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  });
}

void getLocalData() async {
  await serviceLocator<ChatListViewModel>().getLocalChats();
  await serviceLocator<ChatViewModel>().getLocalListChats();
  await serviceLocator<ChatViewModel>().getLocalGroupChats();
  await serviceLocator<ChatViewModel>().getLocalDirectChats();
  await serviceLocator<ChatViewModel>().getLocalLastMessages();
  await serviceLocator<ChatViewModel>().getLocalLastPage();
  await serviceLocator<ChatViewModel>().getInChatType();
  await serviceLocator<ChatViewModel>().getInChatUuid();
  await getLocalOfflineQueuedMessages();
  await getLocalContacts();
  await getTrengoId();
}

bool appServicesInitialStart = false;
String fromPushUuid = "";
String fromPushType = "";

Future<bool> isHuawei() async {
  if (Platform.isAndroid) {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    var manufacturer = androidInfo.manufacturer.toLowerCase();
    if (manufacturer.contains("huawei")) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

Future<dynamic> startAmplitude() async {
  if (await globalAmplitudeService == null) {
    AmplitudeService newAmplitudeService = AmplitudeService();
    globalAmplitudeService = newAmplitudeService;
    await newAmplitudeService.startAmplitudeService();
  }
}

bool isSocketConnected() {
  return globalSocketService.isSocketConnected();
}

Future<bool> startAppServices(BuildContext context) async {
  final prefs = await HivePreferences.getInstance();
  var id = prefs.getUserId();
  var userToken = prefs.getUserToken();
  if (globalSocketService == null) {
    SocketService newSocketService = SocketService(userToken, id, context);
    globalSocketService = newSocketService;
  }
  if (await globalSocketService.startPhoenixServices()) {
    if (!appServicesInitialStart) {
      if (await isHuawei()) {
        HuaweiListen.huaweiListen(context);
      } else {
        FirebaseListen.firebaseListen(context);
      }
      getUserInfo();
    }
    await globalSocketService.push(event: "load_chats");
    await globalSocketService.push(event: "load_archived_chats");
    globalAmplitudeService?.sendAmplitudeData(
        'App services started.', "", null);
    appServicesInitialStart = true;
    return true;
  }
  return false;
} 

bool imagePicked = false;

String getAvatar(String uuid) {
  if (uuid == userUuid) {
    return globalImage;
  } else {
    ContactData contact = contactsGlobalData
        .firstWhere((element) => uuid == element.uuid, orElse: () => null);
    return contact.avatar ?? "";
  }
}

void clearBadgeData() async {
  Eraser.clearAllAppNotifications();
  badgeCount = 0;
  Eraser.resetBadgeCountAndRemoveNotificationsFromCenter();
  FlutterAppBadger.removeBadge();
  await globalSocketService.push(event: "reset_badges");
}

void gotoPageFromPush(BuildContext context, String uuid, String type) {
  if (fromPushUuid != "") {
    if (type == "GroupMessage") {
      GroupChatData group = GroupChatData();
      serviceLocator<ChatListViewModel>().mainChatList.forEach((messageData) {
        if (messageData.group.user != null) {
          if (messageData.group.user.uuid
              .toLowerCase()
              .contains(fromPushUuid)) {
            group = messageData.group;
          }
        }
      });
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GroupChat(
                  groupChatData: group,
                )),
      );
    } else if (type == "DirectMessage") {
      ContactData contactUser = ContactData();
      Chats chat = Chats();
      serviceLocator<ChatListViewModel>().mainChatList.forEach((messageData) {
        if (messageData.user.uuid.toLowerCase().contains(fromPushUuid)) {
          contactUser = messageData.user;
          chat = messageData;
        }
      });
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(
                  peerData: contactUser,
                  chatData: chat,
                )),
      );
    } else if (type == "BroadcastList") {
      BroadcastList broadcastData = BroadcastList();
      serviceLocator<ChatListViewModel>().mainChatList.forEach((messageData) {
        if (messageData.list != null) {
          if (messageData.list.uuid.toLowerCase().contains(fromPushUuid)) {
            broadcastData = messageData.list;
          }
        }
      });
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BroadCastChat(
                  broadcastData: broadcastData,
                )),
      );
    }
  }
}

List<QueueMessage> queuedMessages = [];
bool checkQueueActive = true;
bool isOffline = false;
bool firstLoad = false;
String appState;

void checkQueue() async {
  var uuidClient = Uuid().v1();
  if (queuedMessages.length > 0) {
    QueueMessage queue = queuedMessages.last;
    switch (queue.type) {
      case "DirectMessage":
        {
          var contact = contactsGlobalData.firstWhere(
              (element) => queue.uuid == element.uuid,
              orElse: () => null);
          if (contact != null) {
            globalSocketService.push(event: "new_msg", payload: {
              "to": queue.uuid,
              "client_uuid": uuidClient,
              "content": await RSAEncryptData.encryptText(
                  queue.message, contact.publicKey)
            });
          } else {
            globalSocketService.push(event: "new_msg", payload: {
              "to": queue.uuid,
              "client_uuid": uuidClient,
              "content": await RSAEncryptData.encryptText(
                  queue.message, queue.peerPublicKey)
            });
          }
        }
        break;
      case "GroupMessage":
        {
          globalSocketService.push(
              id: queue.uuid,
              type: "group",
              event: "new_group_message",
              payload: {
                "content": EncryptAESData.encryptAES(
                  queue.message,
                ),
                "client_uuid": uuidClient,
              });
        }
        break;
      case "BroadcastList":
        {
          globalSocketService.push(
              id: queue.uuid,
              type: "broadcast",
              event: "new_broadcast",
              payload: {
                "content": queue.message,
                "client_uuid": uuidClient,
              });
        }
        break;
    }
    queuedMessages.removeLast();
    // persist //
    final preferences = await HivePreferences.getInstance();
    String queued = jsonEncode(queuedMessages
        .map<Map<String, dynamic>>((messages) => QueueMessage.toMap(messages))
        .toList());
    preferences.setQueuedMessages(queued);
    await Future.delayed(const Duration(milliseconds: 1000));
    checkQueue();
  }
}

void queueOfflineMessages(
    String type, String uuid, String message, String peerPublicKey) async {
  QueueMessage queue = QueueMessage();
  queue.peerPublicKey = peerPublicKey;
  queue.uuid = uuid;
  queue.type = type;
  queue.message = message;
  queuedMessages.insert(0, queue);
  // persist //
  final preferences = await HivePreferences.getInstance();
  String queued = jsonEncode(queuedMessages
      .map<Map<String, dynamic>>((messages) => QueueMessage.toMap(messages))
      .toList());
  preferences.setQueuedMessages(queued);
}

void getUserInfo() async {
  HttpService _api = serviceLocator<HttpService>();
  var userResponse = await _api.getUser();
  if (userResponse != null) {
    globalName = userResponse.name;
    globalImage = userResponse.avatar;
    userUuid = userResponse.uuid;
  }
}

Widget errorMessage(String text) {
  return Container(
    padding: EdgeInsets.all(10.00),
    margin: EdgeInsets.only(bottom: 10.00),
    color: Colors.red,
    child: Row(children: [
      Container(
        margin: EdgeInsets.only(right: 6.00),
        child: Icon(Icons.info, color: Colors.white),
      ), // icon for error message

      Text(text, style: TextStyle(color: Colors.white)),
    ]),
  );
}

Future<bool> checkInternet() async {
  final connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult != ConnectivityResult.none;
}

Future getContacts() async {
  List<ContactData> contactsResponse = await _api.getContacts();
  if (contactsResponse != null) {
    contactsGlobalData = contactsResponse;
    final preferences = await HivePreferences.getInstance();
    String contacts = jsonEncode(contactsResponse
        .map<Map<String, dynamic>>((chats) => ContactData.toMap(chats))
        .toList());
    preferences.setCurrentContacts(contacts);
    contactsGlobalData.forEach((element) {
      var existingMessage = contactsGlobalData.firstWhere(
          (contact) => element.uuid == contact.uuid,
          orElse: () => null);
      if (existingMessage == null)
        serviceLocator<ChatViewModel>().messages[element.uuid] = [];
      serviceLocator<ChatViewModel>().usersData[element.uuid] = element;
    });
  }
}

Future<bool> getLocalContacts() async {
  final preferences = await HivePreferences.getInstance();
  var currentContacts = preferences.getCurrentContacts();
  if (currentContacts != null) {
    final List<ContactData> contacts = jsonDecode(currentContacts)
        .map<ContactData>((item) => ContactData.fromJson(item))
        .toList();
    contactsGlobalData = contacts;
    return true;
  } else {
    return false;
  }
}

Future<bool> getTrengoId() async {
  final preferences = await HivePreferences.getInstance();
  trengoIdentifier = preferences.getTrengoId();
  if (trengoIdentifier != null) {
    return true;
  } else {
    return false;
  }
}

Future<bool> getLocalOfflineQueuedMessages() async {
  final preferences = await HivePreferences.getInstance();
  var currentQueuedMessages = preferences.getQueuedMessages();
  if (currentQueuedMessages != null) {
    final List<QueueMessage> queued = jsonDecode(currentQueuedMessages)
        .map<QueueMessage>((item) => QueueMessage.fromJson(item))
        .toList();
    queuedMessages = queued;
    return true;
  } else {
    return false;
  }
}

bool isImageMaxSize(image) {
  final bytes = image.readAsBytesSync().lengthInBytes;
  final kb = bytes / 1024;
  final mb = kb / 1024;
  if (mb > maxImageSize) {
    return true;
  } else {
    return false;
  }
}

bool isVideoMaxSize(File file) {
  final bytes = file.readAsBytesSync().lengthInBytes;
  final kb = bytes / 1024;
  final mb = kb / 1024;
  if (mb > maxVideoSize) {
    return true;
  } else {
    return false;
  }
}

showDeleteChat(String uuid, BuildContext context, String type) async {
  containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        title: Text(
          "Are you sure you want to delete this " + type + "?",
          style: TextStyle(fontSize: 16.0, color: Colors.black),
        ),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "Delete " + type,
              style: TextStyle(
                  color: appColor, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              HttpService _api = serviceLocator<HttpService>();
              if (type == 'broadcast list') {
                var response = await _api.deleteBroadCastList(uuid);
                if (response != null) {
                  serviceLocator<ChatListViewModel>().deleteListChat(uuid);
                  serviceLocator<ChatViewModel>().deleteBroadcastList(uuid);
                  Navigator.of(context, rootNavigator: true).pop("Discard");
                } else {
                  Commons.novaFlushBarError(
                      context, "Error deleting list. Please try again.");
                  Navigator.of(context, rootNavigator: true).pop("Discard");
                }
              } else if (type == 'group') {
                var response = await _api.deleteGroup(uuid);
                if (response != null) {
                  serviceLocator<ChatListViewModel>().deleteGroupChat(uuid);
                  serviceLocator<ChatViewModel>().deleteGroup(uuid);
                  Navigator.of(context, rootNavigator: true).pop("Discard");
                } else {
                  Commons.novaFlushBarError(
                      context, "Error deleting group. Please try again.");
                  Navigator.of(context, rootNavigator: true).pop("Discard");
                }
              }
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(
                color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop("Discard");
          },
        ),
      ));
}

void containerForSheet<T>({BuildContext context, Widget child}) {
  showCupertinoModalPopup<T>(
    context: context,
    builder: (BuildContext context) => child,
  ).then<void>((T value) {});
}

showLeaveChat(String uuid, BuildContext context, String type) async {
  containerForSheet<String>(
    context: context,
    child: CupertinoActionSheet(
      title: Text(
        "Are you sure you want to leave this " + type + "?",
        style: TextStyle(fontSize: 16.0, color: Colors.black),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text(
            "Leave " + type,
            style: TextStyle(
                color: appColor, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          onPressed: () async {
            HttpService _api = serviceLocator<HttpService>();
            if (type == 'broadcast list') {
              if (await _api.leaveBroadcastList(uuid) != null) {
                serviceLocator<ChatListViewModel>().deleteListChat(uuid);
                serviceLocator<ChatViewModel>().deleteBroadcastList(uuid);
                Navigator.of(context, rootNavigator: true).pop("Discard");
              } else {
                Commons.novaFlushBarError(
                    context,
                    "There was an error when trying to leave " +
                        type +
                        ". Please try again.");
              }
            } else if (type == 'group') {
              if (await _api.leaveGroup(uuid) != null) {
                serviceLocator<ChatListViewModel>().deleteGroupChat(uuid);
                serviceLocator<ChatViewModel>().deleteGroup(uuid);
                Navigator.of(context, rootNavigator: true).pop("Discard");
              } else {
                Commons.novaFlushBarError(
                    context,
                    "There was an error when trying to leave " +
                        type +
                        ". Please try again.");
              }
            }
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          "Cancel",
          style: TextStyle(
              color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        isDefaultAction: true,
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop("Discard");
        },
      ),
    ),
  );
}

Future<String> saveVideoImage(
    String type, String uuid, message, messageUuid) async {
  String appPath = "";
  if (Platform.isAndroid) {
    Directory tempDir = await getTemporaryDirectory();
    appPath = tempDir.path;
  } else {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    appPath = appDocDir.path;
  }

  String savedImage = await VideoThumbnail.thumbnailFile(
    video: message.file,
    thumbnailPath: appPath,
    imageFormat: ImageFormat.PNG,
    maxWidth: 450,
    quality: 100,
  );

  ThumbnailResponse thumbResponse =
      await _api.uploadThumbnailFile(savedImage, messageUuid);

  if (thumbResponse != null) {
    switch (type) {
      case "DirectMessage":
        serviceLocator<ChatViewModel>().messages[uuid].forEach((element) {
          if (element.clientUuid == message.clientUuid) {
            element.savedImage = thumbResponse.thumbnail;
          }
        });
        String encodedDirectMessages =
            json.encode(serviceLocator<ChatViewModel>().messages);
        final preferences = await HivePreferences.getInstance();
        preferences.setListChats(encodedDirectMessages);
        serviceLocator<ChatViewModel>().update();
        break;
      case "BroadcastList":
        serviceLocator<ChatViewModel>().listMessages[uuid].forEach((element) {
          if (element.clientUuid == message.clientUuid) {
            element.savedImage = thumbResponse.thumbnail;
          }
        });
        String encodedListMessages =
            json.encode(serviceLocator<ChatViewModel>().listMessages);
        final preferences = await HivePreferences.getInstance();
        preferences.setListChats(encodedListMessages);
        serviceLocator<ChatViewModel>().update();
        break;
      case "GroupMessage":
        serviceLocator<ChatViewModel>().groupMessages[uuid].forEach((element) {
          if (element.clientUuid == message.clientUuid) {
            element.savedImage = thumbResponse.thumbnail;
          }
        });
        String encodedGroupMessages =
            json.encode(serviceLocator<ChatViewModel>().groupMessages);
        final preferences = await HivePreferences.getInstance();
        preferences.setGroupChats(encodedGroupMessages);
        serviceLocator<ChatViewModel>().update();
        break;
    }
    return savedImage;
  }
  return null;
}
