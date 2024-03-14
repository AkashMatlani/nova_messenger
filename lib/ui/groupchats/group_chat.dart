import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:nova/ui/widgets/circle_button_longpress.dart';
import 'package:path/path.dart' as path;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:nova/models/chats.dart';
import 'package:nova/models/group_chat_data.dart';
import 'package:nova/models/message.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/ui/widgets/bubble5new.dart';
import 'package:nova/ui/widgets/circle_button.dart';
import 'package:nova/ui/widgets/forward_message.dart';
import 'package:nova/ui/groupchats/groupinfo.dart';
import 'package:nova/ui/voice_notes_swipe/audio_bubble.dart';
import 'package:nova/ui/widgets/forwarded_message_widget.dart';
import 'package:nova/ui/widgets/messages_widget.dart';
import 'package:nova/ui/widgets/profilecachedimage.dart';
import 'package:nova/utils/commons.dart';
import 'package:nova/ui/voice_notes_swipe/record_button.dart';
import 'package:nova/ui/widgets/background.dart';
import 'package:nova/ui/widgets/bubbletype.dart';
import 'package:nova/utils/encryptdata.dart';
import 'package:nova/utils/hive_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:nova/ui/videoplayerscreen.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/helper/sizeconfig.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nova/networking/http_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nova/utils/pdf_viewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:nova/ui/viewImages.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:nova/viewmodels/chat_viewmodel.dart';
import 'dart:io' as io;
import 'package:nova/viewmodels/chat_list_viewmodel.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:wakelock/wakelock.dart';

// ignore: must_be_immutable
class GroupChat extends StatefulWidget {
  GroupChatData groupChatData;
  bool isForwarded = false;
  MessagePhoenix forwardedMessage;

  GroupChat({this.groupChatData, this.isForwarded, this.forwardedMessage});

  @override
  _GroupChatState createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // ignore: unused_field
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final dataKey = GlobalKey();

  bool record = false;
  bool button = false;

  String groupChatId;
  var listMessage;
  File videoFile;
  VideoPlayerController _videoPlayerController;
  bool isLoading;
  String imageUrl;
  int limit = 20;

  TextEditingController textEditingController;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionListener =
      ItemPositionsListener.create();

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
  bool offline = false;

  bool internet = false;

  // ignore: unused_field
  final textFieldFocusNode = FocusNode();
  final FocusNode focusNode = FocusNode();

  bool isButtonEnabled = false;

  String profilrPrivacy = '';
  String lastSeenPrivacy = '';
  bool loadPage = true;
  int replyIndex = 0;

  String contentBlink = '';

  Timer searchOnStoppedTyping;
  var pathRecording = "";

  //VIDEO UPLOADING
  var videoSize = '';
  double _progress = 0;
  double percentage = 0;
  bool videoloader = false;
  String videoStatus = '';

  AnimationController voiceController;
  GroupChatData groupChatDataLocal;
  Timer timerStatusCheck;
  bool isLoader = false;
  bool isRecording = false;

  @override
  void initState() {
    inChatType = "group";
    voiceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    getUserID();
    setTypes();
    // startTimerStatusCheck();
    groupChatDataLocal = widget.groupChatData;
    inChat = true;
    if (serviceLocator<ChatViewModel>()
            .groupMessages[widget.groupChatData.uuid] ==
        null) {
      serviceLocator<ChatViewModel>().groupMessages[widget.groupChatData.uuid] =
          [];
    }
    serviceLocator<ChatViewModel>().setListPeer(groupChatDataLocal.uuid);
    linkGroupChannel();
    inChatUuid = groupChatDataLocal.uuid;
    super.initState();
    itemGlobalScrollController = itemScrollController;
    fromPushUuid = "";
    markAllMessages();
    setUnreadCount();
    _loadGroup();
    groupChatId = '';
    isLoading = false;
    imageUrl = '';
    // get last typed message //
    textEditingController = TextEditingController(
        text: serviceLocator<ChatViewModel>()
            .messagesLastTyped[groupChatDataLocal.uuid]);
    if (textEditingController.text != "") {
      setState(() {
        isButtonEnabled = true;
      });
    }
    checkForwarding();
  }

  // void startTimerStatusCheck() {
  //   timerStatusCheck = Timer.periodic(const Duration(seconds: 3), (t) {
  //     markAllMessages();
  //   });
  // }

