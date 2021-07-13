import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teams_clone/screens/pageviews/chat_list_screen.dart';

class NewChatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => ChatListScreen()));
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(50)),
        child: Icon(
          Icons.add_comment,
          color: Colors.white,
          size: 25,
        ),
        padding: EdgeInsets.all(15),
      ),
    );
  }
}