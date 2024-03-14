import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:nova/ui/widgets/circle_button_longpress.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:nova/models/broadcast_list.dart';
import 'package:nova/models/contact_data.dart';
import 'package:nova/models/chats.dart';
import 'package:nova/models/group_chat_data.dart';
import 'package:nova/models/message.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/ui/widgets/bubble5new.dart';
import 'package:nova/ui/widgets/circle_button.dart';
import 'package:nova/ui/widgets/forward_message.dart';
import 'package:nova/ui/voice_notes_swipe/audio_bubble.dart';
import 'package:nova/ui/widgets/forwarded_message_widget.dart';
import 'package:nova/ui/widgets/messages_widget.dart';
import 'package:nova/ui/widgets/profilecachedimage.dart';
import 'package:nova/utils/commons.dart';
import 'package:nova/ui/voice_notes_swipe/record_button.dart';
import 'package:nova/ui/widgets/background.dart';
import 'package:nova/ui/widgets/bubbletype.dart';
import 'package:nova/utils/hive_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:nova/ui/contact/contactinfo.dart';
import 'package:nova/ui/videoplayerscreen.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nova/networking/http_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nova/utils/pdf_viewer.dart';
import 'package:nova/utils/rsa_encrypt_data.dart';
import 'package:nova/viewmodels/chat_viewmodel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:nova/ui/viewImages.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'dart:io' as io;
import 'package:nova/viewmodels/chat_list_viewmodel.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:uuid/uuid.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// ignore: must_be_immutable
class Chat extends StatefulWidget {
  Chats chatData;
  ContactData peerData;
  bool isForwarded = false;
  MessagePhoenix forwardedMessage;
  String storeMessage = "";
  bool searchActive = false;

  Chat(
      {this.peerData,
        this.chatData,
        this.isForwarded,
        this.forwardedMessage,
        this.storeMessage,
        this.searchActive});

  @override
  _ChatState createState() => _ChatState(peerData: peerData);
}