  void setTypes() async {
    final preferences = await HivePreferences.getInstance();
    preferences.setInChatUuid(inChatUuid);
    preferences.setInChatType(inChatType);
  }

  getUserID() async {
    final preferences = await HivePreferences.getInstance();
    userUuid = preferences.getUserId();
  }

  void markAllMessages() async {
    if (groupChatDataLocal.uuid != null && await checkInternet()) {
      globalSocketService.push(
          id: groupChatDataLocal.uuid,
          type: "group",
          event: "mark_group_messages_as_read");
      //_loadGroup();
    }
  }

  void setUnreadCount() async {
    serviceLocator<ChatListViewModel>().mainChatList.forEach((chat) {
      if (chat.group != null) {
        if (chat.group.uuid == widget.groupChatData.uuid) chat.unreadCount = 0;
        serviceLocator<ChatListViewModel>().notifyListeners();
      }
    });
    String chats = jsonEncode(serviceLocator<ChatListViewModel>()
        .mainChatList
        .map<Map<String, dynamic>>((chats) => Chats.toMap(chats))
        .toList());
    final preferences = await HivePreferences.getInstance();
    preferences.setCurrentChats(chats);
  }

  _loadGroup() async {
    if (await checkInternet()) {
      await globalSocketService.push(
          id: widget.groupChatData.uuid,
          type: "group",
          event: "load_group_messages",
          payload: {"uuid": widget.groupChatData.uuid});
    }
  }

  linkGroupChannel() async {
    final preferences = await HivePreferences.getInstance();
    var id = await preferences.getUserId();
    senderPhoenix = id;
    receiverPhoenix = groupChatDataLocal.uuid;
  }

  checkForwarding() {
    if (widget.isForwarded != null && widget.isForwarded) {
      if (widget.forwardedMessage.contentType != "text") {
        String fileName = widget.forwardedMessage.file.split('/').last;
        isLoader = true;
        downloadFile(widget.forwardedMessage.file, fileName);
      } else {
        _sendForwardedMessage();
      }
    }
  }

  List<List<int>> randomList;
  MessagePhoenix replyMessage;

