import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nova/services/services_locator.dart';
import 'package:nova/ui/chat/archive_chat_list.dart';
import 'package:nova/ui/broadcasts/showbroadcastlist.dart';
import 'package:nova/ui/chat/main_chat_list.dart';
import 'package:nova/ui/groupchats/showgroups.dart';
import 'package:nova/ui/chat/newchat.dart';
import 'package:nova/ui/settings/setting_options.dart';
import 'package:nova/ui/widgets/network_aware.dart';
import 'package:nova/utils/commons.dart';
import 'package:flutter/material.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/viewmodels/chat_list_viewmodel.dart';
import 'package:provider/provider.dart';

class MainTabList extends StatefulWidget {
  MainTabList();

  @override
  _MainTabListState createState() => _MainTabListState();
}

class _MainTabListState extends State<MainTabList>
    with AutomaticKeepAliveClientMixin<MainTabList>, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  TabController _tabController;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != 0) {
        inHome = false;
      } else {
        inHome = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatListViewModel>.value(
      value: serviceLocator<ChatListViewModel>(),
      child: Consumer<ChatListViewModel>(
        builder: (context, model, child) => Stack(
          children: <Widget>[
            Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight + 50),
                  child: Material(
                      elevation: 4,
                      child: AppBar(
                        bottom: TabBar(
                          controller: _tabController,
                          indicatorColor: Colors.white,
                          indicatorSize: TabBarIndicatorSize.tab,
                          isScrollable: true,
                          labelStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: "DMSans-Regular"),
                          labelPadding: EdgeInsets.symmetric(horizontal: 25),
                          tabs: [
                            Tab(text: "Chats"),
                            Tab(text: "Broadcasts"),
                            Tab(text: "Groups"),
                            Tab(icon: Icon(Icons.archive_outlined)),
                          ],
                        ),
                        title: Padding(
                          padding: EdgeInsets.only(top: 10, left: 8),
                          child: SvgPicture.asset(
                            'assets/images/nova.svg',
                            color: Colors.white,
                          ),
                        ),
                        centerTitle: false,
                        flexibleSpace: Container(
                          color: appColor,
                        ),
                        elevation: 0,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        automaticallyImplyLeading: false,
                        actions: <Widget>[
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SettingsOptions()),
                              );
                            },
                            color: Colors.white,
                            padding: EdgeInsets.only(top: 8),
                            icon: SvgPicture.asset(
                              'assets/images/settings.svg',
                              width: 18.0,
                              height: 18.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ))),
              body: NetworkAwareWidget(
                  onlineChild: TabBarView(
                    controller: _tabController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      ChatList(),
                      ShowBroadcastList(),
                      ShowGroups(),
                      ArchiveChatList(model.mainChatList),
                    ],
                  ),
                  offlineChild: Commons.offLineWidget()),
            ),
            Positioned(
                bottom: 16,
                right: 0,
                child: Padding(
                    padding: EdgeInsets.only(bottom: 0, right: 16),
                    child: FloatingActionButton(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => NewChat()));
                      },
                      child: SvgPicture.asset(
                        'assets/images/newmessagefab.svg',
                        width: 48,
                        height: 48,
                        colorFilter: null,
                      ),
                    ))),
          ],
        ),
      ),
    );
  }
}
