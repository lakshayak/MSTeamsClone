import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teams_clone/provider/user_provider.dart';
import 'package:teams_clone/screens/pageviews/widgets/user_details_container.dart';
import 'package:teams_clone/utils/universal_variables.dart';
import 'package:teams_clone/utils/utilities.dart';

class UserCircle extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return GestureDetector(
      onTap: () => showModalBottomSheet(
          context: context,
          backgroundColor: UniversalVariables.blackColor,
          builder: (context) => UserDetailsContainer(),
          isScrollControlled: true),
      child: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
        shape: BoxShape.circle,
       // borderRadius: BorderRadius.circular(60),
        color: Colors.grey[300],
        ),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Text(
                Utils.getInitials(userProvider.getUser!.name.toString()),
                style: TextStyle(
                  color: Colors.grey[850],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}