class _ChatState extends State<Chat>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  ContactData peerData;

  _ChatState({@required this.peerData});

  // ignore: unused_field
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final dataKey = GlobalKey();

  bool record = false;
  bool button = false;

  String groupChatId;
  var listMessage;
  File videoFile;
  VideoPlayerController _videoPlayerController;
  String imageUrl;
  int limit = 20;

  TextEditingController textEditingController;

  String senderPhoenix = "";
  String receiverPhoenix = "";

  File _path;
  String filename;

  bool searchData = false;
  TextEditingController controller = TextEditingController();

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    isLapHours: true,
    onChange: (value) => print(''),
    onChangeRawSecond: (value) => print(''),
    onChangeRawMinute: (value) => print(''),
  );
  bool replyButton = false;
  var imageMedia = [];
  List newList = [];
  var videoMedia = [];
  var docsMedia = [];

  // ignore: unused_field
  final textFieldFocusNode = FocusNode();
  final FocusNode focusNode = FocusNode();

  bool isButtonEnabled = false;

  MessagePhoenix replyMessage;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionListener =
  ItemPositionsListener.create();

  //VIDEO UPLOADING
  var videoSize = '';
  double _progress = 0;
  double percentage = 0;
  bool videoloader = false;
  String videoStatus = '';

  AnimationController voiceController;
  var pathRecording = "";
  String userNumber = "";
  String userName = "";
  int replyIndex = 0;
  bool loader = false;
  bool isRecording = false;

  @override
  void initState() {
    // If a user taps search from the contact screen the search should be active
    if (widget.searchActive != null && widget.searchActive) {
      searchData = true;
    }
    inChatType = "direct";
    receiverPhoenix = widget.peerData.uuid;
    userNumber = widget.peerData.mobile;
    userName = widget.peerData.name;
    voiceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    inChatUuid = peerData.uuid;
    super.initState();
    markAllMessages();
    setPeerMessages();
    setUnreadCount();
    getUserID();
    inChat = true;
    fromPushUuid = "";
    checkTrengoUser();
    groupChatId = '';
    imageUrl = '';
    itemGlobalScrollController = itemScrollController;
    // get last typed message //
    textEditingController = TextEditingController(
        text:
        serviceLocator<ChatViewModel>().messagesLastTyped[receiverPhoenix]);
    if (textEditingController.text != "") {
      setState(() {
        isButtonEnabled = true;
      });
    }
    checkForwarding();
    checkStoreMessages();
  }

  checkForwarding() {
    if (widget.isForwarded != null && widget.isForwarded) {
      if (widget.forwardedMessage.contentType != "text") {
        String fileName = widget.forwardedMessage.file.split('/').last;
        loader = true;
        downloadFile(widget.forwardedMessage.file, fileName);
      } else {
        _sendForwardedMessage();
      }
    }
  }

  checkStoreMessages() {
    if (widget.storeMessage != null && widget.storeMessage != "") {
      _sendStoreMessage();
    }
  }

  void _sendStoreMessage() async {
    String replyUuid = "";
    if (replyButton) {
      replyUuid = replyMessage.clientUuid;
    }
    var uuidClient = Uuid().v1();
    serviceLocator<ChatViewModel>().messagesLastTyped[receiverPhoenix] = "";
    if (await checkInternet()) {
      globalSocketService.push(event: "new_msg", payload: {
        "to": receiverPhoenix,
        "client_uuid": uuidClient,
        "is_a_reply": replyButton,
        "reply_index": replyIndex,
        "replied_message_uuid": replyUuid,
        "is_forwarding": false,
        "content": await RSAEncryptData.encryptText(
            widget.storeMessage.replaceAll("+", " "), widget.peerData.publicKey)
      });
      globalAmplitudeService?.sendAmplitudeData(
          'SendDirectMessage', 'message sent', true);
      // local //
      DateTime now = DateTime.now();
      String formattedDate =
      DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(now);
      BroadcastList list = BroadcastList();
      GroupChatData group = GroupChatData();
      list.uuid = "";
      group.uuid = "";
      MessagePhoenix message = MessagePhoenix(
          content: widget.storeMessage.replaceAll("+", " "),
          contentType: "text",
          file: "",
          toUuid: receiverPhoenix,
          user: widget.peerData,
          fromUuid: senderPhoenix,
          group: group,
          avatar: "",
          repliedMessageUuid: replyUuid,
          hasReplied: replyButton,
          replyIndex: replyIndex,
          listData: list,
          lastSeen: "",
          insertedAt: formattedDate,
          status: "sent",
          muted: false,
          clientUuid: uuidClient,
          hasForwarded: false,
          uuid: "");
      serviceLocator<ChatViewModel>().updateLastTyped();
      hideKeyboard();
      setState(() {
        isButtonEnabled = false;
        replyButton = false;
      });
      serviceLocator<ChatViewModel>()
          .updateDirectLocalChat(receiverPhoenix, message);
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        itemScrollController.scrollTo(
            index: 0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic);
      });
      // Log time outgoing direct message
      globalAmplitudeService?.sendAmplitudeData(
          'Outgoing Direct Message Time Stamp',
          DateTime.now().toString(),
          true);
      //
    } else {
      Commons.novaFlushBarError(
          context, "Currently offline, please reconnect your internet.");
      // queueOfflineMessages("DirectMessage", receiverPhoenix,
      //     textEditingController.text, widget.peerData.publicKey);
    }
  }

  void _sendForwardedMessage() async {
    String replyUuid = "";
    if (replyButton) {
      replyUuid = replyMessage.clientUuid;
    }
    var uuidClient = Uuid().v1();
    serviceLocator<ChatViewModel>().messagesLastTyped[receiverPhoenix] = "";
    if (await checkInternet()) {
      globalSocketService.push(event: "new_msg", payload: {
        "to": receiverPhoenix,
        "client_uuid": uuidClient,
        "is_a_reply": replyButton,
        "reply_index": replyIndex,
        "replied_message_uuid": replyUuid,
        "is_forwarding": true,
        "content": await RSAEncryptData.encryptText(
            widget.forwardedMessage.content, widget.peerData.publicKey)
      });
      globalAmplitudeService?.sendAmplitudeData(
          'SendDirectMessage', 'message sent', true);
      // local //
      DateTime now = DateTime.now();
      String formattedDate =
      DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(now);
      BroadcastList list = BroadcastList();
      GroupChatData group = GroupChatData();
      list.uuid = "";
      group.uuid = "";
      MessagePhoenix message = MessagePhoenix(
          content: widget.forwardedMessage.content,
          contentType: "text",
          file: "",
          toUuid: receiverPhoenix,
          user: widget.peerData,
          fromUuid: senderPhoenix,
          group: group,
          avatar: "",
          repliedMessageUuid: replyUuid,
          hasReplied: replyButton,
          replyIndex: replyIndex,
          listData: list,
          lastSeen: "",
          insertedAt: formattedDate,
          status: "sent",
          muted: false,
          clientUuid: uuidClient,
          hasForwarded: true,
          uuid: "");
      serviceLocator<ChatViewModel>().updateLastTyped();
      hideKeyboard();
      setState(() {
        isButtonEnabled = false;
        replyButton = false;
      });
      serviceLocator<ChatViewModel>()
          .updateDirectLocalChat(receiverPhoenix, message);
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        itemScrollController.scrollTo(
            index: 0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic);
      });
      // Log time outgoing direct message
      globalAmplitudeService?.sendAmplitudeData(
          'Outgoing Direct Message Time Stamp',
          DateTime.now().toString(),
          true);
      //
    } else {
      Commons.novaFlushBarError(
          context, "Currently offline, please reconnect your internet.");
      // queueOfflineMessages("DirectMessage", receiverPhoenix,
      //     textEditingController.text, widget.peerData.publicKey);
    }
  }

  void checkTrengoUser() async {
    userNumber = await widget.peerData.mobile;
    userName = await widget.peerData.name;
    if (userNumber == "735058273" || userName == "Trengo") {
      isTrengoClient = true;
    } else {
      isTrengoClient = false;
    }
  }

  void markAllMessages() async {
    if (receiverPhoenix != null && await checkInternet())
      globalSocketService.push(
          event: "mark_messages_as_read",
          payload: {"from_uuid": receiverPhoenix});
  }

  void setPeerMessages() async {
    if (serviceLocator<ChatViewModel>().messages[receiverPhoenix] == null &&
        await checkInternet()) {
      serviceLocator<ChatViewModel>().messages[receiverPhoenix] = [];
    }
    if (await checkInternet())
      serviceLocator<ChatViewModel>().setPeer(receiverPhoenix);
    final preferences = await HivePreferences.getInstance();
    preferences.setInChatUuid(inChatUuid);
    preferences.setInChatType(inChatType);
  }

  bool isScroll = true;
  final scrollDirection = Axis.vertical;
  int gotoindex;

  Timer searchOnStoppedTyping;
  bool startedTyping = true;

  _onChangeHandler(value) async {
    const duration = Duration(milliseconds: 2000);
    if (startedTyping) {
      if (await checkInternet()) {
        startedTyping = false;
        globalSocketService
            .push(event: "typing", payload: {"to": receiverPhoenix});
      }
    }
    searchOnStoppedTyping = Timer(duration, () async {
      startedTyping = true;
      if (await checkInternet()) {
        globalSocketService.push(event: "typing_stopped", payload: {
          "to": receiverPhoenix,
        });
      }
    });
  }

  hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _openFileExplorer() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    if (result != null) {
      _path = File(result.files.single.path);
    }
    if (_path != null) {
      print(_path.toString());
      if (!isImageMaxSize(_path)) {
        if (replyButton == true) {
          uploadFile(_path.path, "file");
          setState(() {
            replyButton = false;
          });
        } else {
          uploadFile(_path.path, "file");
        }
      } else {
        Commons.novaFlushBarError(context,
            "File is too large. Please ensure that the file size is no bigger than 8mb.");
      }
    }
  }

  void setUnreadCount() async {
    serviceLocator<ChatListViewModel>().mainChatList.forEach((chat) {
      if (chat.user?.uuid == widget.chatData?.user?.uuid) chat.unreadCount = 0;
      serviceLocator<ChatListViewModel>().notifyListeners();
    });
    String chats = jsonEncode(serviceLocator<ChatListViewModel>()
        .mainChatList
        .map<Map<String, dynamic>>((chats) => Chats.toMap(chats))
        .toList());
    final preferences = await HivePreferences.getInstance();
    preferences.setCurrentChats(chats);
  }

  Future<void> getImage() async {
    if (await permission.Permission.camera.request().isGranted) {
      File _image;
      final picker = ImagePicker();
      final imageFile = await picker.pickImage(source: ImageSource.gallery);

      if (imageFile != null) {
        imagePicked = false;
        final dir = await getTemporaryDirectory();
        final targetPath = dir.absolute.path +
            "/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

        var file;
        _image = File(imageFile.path);
        await FlutterImageCompress.compressAndGetFile(
          _image.absolute.path,
          targetPath,
          quality: 20,
        ).then((value) async {
          print("Compressed");
          file = value;
          if (!isImageMaxSize(file)) {
            uploadFile(file.path, "image");
          } else {
            Commons.novaFlushBarError(context,
                "Image is too large. Please ensure that file size is no bigger than 8mb.");
          }
        });
      }
    } else {
      Commons.novaFlushBarError(context,
          "We need permission to your camera in order to capture photos.");
      permission.openAppSettings();
    }
  }

  void uploadFile(filePath, type) async {
    if (loader != null && loader) {
      print("Loader is there");
    } else {
      EasyLoading.show(status: 'Uploading...');
    }

    HttpService _api = serviceLocator<HttpService>();

    String replyUuid = "";

    if (replyButton) {
      replyUuid = replyMessage.clientUuid;
    }

    final response = await _api.uploadFile(
        to: receiverPhoenix,
        from: senderPhoenix,
        filePath: filePath,
        type: type,
        replyIndex: replyIndex,
        isReply: replyButton,
        replyUuid: replyUuid,
        isForwarded: widget.isForwarded);

    final responseStr = await response.stream.bytesToString();
    if (response != null &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      print("File Uploaded");
      imagePicked = false;
      EasyLoading.dismiss();
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        itemScrollController.scrollTo(
            index: 0,
            duration: Duration(milliseconds: 5),
            curve: Curves.linearToEaseOut);
      });
      setState(() {
        loader = false;
        isButtonEnabled = false;
        replyButton = false;
        replyMessage = null;
      });
    } else {
      Commons.novaFlushBarError(context, "Upload failed. Please try again.");
      EasyLoading.dismiss();
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        itemScrollController.scrollTo(
            index: 0,
            duration: Duration(milliseconds: 5),
            curve: Curves.linearToEaseOut);
      });
      setState(() {
        isButtonEnabled = false;
        replyButton = false;
        replyMessage = null;
        loader = false;
      });
    }
    print("Response" + responseStr);
    if (type == "video") {
      if (mounted) {
        setState(() {
          videoloader = false;
          _videoPlayerController.dispose();
          _videoPlayerController.pause();
        });
      }
    }
  }

  Future getImageFromCam() async {
    if (await permission.Permission.camera.request().isGranted) {
      File _image;
      final picker = ImagePicker();
      final imageFile = await picker.pickImage(source: ImageSource.camera);
      if (imageFile != null) {
        imagePicked = false;
        final dir = await getTemporaryDirectory();
        final targetPath = dir.absolute.path +
            "/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
        var file;
        _image = File(imageFile.path);
        await FlutterImageCompress.compressAndGetFile(
          _image.absolute.path,
          targetPath,
          quality: 20,
        ).then((value) async {
          file = value;
          if (!isImageMaxSize(file)) {
            uploadFile(file.path, "image");
          } else {
            Commons.novaFlushBarError(context,
                "Image is too large. Please ensure that file size is no bigger than 8mb.");
          }
        });
      }
    } else {
      Commons.novaFlushBarError(context,
          "We need permission to your camera in order to capture photos.");
      permission.openAppSettings();
    }
  }

  _pickVideo() async {
    if (await permission.Permission.camera.request().isGranted) {
      setState(() {
        videoFile = null;
        Navigator.pop(context);
      });

      final picker = ImagePicker();
      final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          videoFile = File(pickedFile.path);
          addVideo(context);
        } else {
          print('No video selected.');
        }
      });

      _videoPlayerController = VideoPlayerController.file(videoFile)
        ..initialize().then((_) {
          //_videoPlayerController.play();
        });
    } else {
      Commons.novaFlushBarError(context,
          "We need permission to your gallery in order to attach a video.");
      permission.openAppSettings();
    }
  }

  addVideo(BuildContext context) async {
    if (videoFile != null) {
      if (!isVideoMaxSize(videoFile)) {
        uploadFile(videoFile.path, "video");
      } else {
        Commons.novaFlushBarError(context,
            "Video is too large. Please ensure that file size is no bigger than 8mb.");
      }
    } else {
      setState(() {
        videoloader = false;
        _videoPlayerController.dispose();
        _videoPlayerController.pause();
      });
    }
  }

  List<MessagePhoenix> messagesSearchChat = [];

  String directMessageKey(LastMessage message) {
    List<String> keyList = [message.fromUuid, message.toUuid];
    keyList.sort((a, b) {
      return a.compareTo(b);
    });
    return keyList.join(',');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          stopAllAudio();
          inChatUuid = "";
          senderPhoenix = "";
          serviceLocator<ChatViewModel>().senderPhoenix = "";
          serviceLocator<ChatListViewModel>().mainChatList.forEach((chat) {
            if (chat.user != null) {
              if (chat.user.uuid == receiverPhoenix) chat.unreadCount = 0;
              serviceLocator<ChatListViewModel>().notifyListeners();
            }
          });
          serviceLocator<ChatViewModel>().lastPageData["saveData"] = null;
          await HivePreferences.deleteLastSaved();
          serviceLocator<ChatListViewModel>().setLocal();
          inChat = false;
          Navigator.pop(context);
          return false;
        },
        child: ChangeNotifierProvider<ChatViewModel>.value(
            value: serviceLocator<ChatViewModel>(),
            child: Consumer<ChatViewModel>(
              builder: (context, model, child) => Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  appBar: searchData == true
                      ? AppBar(
                    title:
                    searchTextField(model.messages[receiverPhoenix]),
                    centerTitle: false,
                    elevation: 0,
                    backgroundColor:
                    Theme.of(context).scaffoldBackgroundColor,
                    automaticallyImplyLeading: false,
                    leading: null,
                    actions: <Widget>[
                      Container(
                        width: 50,
                        child: IconButton(
                          padding: const EdgeInsets.all(0),
                          icon: CustomText(
                            alignment: Alignment.center,
                            text: "Cancel",
                            color: appColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          onPressed: () {
                            setState(() {
                              controller.clear();
                              onSearchTextChanged("");
                              searchData = false;
                            });
                          },
                        ),
                      ),
                      Container(width: 15),
                    ],
                  )
                      : AppBar(
                    centerTitle: false,
                    elevation: 0,
                    backgroundColor:
                    Theme.of(context).scaffoldBackgroundColor,
                    title: InkWell(
                      onTap: () async {
                        if (await checkInternet() == true) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ContactInfo(
                                    peerData: widget.peerData,
                                    imageMedia: imageMedia,
                                    videoMedia: videoMedia,
                                    docsMedia: docsMedia)),
                          );
                        }
                      },
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () async {
                                Navigator.pop(context);
                                stopAllAudio();
                                inChatUuid = "";
                                senderPhoenix = "";
                                serviceLocator<ChatViewModel>()
                                    .senderPhoenix = "";
                                serviceLocator<ChatListViewModel>()
                                    .mainChatList
                                    .forEach((chat) {
                                  if (chat.user != null) {
                                    if (chat.user.uuid == receiverPhoenix)
                                      chat.unreadCount = 0;
                                    serviceLocator<ChatListViewModel>()
                                        .notifyListeners();
                                  }
                                });
                                serviceLocator<ChatViewModel>()
                                    .lastPageData["saveData"] = null;
                                await HivePreferences.deleteLastSaved();
                                serviceLocator<ChatListViewModel>()
                                    .setLocal();
                                inChat = false;
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 10,
                                    top: 5,
                                    bottom: 5,
                                    left: 5),
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: appColor,
                                ),
                              ),
                            ),
                            imageWidget(),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(left: 2),
                                      child: Text(
                                        getContactName(peerData.name),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .brightness ==
                                              Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: appBarFontTitleSize,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    peerOnline(model),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    automaticallyImplyLeading: false,
                    actions: <Widget>[
                      Container(width: 10),
                      searchData == false
                          ? Container(
                        width: 30,
                        child: IconButton(
                            onPressed: () {
                              setState(() {
                                searchData = true;
                              });
                            },
                            icon: Icon(CupertinoIcons.search,
                                color: appColor, size: 24)),
                      )
                          : Container(),
                      Container(
                        width: 15,
                      ),
                    ],
                  ),
                  body: Background(
                    child: searchData != true
                        ? Stack(
                      children: [
                        Column(
                          children: <Widget>[
                            buildListMessage(
                                model.messages[receiverPhoenix]),
                            model.usersDirect != null
                                ? buildInput(
                                model.messages[receiverPhoenix],
                                model.usersDirect[
                                widget.peerData.uuid])
                                : buildInput(
                                model.messages[receiverPhoenix], ""),
                          ],
                        ),
                        loader
                            ? Positioned(
                            top: 0,
                            right: 0,
                            bottom: 0,
                            left: 0,
                            child: Stack(
                              children: <Widget>[
                                Center(
                                    child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black,
                                              width: 5.0,
                                              style:
                                              BorderStyle.solid),
                                          borderRadius:
                                          BorderRadius.circular(
                                              20),
                                          color: Colors.black,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .center,
                                          children: [
                                            SpinKitFadingCircle(
                                              color: Colors.white,
                                              size: 45.0,
                                            ),
                                            Container(
                                              height: 5,
                                            ),
                                            Center(
                                                child: Text(
                                                  "Uploading...",
                                                  textAlign:
                                                  TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                      FontWeight
                                                          .normal),
                                                )),
                                          ],
                                        ))),
                              ],
                            ))
                            : Container()
                      ],
                    )
                        : Stack(
                      children: [
                        Container(
                          child: Column(
                            children: <Widget>[
                              buildListMessage(_searchResult),
                              model.usersDirect != null
                                  ? buildInput(
                                  model.messages[receiverPhoenix],
                                  model.usersDirect[
                                  widget.peerData.uuid])
                                  : buildInput(
                                  model.messages[receiverPhoenix],
                                  ""),
                            ],
                          ),
                        ),
                        loader
                            ? Positioned(
                            top: 0,
                            right: 0,
                            bottom: 0,
                            left: 0,
                            child: Stack(
                              children: <Widget>[
                                Center(
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black,
                                            width: 5.0,
                                            style: BorderStyle.solid),
                                        borderRadius:
                                        BorderRadius.circular(20),
                                        color: Colors.black,
                                      ),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )),
                                Center(
                                    child: Text(
                                      "Uploading...",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    )),
                              ],
                            ))
                            : Container()
                      ],
                    ),
                  )),
            )));
  }

  Widget searchTextField(List<MessagePhoenix> messages) {
    messagesSearchChat = messages;
    return Container(
      height: 45,
      child: Card(
        color: Colors.grey[200],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                color: appColor,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: TextField(
                    controller: controller,
                    onChanged: onSearchTextChanged,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListMessage(List<MessagePhoenix> messages) {
    return Flexible(
      child: ScrollablePositionedList.builder(
        reverse: true,
        itemScrollController: itemScrollController,
        itemBuilder: (BuildContext context, int index) {
          final message = messages[index];
          return GestureDetector(
              onHorizontalDragEnd: (_) {
                print("end");
              },
              child: Dismissible(
                  key: const Key('reply_swipe'),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      setState(() {
                        replyButton = true;
                        replyMessage = message;
                        replyIndex = index;
                      });
                      return false;
                    } else if (direction == DismissDirection.endToStart) {
                      return false;
                    }
                    return false;
                  },
                  background: Container(
                    color: Colors.transparent,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Icon(
                          Icons.reply,
                          color: Colors.grey[600],
                          size: 36.0,
                        ),
                      ),
                    ),
                  ),
                  direction: DismissDirection.startToEnd,
                  child: buildItem(index, message)));
        },
        itemCount: messages?.length ?? 0,
      ),
    );
  }

  Widget buildItem(int index, MessagePhoenix message) {
    if (message.contentType == "image") {
      if (imageMedia.contains(message.file)) {
      } else {
        imageMedia.add(message.file);
      }
    } else if (message.contentType == "video") {
      if (videoMedia.contains(message.file)) {
      } else {
        videoMedia.add(message.file);
      }
    } else if (message.contentType == "file") {
      if (docsMedia.contains(message.file)) {
      } else {
        docsMedia.add(message.file);
      }
    }

    if (message.toUuid == receiverPhoenix) {
      return Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              setState(() {
                textFieldFocusNode.unfocus();
                textFieldFocusNode.canRequestFocus = false;
              });
            },
            onLongPress: () {
              openMessageBox(
                  message.fromUuid,
                  message);
            },
            child: Row(
              children: <Widget>[
                message.contentType == "text"
                    ? myTextMessage(
                    ChatBubbleClipper5New(type: BubbleTypeNew.sendBubble),
                    chatRightColor,
                    chatRightTextColor,
                    message.content,
                    message.star,
                    message.insertedAt,
                    message.status,
                    index,
                    message)
                    : message.contentType == "image"
                    ? myImageWidget(
                    ChatBubbleClipper5New(
                        type: BubbleTypeNew.sendBubble),
                    chatRightColor,
                    chatRightTextColor,
                    message.file,
                    message.star,
                    message.insertedAt,
                    message.status,
                    index,
                    message.fromUuid,
                    message)
                    : message.contentType == "video"
                    ? myVideoWidget(
                    ChatBubbleClipper5New(
                        type: BubbleTypeNew.sendBubble),
                    chatRightColor,
                    chatRightTextColor,
                    message.file,
                    message.savedImage,
                    message.insertedAt,
                    message.status,
                    index,
                    message.fromUuid,
                    message)
                    : message.contentType == "file"
                    ? myFileWidget(
                    ChatBubbleClipper5New(
                        type: BubbleTypeNew.sendBubble),
                    chatRightColor,
                    chatRightTextColor,
                    message.file,
                    message.star,
                    message.insertedAt,
                    message.status,
                    index,
                    message.fromUuid,
                    context,
                    message)
                    : message.contentType == "audio"
                //Audio
                    ? myVoiceWidget(
                    context,
                    ChatBubbleClipper5New(
                        type: BubbleTypeNew.sendBubble),
                    message.file,
                    message.star,
                    message.insertedAt,
                    message.status,
                    index,
                    message.fromUuid,
                    true,
                    message)
                    : Container()
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              setState(() {
                textFieldFocusNode.unfocus();
                textFieldFocusNode.canRequestFocus = false;
              });
            },
            onLongPress: () {
              openMessageBox(
                  message.fromUuid,
                  message);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: <Widget>[
                  message.contentType == "text"
                  // Text
                      ? myTextMessage(
                      ChatBubbleClipper5New(
                          type: BubbleTypeNew.receiverBubble),
                      chatLeftColor,
                      chatLeftTextColor,
                      message.content,
                      message.star,
                      message.insertedAt,
                      message.status,
                      index,
                      message)
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
                      index,
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
                      index,
                      message.fromUuid,
                      message)
                      : message.contentType == "file"
                  //File
                      ? myFileWidget(
                      ChatBubbleClipper5New(
                          type: BubbleTypeNew.receiverBubble),
                      chatLeftColor,
                      chatLeftTextColor,
                      message.file,
                      message.star,
                      message.insertedAt,
                      message.status,
                      index,
                      message.fromUuid,
                      context,
                      message)
                      : message.contentType == "audio"
                      ? myVoiceWidget(
                      context,
                      message.fromUuid != userUuid
                          ? ChatBubbleClipper5New(
                          type: BubbleTypeNew
                              .receiverBubble)
                          : ChatBubbleClipper5New(
                          type:
                          BubbleTypeNew.sendBubble),
                      message.file,
                      message.star,
                      message.insertedAt,
                      message.status,
                      index,
                      message.fromUuid,
                      false,
                      message)
                      : Container()
                ],
              ),
            ),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      );
    }
  }

  Widget peerOnline(ChatViewModel model) {
    var contact = model.usersData[receiverPhoenix];
    var textPeer = "";
    Color peerColor = Colors.green;
    if (isTrengoClient) {
      textPeer = "Online";
    } else {
      if (contact != null) {
        if (contact.status == "pending") {
          textPeer = " User not activated";
          peerColor = appColorGrey;
        } else if (contact.lastSeen != "" && contact.typing == "") {
          textPeer = " Last Seen at " +
              readTimestamp(
                DateTime.parse(
                  converTime(contact.lastSeen),
                ).millisecondsSinceEpoch,
              );
          peerColor = appColorGrey;
        } else if (contact.typing == senderPhoenix.toString() &&
            contact.lastSeen == "") {
          textPeer = " Typing...";
          peerColor = appColorGrey;
        } else if (contact.statusContact == "active" &&
            contact.lastSeen == "") {
          textPeer = " Offline";
          peerColor = appColorGrey;
        } else {
          textPeer = " Online";
          peerColor = Colors.green;
        }
      }
    }

    return CustomText(
      text: textPeer,
      alignment: Alignment.centerLeft,
      fontSize: 11,
      color: peerColor,
    );
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
    ChatViewModel viewModel = serviceLocator<ChatViewModel>();
    int actualIndex = viewModel.messages[peerData.uuid]
        .indexWhere((item) => item.clientUuid == message.repliedMessageUuid);

    return message.hasReplied == false
        ? AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.only(left: 5, right: 5, bottom: genericSpacing),
        color: message.isHighlighted != null && message.isHighlighted
            ? Colors.purple
            : Colors.transparent,
        child: ChatBubble(
          clipper: clipper,
          elevation: 0,
          alignment: Alignment.topRight,
          backGroundColor: chatRightColor,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.5,
            ),
            child: TextButton(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ForwardingWidget(message.hasForwarded),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: !content.contains(".pdf")
                              ? Icon(
                            Icons.note,
                            color: chatRightTextColor,
                          )
                              : SvgPicture.asset(
                            'assets/images/filepdf.svg',
                            fit: BoxFit.fill,
                          ),
                        ),
                        Container(
                          width: 5,
                        ),
                        message.toUuid != receiverPhoenix
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
                            )),
                      ],
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: timeWidget(
                          timeStamp, read, chatRightTextColor, id))
                ],
              ),
              onPressed: () {
                if (content.contains(".pdf")) {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return PdfViewScreen(content);
                    },
                  ));
                  // ).then((value) => reset());
                } else {
                  launchUrl(
                    content,
                  );
                }
              },
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.all(0)),
                foregroundColor:
                MaterialStateProperty.all<Color>(chatRightTextColor),
                overlayColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
                backgroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
              ),
            ),
          ),
        ))
        : AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.only(left: 5, right: 5, bottom: genericSpacing),
        color: message.isHighlighted != null && message.isHighlighted
            ? Colors.purple
            : Colors.transparent,
        child: MessagesWidget(
          timestamp: timeStamp,
          read: read,
          messageOriginal: message,
          index: actualIndex,
          messageReply: getReplyMessageFromUuid(message.repliedMessageUuid),
          isGroup: false,
          onSwipedMessage: (message) {
            setState(() {
              replyButton = true;
              replyMessage = message;
            });
          },
        ));
  }

  Widget myVoiceReplyWidget(
      BuildContext context,
      CustomClipper clipper,
      content,
      star,
      timeStamp,
      read,
      index,
      id,
      isPeer,
      MessagePhoenix message) {
    return Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: AudioBubble(
              filepath: content,
              key: ValueKey(content),
              isPeer: true,
              uuid: timeStamp,
            )));
  }

  Widget myFileReplyWidget(
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
        key: PageStorageKey(message.uuid),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.5,
        ),
        // ignore: deprecated_member_use
        child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: !content.contains(".pdf")
                        ? Icon(
                      Icons.note,
                      color: chatRightTextColor,
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
                      ? Text(
                    "",
                    maxLines: 1,
                    style: TextStyle(
                        color: chatRightTextColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  )
                      : Text(
                    "FILE",
                    maxLines: 1,
                    style: TextStyle(
                        color: chatRightTextColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                )
              ],
            )));
  }

  Widget myVoiceWidget(BuildContext context, CustomClipper clipper, content,
      star, timeStamp, read, index, id, isPeer, MessagePhoenix message) {
    ChatViewModel viewModel = serviceLocator<ChatViewModel>();
    int actualIndex = viewModel.messages[peerData.uuid]
        .indexWhere((item) => item.clientUuid == message.repliedMessageUuid);

    return message.hasReplied == false
        ? AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.only(left: 5, right: 5, bottom: genericSpacing),
        color: message.isHighlighted != null && message.isHighlighted
            ? Colors.purple
            : Colors.transparent,
        child: ChatBubble(
            clipper: clipper,
            alignment: Alignment.topRight,
            elevation: 0,
            padding: EdgeInsets.only(
                top: genericPadding,
                bottom: genericPadding,
                left: genericPadding,
                right: genericPadding),
            backGroundColor: !isPeer ? Colors.white : appColor,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ForwardingWidget(message.hasForwarded),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ProfileCachedNetworkImage(
                          imageUrl: message.toUuid != receiverPhoenix
                              ? peerData.avatar
                              : globalImage,
                          size: 35),
                      Expanded(
                        child: AudioBubble(
                          filepath: content,
                          key: ValueKey(content),
                          isPeer: isPeer,
                          uuid: timeStamp,
                        ),
                      ),
                    ],
                  ),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: timeWidget(
                          timeStamp, read, chatRightTextColor, id))
                ],
              ),
            )))
        : AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.only(left: 5, right: 5, bottom: genericSpacing),
        color: message.isHighlighted != null && message.isHighlighted
            ? Colors.purple
            : Colors.transparent,
        child: MessagesWidget(
          timestamp: timeStamp,
          read: read,
          messageOriginal: message,
          index: actualIndex,
          messageReply: getReplyMessageFromUuid(message.repliedMessageUuid),
          isGroup: false,
          onSwipedMessage: (message) {
            setState(() {
              replyButton = true;
              replyMessage = message;
            });
          },
        ));
  }

  Widget myTextMessage(
      CustomClipper clipper,
      chatRightColor,
      chatRightTextColor,
      content,
      star,
      timestamp,
      read,
      index,
      MessagePhoenix message) {
    RegExp _numeric = RegExp(r'^-?[0-9]+$');

    String messageUserUuid = "";
    if (message.user != null) {
      messageUserUuid = message.user.uuid ?? "";
    }

    ChatViewModel viewModel = serviceLocator<ChatViewModel>();
    int actualIndex = viewModel.messages[peerData.uuid]
        .indexWhere((item) => item.clientUuid == message.repliedMessageUuid);

    return messageUserUuid == userUuid
        ? message.hasReplied == false
        ? AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding:
        EdgeInsets.only(left: 5, right: 5, bottom: genericSpacing),
        color: message.isHighlighted != null && message.isHighlighted
            ? Colors.purple
            : Colors.transparent,
        child: Align(
            alignment: Alignment.centerRight,
            child: ChatBubble(
              clipper: clipper,
              elevation: 0,
              alignment: Alignment.topRight,
              padding: EdgeInsets.only(
                  top: genericPadding,
                  bottom: genericPadding,
                  left: genericPadding,
                  right: genericPadding),
              backGroundColor: chatRightColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ForwardingWidget(message.hasForwarded),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth:
                          MediaQuery.of(context).size.width * 0.55,
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          children: <Widget>[
                            _numeric.hasMatch(content) &&
                                content.length >= 10
                                ? InkWell(
                              onTap: () {
                                launch('tel:$content');
                              },
                              child: contentText(
                                  content, message.fromUuid),
                            )
                                : contentText(
                                content, message.fromUuid),
                          ],
                        ),
                      ),
                      message.hasForwarded
                          ? SizedBox(
                        width: 50.0,
                        height: 10,
                      )
                          : SizedBox(width: 4.0),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: timeWidget(
                          timestamp,
                          read,
                          chatRightTextColor,
                          messageUserUuid,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )))
        : AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding:
        EdgeInsets.only(left: 5, right: 5, bottom: genericSpacing),
        color: message.isHighlighted != null && message.isHighlighted
            ? Colors.purple
            : Colors.transparent,
        child: MessagesWidget(
          timestamp: timestamp,
          read: read,
          messageOriginal: message,
          messageReply:
          getReplyMessageFromUuid(message.repliedMessageUuid),
          isGroup: false,
          index: actualIndex,
          onSwipedMessage: (message) {
            setState(() {
              replyButton = true;
              replyMessage = message;
            });
          },
        ))
        : message.hasReplied == false
        ? AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding:
        EdgeInsets.only(left: 5, right: 5, bottom: genericSpacing),
        color: message.isHighlighted != null && message.isHighlighted
            ? Colors.purple
            : Colors.transparent,
        child: Align(
          alignment: Alignment.centerLeft,
          child: ChatBubble(
            clipper: clipper,
            elevation: 0,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(
                top: genericPadding,
                bottom: genericPadding,
                left: genericPadding,
                right: genericPadding),
            backGroundColor: chatRightColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ForwardingWidget(message.hasForwarded),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth:
                        MediaQuery.of(context).size.width * 0.55,
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        children: <Widget>[
                          _numeric.hasMatch(content) &&
                              content.length >= 10
                              ? InkWell(
                            onTap: () {
                              launch('tel:$content');
                            },
                            child: contentText(
                                content, message.fromUuid),
                          )
                              : contentText(content, message.fromUuid),
                        ],
                      ),
                    ),
                    message.hasForwarded
                        ? SizedBox(
                      width: 50.0,
                      height: 10,
                    )
                        : SizedBox(width: 4.0),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: timeWidget(
                        timestamp,
                        read,
                        chatRightTextColor,
                        messageUserUuid,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ))
        : AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding:
        EdgeInsets.only(left: 5, right: 5, bottom: genericSpacing),
        color: message.isHighlighted != null && message.isHighlighted
            ? Colors.purple
            : Colors.transparent,
        child: MessagesWidget(
          timestamp: timestamp,
          read: read,
          messageOriginal: message,
          index: actualIndex,
          messageReply:
          getReplyMessageFromUuid(message.repliedMessageUuid),
          isGroup: false,
          onSwipedMessage: (message) {
            setState(() {
              replyButton = true;
              replyMessage = message;
            });
          },
        ));
  }

  myImageWidget(CustomClipper clipper, chatRightColor, chatRightTextColor,
      content, star, timeStamp, read, index, id, MessagePhoenix message) {
    ChatViewModel viewModel = serviceLocator<ChatViewModel>();
    int actualIndex = viewModel.messages[peerData.uuid]
        .indexWhere((item) => item.clientUuid == message.repliedMessageUuid);
    return message.hasReplied == false
        ? AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.only(left: 5, right: 5, bottom: genericSpacing),
      color: message.isHighlighted != null && message.isHighlighted
          ? Colors.purple
          : Colors.transparent,
      child: ChatBubble(
        clipper: clipper,
        elevation: 0,
        backGroundColor: chatRightColor,
        padding: EdgeInsets.only(
            top: genericPadding,
            bottom: genericPadding,
            left: genericPadding,
            right: genericPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ForwardingWidget(message.hasForwarded),
            InkWell(
              onTap: () {
                setState(() {
                  imageMedia.remove(content);
                  imageMedia.insert(0, content);
                });
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
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation<Color>(appColor),
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
            ),
            timeWidget(timeStamp, read, chatRightTextColor, id),
          ],
        ),
      ),
    )
        : AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.only(left: 5, right: 5, bottom: genericSpacing),
        color: message.isHighlighted != null && message.isHighlighted
            ? Colors.purple
            : Colors.transparent,
        child: MessagesWidget(
          timestamp: timeStamp,
          read: read,
          messageOriginal: message,
          messageReply: getReplyMessageFromUuid(message.repliedMessageUuid),
          isGroup: false,
          index: actualIndex,
          onSwipedMessage: (message) {
            setState(() {
              replyButton = true;
              replyMessage = message;
            });
          },
        ));
  }

  MessagePhoenix getReplyMessageFromUuid(String uuid) {
    ChatViewModel viewModel = serviceLocator<ChatViewModel>();
    var existingReplyMessage = viewModel.messages[peerData.uuid].firstWhere(
            (element) => element.clientUuid == uuid,
        orElse: () => null);
    return existingReplyMessage;
  }

  myVideoWidget(CustomClipper clipper, chatRightColor, chatRightTextColor,
      content, savedImage, timeStamp, read, index, id, MessagePhoenix message) {
    ChatViewModel viewModel = serviceLocator<ChatViewModel>();
    int actualIndex = viewModel.messages[peerData.uuid]
        .indexWhere((item) => item.clientUuid == message.repliedMessageUuid);
    return message.hasReplied == false
        ? AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.only(left: 5, right: 5, bottom: genericSpacing),
        color: message.isHighlighted != null && message.isHighlighted
            ? Colors.purple
            : Colors.transparent,
        child: ChatBubble(
            clipper: clipper,
            elevation: 0,
            alignment: Alignment.topRight,
            padding: EdgeInsets.only(
                top: genericPadding,
                bottom: genericPadding,
                left: genericPadding,
                right: genericPadding),
            backGroundColor: chatRightColor,
            child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.5,
                ),
                child: TextButton(
                  onPressed: () async {
                    Timer.run(() async {
                      if (savedImage == "" || savedImage == null)
                        await saveVideoImage("DirectMessage", peerData.uuid,
                            message, message.uuid);
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoNovaPlayer(url: content),
                      ),
                    );
                    globalAmplitudeService?.sendAmplitudeData(
                        'VideoPlayerTap', "Video player tapped.", true);
                  },
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.zero),
                    backgroundColor:
                    MaterialStateProperty.all<Color>(chatRightColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ForwardingWidget(message.hasForwarded),
                      Container(
                          height: 150,
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              color: novaDarkModeBlue,
                              width: SizeConfig.screenWidth,
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  if (savedImage != null)
                                    CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: savedImage,
                                      placeholder: (context, url) =>
                                          Container(
                                            height: 250,
                                            width: 0,
                                          ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            height: 250,
                                            width: 0,
                                          ),
                                    )
                                  else
                                    Container(
                                      height: 250,
                                      width: 0,
                                    ),
                                  Icon(
                                    Icons.play_circle,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          )),
                      timeWidget(timeStamp, read, chatRightTextColor, id),
                    ],
                  ),
                ))))
        : AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.only(left: 5, right: 5, bottom: genericSpacing),
        color: message.isHighlighted != null && message.isHighlighted
            ? Colors.purple
            : Colors.transparent,
        child: MessagesWidget(
          timestamp: timeStamp,
          read: read,
          messageOriginal: message,
          messageReply: getReplyMessageFromUuid(message.repliedMessageUuid),
          isGroup: false,
          index: actualIndex,
          onSwipedMessage: (message) {
            setState(() {
              replyButton = true;
              replyMessage = message;
            });
          },
        ));
  }

  getUserID() async {
    final preferences = await HivePreferences.getInstance();
    var id = await preferences.getUserId();
    senderPhoenix = id;
  }

  Widget imageWidget() {
    return peerData.avatar != ""
        ? Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: customImage(peerData.avatar),
        ))
        : Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.asset(
            "assets/images/user.png",
            height: 10,
            color: Colors.white,
          ),
        ));
  }

  myImageReplyWidget(CustomClipper clipper, chatRightColor, chatRightTextColor,
      content, star, timeStamp, read, index, id, MessagePhoenix message) {
    return Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.width * 0.5,
          maxWidth: MediaQuery.of(context).size.width * 0.5,
        ),
        child: Stack(
          children: [
            Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            imageMedia.remove(content);
                            imageMedia.insert(0, content);
                          });
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
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(appColor),
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
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ));
  }

  myVideoReplyWidget(CustomClipper clipper, chatRightColor, chatRightTextColor,
      content, savedImage, timeStamp, read, index, id, MessagePhoenix message) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FittedBox(
          fit: BoxFit.cover,
          child: Center(
            child: Container(
              color: novaDarkModeBlue,
              width: 150,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    height: 150,
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
        ));
  }

  Widget buildInput(List<MessagePhoenix> messages, String user) {
    SizeConfig().init(context);
    bool blockedPeer = false;
    if (user != "") {
      if (user == "blocked") {
        blockedPeer = true;
      }
    }
    final deviceHeight = MediaQuery.of(context).size.height;
    return blockedPeer == false
        ? widget.peerData.statusContact != "blocked"
        ? Container(
      width: deviceHeight,
      padding: EdgeInsets.only(bottom: Platform.isIOS ? 15 : 0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
              width: 1.0,
              color: Theme.of(context).brightness != Brightness.dark
                  ? Colors.grey[300]
                  : Colors.grey[900]),
          bottom: BorderSide(
              width: 1.0,
              color: Theme.of(context).brightness != Brightness.dark
                  ? Colors.grey[200]
                  : Colors.grey[900]),
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0),
        child: Column(
          children: [
            replyButton == true
                ? IntrinsicHeight(
                child: Container(
                  margin: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness ==
                        Brightness.dark
                        ? appColor
                        : bgReplyGrayColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        color: appColor,
                        width: 4,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                              left: 8, bottom: 8, right: 8, top: 8),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${replyMessage.user.name}',
                                      style: TextStyle(
                                          fontWeight:
                                          FontWeight.bold),
                                    ),
                                  ),
                                  GestureDetector(
                                    child:
                                    Icon(Icons.close, size: 16),
                                    onTap: onCancelReply,
                                  )
                                ],
                              ),
                              const SizedBox(height: 8),
                              replyMessage.contentType == "text"
                                  ? Text(
                                replyMessage.content,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .brightness ==
                                        Brightness.dark
                                        ? Colors.white
                                        : Colors.black54),
                              )
                                  : replyMessage.contentType ==
                                  "image"
                                  ? myImageReplyWidget(
                                  ChatBubbleClipper5New(
                                      type: BubbleTypeNew
                                          .receiverBubble),
                                  chatLeftColor,
                                  chatLeftTextColor,
                                  replyMessage.file,
                                  replyMessage.star,
                                  replyMessage.insertedAt,
                                  replyMessage.status,
                                  0,
                                  replyMessage.fromUuid,
                                  replyMessage)
                                  : replyMessage.contentType ==
                                  "video"
                                  ? myVideoReplyWidget(
                                  ChatBubbleClipper5New(
                                      type: BubbleTypeNew
                                          .receiverBubble),
                                  chatLeftColor,
                                  chatLeftTextColor,
                                  replyMessage.file,
                                  replyMessage
                                      .savedImage,
                                  replyMessage
                                      .insertedAt,
                                  replyMessage.status,
                                  0,
                                  replyMessage.fromUuid,
                                  replyMessage)
                                  : replyMessage.contentType ==
                                  "file"
                                  ? myFileReplyWidget(
                                  ChatBubbleClipper5New(
                                      type: BubbleTypeNew
                                          .receiverBubble),
                                  chatLeftColor,
                                  chatLeftTextColor,
                                  replyMessage.file,
                                  replyMessage.star,
                                  replyMessage
                                      .insertedAt,
                                  replyMessage
                                      .status,
                                  0,
                                  replyMessage
                                      .fromUuid,
                                  context,
                                  replyMessage)
                                  : replyMessage
                                  .contentType ==
                                  "audio"
                                  ? myVoiceReplyWidget(
                                  context,
                                  ChatBubbleClipper5New(
                                      type: BubbleTypeNew
                                          .receiverBubble),
                                  replyMessage
                                      .file,
                                  replyMessage
                                      .star,
                                  replyMessage
                                      .insertedAt,
                                  replyMessage
                                      .status,
                                  0,
                                  replyMessage
                                      .fromUuid,
                                  false,
                                  replyMessage)
                                  : Container()
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
                : Container(),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    margin: EdgeInsets.all(15),
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        !isRecording
                            ? Expanded(
                          child: TextField(
                            focusNode: textFieldFocusNode,
                            controller: textEditingController,
                            textCapitalization:
                            TextCapitalization.sentences,
                            minLines: 1,
                            maxLines: 5,
                            keyboardType:
                            TextInputType.multiline,
                            onChanged: (val) {
                              _onChangeHandler(val);
                              if (val.isNotEmpty) {
                                serviceLocator<ChatViewModel>()
                                    .messagesLastTyped[
                                peerData.uuid] = val;
                                setState(() {
                                  isButtonEnabled = true;
                                });
                              } else {
                                serviceLocator<ChatViewModel>()
                                    .messagesLastTyped[
                                peerData.uuid] = "";
                                setState(() {
                                  isButtonEnabled = false;
                                });
                              }
                              serviceLocator<ChatViewModel>()
                                  .updateLastTyped();
                            },
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Type a Message',
                              contentPadding:
                              EdgeInsets.all(10.0),
                              hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .brightness !=
                                    Brightness.dark
                                    ? Colors.black
                                    : Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                            : Container(),
                        !isRecording
                            ? IconButton(
                          onPressed: () {
                            _settingModalBottomSheet(context);
                          },
                          icon: Icon(
                            Icons.attach_file,
                            color:
                            Theme.of(context).brightness !=
                                Brightness.dark
                                ? Colors.grey[700]
                                : Colors.white,
                            size: 26,
                          ),
                        )
                            : Container(),
                        SizedBox(width: 4),
                        !isRecording
                            ? IconButton(
                          onPressed: () {
                            getImageFromCam();
                          },
                          icon: Icon(
                            Icons.camera_alt_outlined,
                            color:
                            Theme.of(context).brightness !=
                                Brightness.dark
                                ? Colors.grey[700]
                                : Colors.white,
                            size: 26,
                          ),
                        )
                            : Container(),
                        SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),
                !isButtonEnabled
                    ? Container(
                    padding: EdgeInsets.only(right: 10),
                    child: RecordButton(
                      controller: voiceController,
                      onPause: () async {
                        await Record().pause();
                      },
                      onContinue: () async {
                        await Record().resume();
                      },
                      onStart: () async {
                        if (await permission.Permission.microphone
                            .request()
                            .isGranted) {
                          _stopWatchTimer.onExecute
                              .add(StopWatchExecute.reset);
                          _stopWatchTimer.onExecute
                              .add(StopWatchExecute.start);

                          pathRecording = "";

                          io.Directory appDocDirectory =
                          await getApplicationDocumentsDirectory();
                          String name =
                          Commons.createCryptoRandomString(
                              15);
                          pathRecording = appDocDirectory.path +
                              '/' +
                              "recordings-$name.mp4";

                          Vibrate.feedback(FeedbackType.success);
                          if (await Record().hasPermission()) {
                            Wakelock.enable();
                            try {
                              await Record().start(
                                path: pathRecording,
                                encoder: AudioEncoder.aacLc,
                                bitRate: 128000,
                                samplingRate: 44100,
                              );
                            } catch (exception, stackTrace) {
                              await Sentry.captureException(
                                exception,
                                stackTrace: stackTrace,
                              );
                              Commons.novaFlushBarError(context,
                                  "Error recording. Please try again.");
                            }
                          }
                          setState(() {
                            isRecording = true;
                          });
                        } else {
                          Commons.novaFlushBarError(context,
                              "We need permission to your microphone in order to send voice notes.");
                          permission.openAppSettings();
                        }
                      },
                      onCancel: () async {
                        _stopWatchTimer.onExecute
                            .add(StopWatchExecute.stop);
                        pathRecording = "";
                        await Record().stop();
                        Wakelock.disable();
                        setState(() {
                          button = true;
                          isRecording = false;
                        });
                      },
                      onFinish: () async {
                        _stopWatchTimer.onExecute
                            .add(StopWatchExecute.stop);
                        print("_stopWatchTimer.minuteTime = " +
                            _stopWatchTimer.secondTime.value
                                .toString());

                        Wakelock.disable();
                        await Record().stop();
                        setState(() {
                          button = true;
                          isRecording = false;
                        });
                        if (_stopWatchTimer.secondTime.value >
                            1) {
                          await uploadFile(
                              pathRecording, "audio");
                        }
                      },
                    ))
                    : Container(
                    padding: EdgeInsets.only(right: 10),
                    child: IconButton(
                      onPressed: () {
                        _sendMessage();
                      },
                      icon: Icon(
                        CupertinoIcons.paperplane_fill,
                        size: 27,
                        color: appColor,
                      ),
                    )),
              ],
            ),
          ],
        ),
      ),
    )
        : Container(
      width: deviceHeight,
      padding: EdgeInsets.only(bottom: Platform.isIOS ? 15 : 0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1.0, color: Colors.grey[300]),
          bottom: BorderSide(width: 1.0, color: Colors.grey[200]),
        ),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.grey[200],
      ),
      child: Container(
        margin: EdgeInsets.only(top: 25, bottom: 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: Colors.transparent,
        ),
        child: Text(
          "This user has been blocked.",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
      ),
    )
        : Container(
      width: deviceHeight,
      padding: EdgeInsets.only(bottom: Platform.isIOS ? 15 : 0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1.0, color: Colors.grey[300]),
          bottom: BorderSide(width: 1.0, color: Colors.grey[200]),
        ),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.grey[200],
      ),
      child: Container(
        margin: EdgeInsets.only(top: 25, bottom: 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: Colors.transparent,
        ),
        child: Text(
          "This user has blocked you.",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void replyToMessage(MessagePhoenix message) {
    setState(() {
      replyButton = true;
      replyMessage = message;
    });
  }

  void onCancelReply() {
    setState(() {
      replyButton = false;
      replyMessage = null;
    });
  }

  void _sendMessage() async {
    String replyUuid = "";
    if (replyButton) {
      replyUuid = replyMessage.clientUuid;
    }
    var uuidClient = Uuid().v1();
    serviceLocator<ChatViewModel>().messagesLastTyped[receiverPhoenix] = "";
    if (await checkInternet()) {
      globalSocketService.push(event: "new_msg", payload: {
        "to": receiverPhoenix,
        "client_uuid": uuidClient,
        "is_a_reply": replyButton,
        "reply_index": replyIndex,
        "replied_message_uuid": replyUuid,
        "is_forwarding": false,
        "content": await RSAEncryptData.encryptText(
            textEditingController.text, widget.peerData.publicKey)
      });
      globalAmplitudeService?.sendAmplitudeData(
          'SendDirectMessage', 'message sent', true);
      // local //
      DateTime now = DateTime.now();
      String formattedDate =
      DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(now);
      BroadcastList list = BroadcastList();
      GroupChatData group = GroupChatData();
      list.uuid = "";
      group.uuid = "";
      MessagePhoenix message = MessagePhoenix(
          content: textEditingController.text,
          contentType: "text",
          file: "",
          toUuid: receiverPhoenix,
          user: widget.peerData,
          fromUuid: senderPhoenix,
          group: group,
          avatar: widget.peerData.avatar,
          repliedMessageUuid: replyUuid,
          hasReplied: replyButton,
          replyIndex: replyIndex,
          listData: list,
          lastSeen: "",
          insertedAt: formattedDate,
          status: "sent",
          muted: false,
          hasForwarded: false,
          clientUuid: uuidClient,
          uuid: "");
      serviceLocator<ChatViewModel>().updateLastTyped();
      textEditingController.text = "";
      hideKeyboard();
      setState(() {
        isButtonEnabled = false;
        replyButton = false;
      });
      serviceLocator<ChatViewModel>()
          .updateDirectLocalChat(receiverPhoenix, message);
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        itemScrollController.scrollTo(
            index: 0,
            duration: Duration(milliseconds: 5),
            curve: Curves.linearToEaseOut);
      });
      // Log time outgoing direct message
      globalAmplitudeService?.sendAmplitudeData(
          'Outgoing Direct Message Time Stamp',
          DateTime.now().toString(),
          true);
      //
    } else {
      Commons.novaFlushBarError(
          context, "Currently offline, please reconnect your internet.");
      // queueOfflineMessages("DirectMessage", receiverPhoenix,
      //     textEditingController.text, widget.peerData.publicKey);
    }
  }

  void _settingModalBottomSheet(context) {
    imagePicked = true;
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            height: 120,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 90),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: appColor,
            ),
            child: Column(
              children: <Widget>[
                Container(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: CircleButton(
                        assetPath: 'assets/images/photocam.svg',
                        color: Color(0XFFFFF5CC),
                        text: 'Photo',
                        colorBorder: Color(0XFFFFDA3C),
                        onTap: () {
                          Navigator.pop(context);
                          getImage();
                        },
                      ),
                    ),
                    Expanded(
                      child: CircleButton(
                        assetPath: 'assets/images/videocam.svg',
                        text: 'Video',
                        color: Color(0XFFCCFFF0),
                        colorBorder: Color(0XFF00D495),
                        onTap: () {
                          _pickVideo();
                        },
                      ),
                    ),
                    Expanded(
                      child: CircleButton(
                        assetPath: 'assets/images/assignment.svg',
                        text: 'Documents',
                        color: Color(0XFFD9D1FA),
                        colorBorder: Color(0XFF642CE8),
                        onTap: () {
                          if (Platform.isAndroid) {
                            Navigator.pop(context);
                            _pickFile();
                          } else {
                            Navigator.pop(context);
                            _openFileExplorer();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  openMessageBox(id, MessagePhoenix message) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(48.0),
          topRight: Radius.circular(48.0),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 180, // Adjusted height
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Container(
                width: 80,
                height: 5,
                decoration: BoxDecoration(
                  color: bgGrey,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: CircleButtonLongPress(
                      assetPath: 'assets/images/reply.svg',
                      color: bgGrey,
                      text: 'Reply',
                      colorBorder: bgGrey,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          replyButton = true;
                          replyMessage = message;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: CircleButtonLongPress(
                      assetPath: 'assets/images/forward.svg',
                      text: 'Forward',
                      color: bgGrey,
                      colorBorder: bgGrey,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ForwardMessage(message, "direct")),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: CircleButtonLongPress(
                      assetPath: 'assets/images/content_copy.svg',
                      text: 'Copy',
                      color: bgGrey,
                      colorBorder: bgGrey,
                      onTap: () {
                        Navigator.pop(context);
                        Clipboard.setData(ClipboardData(text: message.content));
                      },
                    ),
                  ),
                  Expanded(
                      child: GestureDetector(
                        onTap: () {
                          globalSocketService
                              .push(event: "delete", payload: {"uuid": message.uuid});
                          serviceLocator<ChatViewModel>().deleteFromLocal(message.uuid);
                          Navigator.pop(context);
                        },
                        child: Column(
                          children: [
                            Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Color(0XFFEBEBEB),
                                    width: 2.0,
                                  ),
                                ),
                                child: CircleAvatar(
                                    backgroundColor: Color(0XFFEBEBEB),
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      child: SvgPicture.asset(
                                        "assets/images/delete.svg",
                                      ),
                                    ))),
                            SizedBox(height: 8.0),
                            Text(
                              'Delete',
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16.0,
                                  fontFamily: "DMSans-Regular"),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  unBlockMenu(BuildContext context) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "Unblock",
              style: TextStyle(
                  color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop("Discard");
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop("Discard");
          },
        ),
      ),
    );
  }

  void containerForSheet<T>({BuildContext context, Widget child}) {
    showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {});
  }

  List<MessagePhoenix> _searchResult = [];

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    messagesSearchChat.forEach((messageData) {
      if (messageData.content.toLowerCase().contains(text.toLowerCase())) {
        _searchResult.add(messageData);
      }
    });
    setState(() {});
  }

  //This code is for Forwaded Message in One to One (Download & upload file to S3)
  static var httpClient = new HttpClient();

  downloadFile(String url, String filename) async {
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      String dir = (await getApplicationDocumentsDirectory()).path;
      File file = File('$dir/$filename');
      await file.writeAsBytes(bytes);
      uploadFile(file.path, widget.forwardedMessage.contentType);
    } on Exception catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      Commons.novaFlushBarError(
          context, 'Something has gone wrong. Please recheck and try again.');
    }
  }

  Future<void> _pickFile() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    Map<Permission, PermissionStatus> statusess;

    if (androidInfo.version.sdkInt <= 32) {
      statusess = await [
        Permission.storage,
      ].request();
    } else {
      statusess = await [
        Permission.photos,
        Permission.mediaLibrary,
        Permission.notification
      ].request();
    }

    var allAccepted = true;
    statusess.forEach((permission, status) {
      if (status != PermissionStatus.granted) {
        allAccepted = false;
        print("ALl accepted in loop" + allAccepted.toString());
      }
    });

    if (allAccepted) {
      final FilePickerResult result = await FilePicker.platform.pickFiles(
          allowedExtensions: ['pdf', 'doc', 'docx', 'pptx', 'xlsx'],
          type: FileType.custom);

      final path = result.files.single.path;

      if (path != null) {
        if (!isVideoMaxSize(File(path))) {
          if (replyButton == true) {
            uploadFile(path, "file");
            setState(() {
              replyButton = false;
            });
          } else {
            uploadFile(path, "file");
          }
        } else {
          Commons.novaFlushBarError(context,
              "File is too large. Please ensure that the file size is no bigger than 8mb.");
        }
      }
    } else {
      Commons.novaFlushBarError(context, "Please enable permission for Media");
    }
  }
}
