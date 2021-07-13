import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:teams_clone/constants/strings.dart';
import 'package:teams_clone/models/call.dart';
import 'package:teams_clone/models/log.dart';
import 'package:teams_clone/models/user.dart';
import 'package:teams_clone/resources/call_methods.dart';
import 'package:teams_clone/resources/local_db/repository/log_repository.dart';
import 'package:teams_clone/screens/callscreens/call_screen.dart';
import 'package:teams_clone/screens/callscreens/voice_call.dart';
import 'package:teams_clone/screens/chatscreens/widgets/cached_image.dart';

// Screen seen to receiver of call
class PickupScreen extends StatefulWidget {
  final Call call;
  PickupScreen({
    required this.call
  });

  @override
  _PickupScreenState createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final CallMethods callMethods = CallMethods();

  bool isCallMissed = true;

  addToLocalStorage({required String callStatus}) {
    Log log = Log(
      callerName: widget.call.callerName.toString(),
      callerPic: widget.call.callerPic.toString(),
      receiverName: widget.call.receiverName.toString(),
      receiverPic: widget.call.receiverPic.toString(),
      timestamp: DateTime.now().toString(),
      callStatus: callStatus,
      logId: 0);


    LogRepository.addLogs(log);
  }

  @override
  void dispose() {
    if (isCallMissed) {
      addToLocalStorage(callStatus: CALL_STATUS_MISSED);
    }
    super.dispose();
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Incoming...",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            SizedBox(height: 50),
            CachedImage(
              widget.call.callerPic.toString(),
              isRound: true,
              radius: 180,
            ),
            SizedBox(height: 15),
            Text(
              widget.call.callerName.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 75),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.call_end),
                  color: Colors.redAccent,
                  onPressed: () async {
                    isCallMissed = false;
                    addToLocalStorage(callStatus: CALL_STATUS_RECEIVED);
                    await callMethods.endCall(call: widget.call);
                  },
                ),
                SizedBox(width: 25),
                IconButton(
                  icon: Icon(Icons.call),
                  color: Colors.green,
                    onPressed: () async {
                      await _handleCameraAndMic(Permission.camera);
                      await _handleCameraAndMic(Permission.microphone);
                      print(widget.call.video);
                      if (widget.call.video == true){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CallScreen(call: widget.call)));
                      }
                      if (widget.call.video == false){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VoiceCallScreen(call: widget.call),
                            ));
                      }
                  })
              ],
            ),
          ],
        ),
      ),
    );
  }
}