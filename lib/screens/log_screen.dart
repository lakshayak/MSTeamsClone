import 'package:flutter/material.dart';
import 'package:teams_clone/screens/callscreens/pickup/pickup_layout.dart';
import 'package:teams_clone/widgets/log_list_container.dart';
import 'package:teams_clone/widgets/teams_appbar.dart';

// Screen that displays the logs
class LogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: Colors.black,
        appBar: teamsAppBar(
          title: "Feed",
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pushNamed(context, "/search_screen"),
            ),
          ],
        ),
        //floatingActionButton: FloatingColumn(),
        body: Padding(
          padding: EdgeInsets.only(left: 15),
          child: LogListContainer(),
        ),
      ),
    );
  }
}