  @override
  void dispose() {
    timerStatusCheck.cancel();
    super.dispose();
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
            print("if calling");
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

  void _openFileExplorer() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    if (result != null) {
      _path = File(result.files.single.path);
    }

    if (_path != null) {
      setState(() {
        isLoading = true;
      });

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

  List<File> allImages = [];

  Future<void> getImage() async {
    if (await permission.Permission.camera.request().isGranted) {
      File _image;
      final picker = ImagePicker();
      final imageFile = await picker.pickImage(source: ImageSource.gallery);

      if (imageFile != null) {
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
            imagePicked = false;
            await uploadFile(file.path, "image");
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

  List<MessagePhoenix> messagesSearchChat = [];

  void uploadFile(filePath, type) async {
    if (isLoader != null && isLoader) {
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
        to: groupChatDataLocal.uuid,
        filePath: filePath,
        type: type,
        channelType: "group",
        replyIndex: replyIndex,
        isReply: replyButton,
        replyUuid: replyUuid,
        isForwarded: widget.isForwarded);
    if (response != null &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      imagePicked = false;
      EasyLoading.dismiss();
      print("File Uploaded");
      setState(() {
        isLoader = false;
        isButtonEnabled = false;
        replyButton = false;
        replyMessage = null;
      });
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        itemScrollController.scrollTo(
            index: 0,
            duration: Duration(milliseconds: 5),
            curve: Curves.linearToEaseOut);
      });
    } else {
      Commons.novaFlushBarError(context, "Upload failed. Please try again.");
      EasyLoading.dismiss();
      setState(() {
        isButtonEnabled = false;
        replyButton = false;
        replyMessage = null;
        isLoader = false;
      });
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        itemScrollController.scrollTo(
            index: 0,
            duration: Duration(milliseconds: 5),
            curve: Curves.linearToEaseOut);
      });
    }
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
      imagePicked = true;
      if (imageFile != null) {
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
            imagePicked = false;
            await uploadFile(file.path, "image");
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

  bool startedTyping = true;

  _onChangeHandler(value) {}

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
    imagePicked = false;
    if (videoFile != null) {
      if (!isVideoMaxSize(videoFile)) {
        await uploadFile(videoFile.path, "video");
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

  hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          stopAllAudio();
          inChat = false;
          inChatUuid = "";
          senderPhoenix = "";
          serviceLocator<ChatViewModel>().senderGroupPhoenix = "";
          serviceLocator<ChatViewModel>().lastPageData["saveData"] = null;
          await HivePreferences.deleteLastSaved();
          serviceLocator<ChatListViewModel>().setLocal();
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
                          title: searchTextField(
                              model.groupMessages[groupChatDataLocal.uuid]),
                          centerTitle: false,
                          elevation: 0,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          automaticallyImplyLeading: false,
                          leading: null,
                          actions: <Widget>[
                            Container(
                              width:50,
                              child: IconButton(
                                padding: const EdgeInsets.all(0),
                                icon: CustomText(
                                  alignment: Alignment.center,
                                  text: "Cancel",
                                  color: appColor,
                                  fontSize: 13,
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
                                      builder: (context) =>
                                          GroupInfo(groupChatDataLocal)),
                                ).then((value) => Navigator.pop(context));
                              }
                            },
                            child: Container(
                              // height: 40,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      Navigator.pop(context);
                                      stopAllAudio();
                                      inChat = false;
                                      inChatUuid = "";
                                      senderPhoenix = "";
                                      serviceLocator<ChatViewModel>()
                                          .senderGroupPhoenix = "";
                                      serviceLocator<ChatListViewModel>()
                                          .mainChatList
                                          .forEach((chat) {
                                        if (chat.group != null) {
                                          if (chat.group.uuid ==
                                              widget.groupChatData.uuid)
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
                                          Text(
                                            getContactName(
                                                groupChatDataLocal.name ?? ""),
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
                              Container(
                                child: Column(
                                  children: <Widget>[
                                    groupChatDataLocal != null
                                        ? buildListMessage(model.groupMessages[
                                            groupChatDataLocal.uuid])
                                        : Container(),
                                    buildInput()
                                  ],
                                ),
                              ),
                              isLoader
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
                                  : Container(),
                              internet == true
                                  ? Align(
                                      alignment: Alignment.center,
                                      child: isLoading == true
                                          ? Center(child: loader())
                                          : Container(),
                                    )
                                  : Container(),
                            ],
                          )
                        : Stack(
                            children: [
                              Container(
                                child: Column(
                                  children: <Widget>[
                                    groupChatDataLocal != null
                                        ? buildListMessage(_searchResult)
                                        : Container(),
                                    buildInput()
                                  ],
                                ),
                              ),
                              isLoader
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

  Widget buildListMessage(List<MessagePhoenix> groupMessages) {
    return Flexible(
      child: ScrollablePositionedList.builder(
        reverse: true,
        itemScrollController: itemScrollController,
        itemBuilder: (BuildContext context, int index) {
          final message = groupMessages[index];
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
        itemCount: groupMessages?.length ?? 0,
      ),
    );
  }

  Widget imageWidget() {
    return groupChatDataLocal.avatar != ""
        ? Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: customImage(groupChatDataLocal.avatar),
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

    if (message.user.uuid == userUuid) {
      return Row(
        children: [
          Expanded(
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    setState(() {
                      textFieldFocusNode.unfocus();
                      textFieldFocusNode.canRequestFocus = false;
                    });
                  },
                  onLongPress: () {
                    openMessageBox(groupChatId, message);
                  },
                  child: Row(
                    children: <Widget>[
                      message.contentType == "text"
                          // Text
                          ? myTextMessage(
                              ChatBubbleClipper5New(
                                  type: BubbleTypeNew.sendBubble),
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
                                  message.user.uuid,
                                  message)
                              : message.contentType == "video"
                                  //Video
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
                                      //File
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
                                          message.user.uuid,
                                          context,
                                          message)
                                      : message.contentType == "audio"
                                          //Audio
                                          ? myVoiceWidget(
                                              context,
                                              ChatBubbleClipper5New(
                                                  type:
                                                      BubbleTypeNew.sendBubble),
                                              message.file,
                                              message.star,
                                              message.insertedAt,
                                              message.status,
                                              index,
                                              message.user.uuid,
                                              true,
                                              message)
                                          : Container()
                    ],
                    mainAxisAlignment: MainAxisAlignment.end,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Left (peer message)
      return Container(
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      setState(() {
                        textFieldFocusNode.unfocus();
                        textFieldFocusNode.canRequestFocus = false;
                      });
                    },
                    onLongPress: () {
                      openMessageBox(groupChatId, message);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: <Widget>[
                          message.contentType == "text"
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
                                  // Image/GIF
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
                                      //Video
                                      ? myVideoWidget(
                                          ChatBubbleClipper5New(
                                              type:
                                                  BubbleTypeNew.receiverBubble),
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
                                                  type: BubbleTypeNew
                                                      .receiverBubble),
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
                                              //Audio
                                              ? myVoiceWidget(
                                                  context,
                                                  ChatBubbleClipper5New(
                                                      type: BubbleTypeNew
                                                          .receiverBubble),
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
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget myVoiceWidget(BuildContext context, CustomClipper clipper, content,
      star, timeStamp, read, index, id, isPeer, MessagePhoenix message) {
    ChatViewModel viewModel = serviceLocator<ChatViewModel>();
    int actualIndex = viewModel.groupMessages[groupChatDataLocal.uuid]
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
                        Padding(
                            padding: EdgeInsets.fromLTRB(2, 2, 0, 4),
                            child: Text(
                              message.user.name ?? "User",
                              style: TextStyle(
                                  color: appColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: normalStyle,
                                  fontSize: chatFontLabelSize),
                            )),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ProfileCachedNetworkImage(
                                imageUrl:
                                    !isPeer ? message.user.avatar : globalImage,
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
                        timeWidget(timeStamp, read, chatRightTextColor, id)
                      ])),
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
              messageReply: getReplyMessageFromUuid(message.repliedMessageUuid),
              isGroup: true,
              index: actualIndex,
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

    ChatViewModel viewModel = serviceLocator<ChatViewModel>();
    int actualIndex = viewModel.groupMessages[groupChatDataLocal.uuid]
        .indexWhere((item) => item.clientUuid == message.repliedMessageUuid);

    return message.user.uuid == userUuid
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
                      alignment: Alignment.bottomRight,
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
                                                content, message.user.uuid),
                                          )
                                        : contentText(
                                            content, message.user.uuid),
                                  ],
                                ),
                              ),
                              message.hasForwarded != null &&
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
                                  message.user.uuid,
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
                  index: actualIndex,
                  messageReply:
                      getReplyMessageFromUuid(message.repliedMessageUuid),
                  isGroup: true,
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
                    alignment: Alignment.centerRight,
                    child: ChatBubble(
                      clipper: clipper,
                      elevation: 0,
                      alignment: Alignment.bottomRight,
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
                          Padding(
                              padding: const EdgeInsets.fromLTRB(2, 2, 0, 2),
                              child: Text(
                                message.user.name,
                                style: TextStyle(
                                    color: appColor,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: normalStyle,
                                    fontSize: chatFontLabelSize),
                              )),
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
                                                content, message.user.uuid),
                                          )
                                        : contentText(
                                            content, message.user.uuid),
                                  ],
                                ),
                              ),
                              message.hasForwarded != null &&
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
                                  message.fromUuid,
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
                  index: actualIndex,
                  messageReply:
                      getReplyMessageFromUuid(message.repliedMessageUuid),
                  isGroup: true,
                  onSwipedMessage: (message) {
                    setState(() {
                      replyButton = true;
                      replyMessage = message;
                    });
                  },
                ));
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

  myImageWidget(CustomClipper clipper, chatRightColor, chatRightTextColor,
      content, star, timeStamp, read, index, id, MessagePhoenix message) {
    ChatViewModel viewModel = serviceLocator<ChatViewModel>();
    int actualIndex = viewModel.groupMessages[groupChatDataLocal.uuid]
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
                  message.user.uuid != userUuid
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(2, 2, 0, 2),
                          child: Text(
                            message.user.name,
                            style: TextStyle(
                                color: appColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: normalStyle,
                                fontSize: chatFontLabelSize),
                          ))
                      : Container(),
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
                    child: content.contains(".pdf")
                        ? Icon(
                            Icons.note,
                            size: 20,
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
                          "PDF",
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

  myVideoWidget(CustomClipper clipper, chatRightColor, chatRightTextColor,
      content, savedImage, timeStamp, read, index, id, MessagePhoenix message) {
    ChatViewModel viewModel = serviceLocator<ChatViewModel>();
    int actualIndex = viewModel.groupMessages[groupChatDataLocal.uuid]
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
                            await saveVideoImage("GroupMessage",
                                groupChatDataLocal.uuid, message, message.uuid);
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
                          message.user.uuid != userUuid
                              ? Padding(
                                  padding: EdgeInsets.fromLTRB(6, 2, 0, 6),
                                  child: Text(
                                    message.user?.name ?? globalName,
                                    style: TextStyle(
                                      color: appColor,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: normalStyle,
                                      fontSize: chatFontLabelSize,
                                    ),
                                  ),
                                )
                              : Container(),
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
              isGroup: true,
              index: actualIndex,
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

  Widget buildInput() {
    SizeConfig().init(context);
    final deviceHeight = MediaQuery.of(context).size.height;
    return Container(
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? appColor
                          : bgReplyGrayColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                              left: 8, bottom: 8, right: 8, top: 8),
                          color: appColor,
                          width: 4,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                                left: 8, bottom: 8, right: 8, top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${replyMessage.user.name}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    GestureDetector(
                                      child: Icon(Icons.close, size: 16),
                                      onTap: onCancelReply,
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                replyMessage.contentType == "text"
                                    ? Text(
                                        replyMessage.content,
                                        style: TextStyle(color: Colors.black54),
                                      )
                                    : replyMessage.contentType == "image"
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
                                        : replyMessage.contentType == "video"
                                            ? myVideoReplyWidget(
                                                ChatBubbleClipper5New(
                                                    type: BubbleTypeNew
                                                        .receiverBubble),
                                                chatLeftColor,
                                                chatLeftTextColor,
                                                replyMessage.file,
                                                replyMessage.savedImage,
                                                replyMessage.insertedAt,
                                                replyMessage.status,
                                                0,
                                                replyMessage.fromUuid,
                                                replyMessage)
                                            : replyMessage.contentType == "file"
                                                ? myFileReplyWidget(
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
                                                    context,
                                                    replyMessage)
                                                : replyMessage.contentType ==
                                                        "audio"
                                                    ? myVoiceReplyWidget(
                                                        context,
                                                        ChatBubbleClipper5New(
                                                            type: BubbleTypeNew
                                                                .receiverBubble),
                                                        replyMessage.file,
                                                        replyMessage.star,
                                                        replyMessage.insertedAt,
                                                        replyMessage.status,
                                                        0,
                                                        replyMessage.fromUuid,
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
                                  keyboardType: TextInputType.multiline,
                                  onChanged: (val) {
                                    _onChangeHandler(val);
                                    if (val.isNotEmpty) {
                                      serviceLocator<ChatViewModel>()
                                              .messagesLastTyped[
                                          groupChatDataLocal.uuid] = val;
                                      setState(() {
                                        isButtonEnabled = true;
                                      });
                                    } else {
                                      serviceLocator<ChatViewModel>()
                                              .messagesLastTyped[
                                          groupChatDataLocal.uuid] = "";
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
                                    contentPadding: EdgeInsets.all(10.0),
                                    hintStyle: TextStyle(
                                      color: Theme.of(context).brightness !=
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
                                  color: Theme.of(context).brightness !=
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
                                  color: Theme.of(context).brightness !=
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
                                  Commons.createCryptoRandomString(15);
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
                                setState(() {
                                  isRecording = true;
                                });
                              }
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
                                _stopWatchTimer.secondTime.value.toString());
                            Wakelock.disable();
                            await Record().stop();
                            setState(() {
                              button = true;
                              isRecording = false;
                            });
                            if (_stopWatchTimer.secondTime.value > 1) {
                              await uploadFile(pathRecording, "audio");
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
    );
  }

  void _sendMessage() async {
    String replyUuid = "";
    if (replyButton) {
      replyUuid = replyMessage.clientUuid;
    }
    var uuidClient = Uuid().v1();
    serviceLocator<ChatViewModel>().messagesLastTyped[groupChatDataLocal.uuid] =
        "";
    if (await checkInternet()) {
      globalSocketService.push(
          id: groupChatDataLocal.uuid,
          type: "group",
          event: "new_group_message",
          payload: {
            "is_a_reply": replyButton,
            "replied_message_uuid": replyUuid,
            "client_uuid": uuidClient,
            "reply_index": replyIndex,
            "is_forwarding": false,
            "content": EncryptAESData.encryptAES(textEditingController.text)
          });
      // ------------------------------------ //
      globalAmplitudeService?.sendAmplitudeData(
          'Outgoing Group Message Time Stamp', DateTime.now().toString(), true);
      //
    } else {
      Commons.novaFlushBarError(
          context, "Currently offline, please reconnect your internet.");
    }
    textEditingController.text = "";
    serviceLocator<ChatViewModel>().updateLastTyped();
    hideKeyboard();
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      itemScrollController.scrollTo(
          index: 0,
          duration: Duration(milliseconds: 5),
          curve: Curves.linearToEaseOut);
    });
    setState(() {
      isButtonEnabled = false;
      replyMessage = null;
      replyButton = false;
    });
  }

  void _sendForwardedMessage() async {
    String replyUuid = "";
    if (replyButton) {
      replyUuid = replyMessage.clientUuid;
    }
    var uuidClient = Uuid().v1();
    serviceLocator<ChatViewModel>().messagesLastTyped[groupChatDataLocal.uuid] =
        "";
    if (await checkInternet()) {
      globalSocketService.push(
          id: groupChatDataLocal.uuid,
          type: "group",
          event: "new_group_message",
          payload: {
            "is_a_reply": replyButton,
            "replied_message_uuid": replyUuid,
            "client_uuid": uuidClient,
            "reply_index": replyIndex,
            "is_forwarding": true,
            "content":
                EncryptAESData.encryptAES(widget.forwardedMessage.content)
          });
      // ------------------------------------ //
      globalAmplitudeService?.sendAmplitudeData(
          'Outgoing Group Message Time Stamp', DateTime.now().toString(), true);
      //
    } else {
      Commons.novaFlushBarError(
          context, "Currently offline, please reconnect your internet.");
    }
    textEditingController.text = "";
    serviceLocator<ChatViewModel>().updateLastTyped();
    hideKeyboard();
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      itemScrollController.scrollTo(
          index: 0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeIn);
    });
    setState(() {
      isButtonEnabled = false;
      replyMessage = null;
      replyButton = false;
    });
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
    int actualIndex = viewModel.groupMessages[groupChatDataLocal.uuid]
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
                  onPressed: () {
                    if (content.contains(".pdf")) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfViewScreen(content),
                        ),
                      );
                    } else {
                      launchUrl(content);
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ForwardingWidget(message.hasForwarded),
                      message.user.uuid != userUuid
                          ? Padding(
                              padding: EdgeInsets.fromLTRB(2, 2, 0, 6),
                              child: Text(
                                message.user?.name ?? globalName,
                                style: TextStyle(
                                  color: appColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: normalStyle,
                                  fontSize: chatFontLabelSize,
                                ),
                              ),
                            )
                          : Container(),
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
                                      )),
                            SizedBox(width: 5),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                                child: Text(
                              path.basename(content).substring(0, 30),
                              style: TextStyle(
                                color: message.user.uuid == userUuid
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.normal,
                                fontSize: 13.0,
                              ),
                            )),
                          ],
                        ),
                      ),
                      timeWidget(timeStamp, read, chatRightTextColor, id),
                    ],
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
              messageReply: getReplyMessageFromUuid(message.repliedMessageUuid),
              isGroup: true,
              index: actualIndex,
              onSwipedMessage: (message) {
                setState(() {
                  replyButton = true;
                  replyMessage = message;
                });
              },
            ));
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

  MessagePhoenix getReplyMessageFromUuid(String uuid) {
    ChatViewModel viewModel = serviceLocator<ChatViewModel>();
    var existingReplyMessage = viewModel.groupMessages[groupChatDataLocal.uuid]
        .firstWhere((element) => element.clientUuid == uuid,
            orElse: () => null);
    return existingReplyMessage;
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
                                  ForwardMessage(message, "group")),
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
                      globalSocketService.push(
                          id: groupChatDataLocal.uuid,
                          type: "group",
                          event: "delete_group_message",
                          payload: {"uuid": message.uuid});
                      serviceLocator<ChatViewModel>().deleteLocalGroupMessage();
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

  Widget peerOnline(ChatViewModel model) {
    var contact = model.usersData[receiverPhoenix];
    {
      return contact == null
          ? Container()
          : contact.typing == senderPhoenix.toString()
              ? CustomText(
                  text: contact.name + " Typing...",
                  alignment: Alignment.centerLeft,
                  fontSize: 12,
                  color: appColorGrey,
                )
              : Container();
    }
  }

  //This code is for Forwaded Message in Group (Download & upload file to S3)
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
}
