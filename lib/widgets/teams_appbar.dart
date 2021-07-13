import 'package:flutter/material.dart';
import 'package:teams_clone/screens/chatscreens/widgets/cached_image.dart';
import 'package:teams_clone/screens/pageviews/widgets/user_circle.dart';
import 'package:teams_clone/widgets/appbar.dart';

class teamsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final title;
  final List<Widget> actions;

  const teamsAppBar({
    Key? key,
    required this.title,
    required this.actions,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      leading:   UserCircle(),
      title: (title is String)
          ? Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 30

        ),
      )
          : title,
      centerTitle: false,
      actions: actions,
    );
  }

  final Size preferredSize = const Size.fromHeight(kToolbarHeight + 10);
}