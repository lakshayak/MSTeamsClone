import 'dart:math';

import 'package:flutter/material.dart';
import 'package:teams_clone/constants/strings.dart';
import 'package:teams_clone/models/call.dart';
import 'package:teams_clone/models/log.dart';
import 'package:teams_clone/models/user.dart';
import 'package:teams_clone/resources/call_methods.dart';
import 'package:teams_clone/resources/local_db/repository/log_repository.dart';
import 'package:teams_clone/screens/callscreens/call_screen.dart';
import 'package:teams_clone/screens/callscreens/voice_call.dart';


class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({required User from, required User to, context, required bool video}) async {
    Call call = Call(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      channelId: Random().nextInt(1000).toString(),
      hasDialled: null,
      video: video
    );

    Log log = Log(
      callerName: from.name.toString(),
      callerPic: from.profilePhoto.toString(),
      callStatus: CALL_STATUS_DIALLED,
      receiverName: to.name.toString(),
      receiverPic: to.profilePhoto.toString(),
      timestamp: DateTime.now().toString(),
      logId: 0,
    );
    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade & video == true) {
      LogRepository.addLogs(log);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(call: call),
          ));
    }

    if (callMade & video == false){
      LogRepository.addLogs(log);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoiceCallScreen(call: call),
          ));
    }
  }
}