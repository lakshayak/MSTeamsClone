import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teams_clone/models/call.dart';
import 'package:teams_clone/provider/user_provider.dart';
import 'package:teams_clone/resources/call_methods.dart';
import 'package:teams_clone/screens/callscreens/pickup/pickup_screen.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();

  var caller;
  var receiver;

  PickupLayout({
    required this.scaffold, this.receiver, this.caller
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider? userProvider = Provider.of<UserProvider>(context);
    return (userProvider!.getUser!=null)
        ? StreamBuilder<DocumentSnapshot>(
          stream: callMethods.callStream(uid: userProvider.getUser!.uid.toString()),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.data != null) {
              Call call = Call.fromMap(snapshot.data!.data);
              if (call.hasDialled == false) {
                return PickupScreen(call: call);
          }
        }
        return scaffold;
      },
    )
        : Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
      ),
    );
  }
}