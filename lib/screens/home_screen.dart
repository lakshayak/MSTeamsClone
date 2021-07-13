import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:teams_clone/enum/user_state.dart';
import 'package:teams_clone/provider/user_provider.dart';
import 'package:teams_clone/resources/auth_methods.dart';
import 'package:teams_clone/resources/local_db/repository/log_repository.dart';
import 'package:teams_clone/screens/callscreens/pickup/pickup_layout.dart';
import 'package:teams_clone/screens/log_screen.dart';
import 'package:teams_clone/screens/pageviews/auth_meet_screen.dart';
import 'package:teams_clone/screens/pageviews/chat_list_screen.dart';
import 'package:teams_clone/utils/universal_variables.dart';

// Main screen visible when user logs in
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver{
  PageController? pageController;
  int _page = 0;
  final AuthMethods _authMethods = AuthMethods();
  late UserProvider userProvider;
  String dbid = '';
  @override
  void initState() {
    super.initState();


    SchedulerBinding.instance!.addPostFrameCallback((_) async{
      userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUser();
      _authMethods.setUserState(
      userId: userProvider.getUser!.uid.toString(),
      userState: UserState.Online,
    );
      dbid = userProvider.getUser!.uid.toString();
  });

    LogRepository.init(isHive: true, dbName: dbid);
    WidgetsBinding.instance!.addObserver(this);
    pageController = PageController();

}

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String currentUserId =
    (userProvider != null && userProvider.getUser.toString() != null)
        ? userProvider.getUser!.uid.toString()
        : "";

    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        currentUserId != null
            ? _authMethods.setUserState(
            userId: currentUserId, userState: UserState.Online)
            : print("resume state");
        break;
      case AppLifecycleState.inactive:
        currentUserId != null
            ? _authMethods.setUserState(
            userId: currentUserId, userState: UserState.Offline)
            : print("inactive state");
        break;
      case AppLifecycleState.paused:
        currentUserId != null
            ? _authMethods.setUserState(
            userId: currentUserId, userState: UserState.Waiting)
            : print("paused state");
        break;
      case AppLifecycleState.detached:
        currentUserId != null
            ? _authMethods.setUserState(
            userId: currentUserId, userState: UserState.Offline)
            : print("detached state");
        break;
    }
  }
  void onPageChanged(int page){
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page){
    pageController!.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    double _labelFontSize = 10;
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: Colors.grey[850],
        body:PageView(
          children: [
            LogScreen(),
            ChatListScreen(),
            MeetScreen(),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: CupertinoTabBar(
              backgroundColor: Colors.grey[850],
              items: [BottomNavigationBarItem(
                icon: Icon(Icons.notifications_none_outlined,
                    color: (_page == 0)
                        ? Colors.white
                        :UniversalVariables.greyColor),
                title:Text(
                  "Activity",
                  style: TextStyle(
                      fontSize: _labelFontSize,
                      color: (_page == 0) ? Colors.white
                          : Colors.grey),
                ),
              ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.chat,
                        color: (_page == 1)
                            ? Colors.white
                            :UniversalVariables.greyColor),
                        title:Text(
                        "Chats",
            style: TextStyle(
              fontSize: _labelFontSize,
              color: (_page == 1) ? Colors.white
                      : Colors.grey[400]),
            ),
          ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_ic_call_outlined,
                      color: (_page == 2)
                          ? Colors.white
                          :UniversalVariables.greyColor),
                  title:Text(
                    "Join Meeting",
                    style: TextStyle(
                        fontSize: _labelFontSize,
                        color: (_page == 2) ? Colors.white
                            : Colors.grey),
                  ),
                ),

              ],
              onTap: navigationTapped,
              currentIndex: _page,
            ),
          ),
        ),
      ),
    );
  }
}
