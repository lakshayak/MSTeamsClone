import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teams_clone/models/user.dart';
import 'package:teams_clone/resources/auth_methods.dart';
import 'package:teams_clone/screens/callscreens/pickup/pickup_layout.dart';
import 'package:teams_clone/widgets/custom_tile.dart';
import 'chatscreens/chat_screen.dart';

// Screen when user is searching for a contact
class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final AuthMethods _authMethods = AuthMethods();

  List<User> userList = [];
  String query = "";
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _authMethods.getCurrentUser().then((FirebaseUser user) {
      _authMethods.fetchAllUsers(user).then((List<User> list) {
        setState(() {
          userList = list;
        });
      });
    });
  }
  searchAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[700],
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: TextField(
            controller: searchController,
            onChanged: (val) {
              setState(() {
                query = val;
              });
            },
            cursorColor: Colors.white,
            autofocus: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 35,
            ),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  WidgetsBinding.instance?.addPostFrameCallback((_) => searchController.clear());
                },
              ),
              border: InputBorder.none,
              hintText: "Search",
              hintStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 35,
                //color: Color(0x88ffffff),
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }


  buildSuggestions(String query) {
    final List<User> suggestionList = query.isEmpty
    ? []
    : userList.where((User user) {
    String? _getUsername = (user.username)?.toLowerCase();
    String _query = query.toLowerCase();
    String? _getName = (user.name)?.toLowerCase();

    bool matchesUsername = _getUsername!.contains(_query);
    bool matchesName = _getName!.contains(_query);

    return (matchesUsername || matchesName);
    }).toList();


    return ListView.builder(
    itemCount: suggestionList.length,
    itemBuilder: ((context, index) {
    User searchedUser = User(
    uid: suggestionList[index].uid,
    profilePhoto: suggestionList[index].profilePhoto,
    name: suggestionList[index].name,
    username: suggestionList[index].username);

    return CustomTile(
    mini: false,
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            receiver: searchedUser,
            )));
    },
    leading: CircleAvatar(
    backgroundImage: NetworkImage(searchedUser.profilePhoto.toString()),
    backgroundColor: Colors.grey,
    ),
    title: Text(
    searchedUser.username.toString(),
    style: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    ),
    ),
    subtitle: Text(
    searchedUser.name.toString(),
    style: TextStyle(color: Colors.white),
    ),
    );
    }),
    );
  }


  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: Colors.grey[900],

        appBar: searchAppBar(context),
          body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: buildSuggestions(query),
        ),
      ),
    );
  }
}
