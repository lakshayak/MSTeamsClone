import 'package:flutter/material.dart';
import 'package:teams_clone/utils/universal_variables.dart';
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget{

  final Widget title;
  final List<Widget> actions;
  final Widget leading;
  final bool centerTitle;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.actions,
    required this.leading,
    required this.centerTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          bottom: BorderSide(
            color: UniversalVariables.separatorColor,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        actions: actions,
        centerTitle: centerTitle,
        title: title,

        leading: leading,
      ),
    );
  }

  final Size preferredSize = const Size.fromHeight(kToolbarHeight);
}