import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:teams_clone/constants/strings.dart';
import 'package:teams_clone/models/call.dart';
import 'package:teams_clone/models/user.dart';
import 'package:teams_clone/provider/user_provider.dart';
import 'package:teams_clone/resources/call_methods.dart';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:teams_clone/screens/chatscreens/widgets/cached_image.dart';
import 'package:teams_clone/resources/chatcall_screen.dart';
import 'package:teams_clone/resources/auth_methods.dart';

// Screen during 1 to 1 voice call
class VoiceCallScreen extends StatefulWidget {
  final Call call;

  VoiceCallScreen({required this.call});

  @override
  _VoiceCallScreenState createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  final CallMethods callMethods = CallMethods();
  final AuthMethods _authMethods = AuthMethods();

  late UserProvider userProvider;
  late StreamSubscription callStreamSubscription;

  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool mutedMic = false;
  late RtcEngine _engine;


  @override
  void initState() {
    super.initState();
    initializeAgora();
  }

  Future<void> initializeAgora() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.joinChannel(null, "firsttry", null, 0);
  }


  // Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableAudio();
  }

  // Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          final info = 'onError: $code';
          _infoStrings.add(info);
          _engine.disableVideo();
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
          _engine.disableVideo();
        });
      },
      leaveChannel: (stats) {
        setState(() {
          _infoStrings.add('onLeaveChannel');
          _users.clear();
          _engine.disableVideo();
        });
      },
      userJoined: (uid, elapsed) {
        setState(() {
          final info = 'userJoined: $uid';
          _infoStrings.add(info);
          _users.add(uid);
          _engine.disableVideo();
        });
      },
      userOffline: (uid, reason) {
        setState(() {
          final info = 'userOffline: $uid , reason: $reason';
          _infoStrings.add(info);
          _users.remove(uid);
          _engine.disableVideo();
        });
      },
      firstRemoteVideoFrame: (uid, width, height, elapsed) {
        setState(() {
          final info = 'firstRemoteVideoFrame: $uid';
          _infoStrings.add(info);
          _engine.disableVideo();
        });
      },
    ));
  }

  // Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<CachedImage> list = [];
    list.add(CachedImage(
      widget.call.callerPic.toString(),
      isRound: false,
      height: 300,

    ));
    _users.forEach((int uid) => list.add(
        CachedImage(
            widget.call.receiverPic.toString(),
        isRound: false,
        height: 300)
    ));
    return list;
  }

  // Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  // Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  // Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
              children: <Widget>[_videoView(views[0])],
            ));
      case 2:
        return Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow([views[0]]),
                _expandedVideoRow([views[1]])
              ],
            ));
      case 3:
        return Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow(views.sublist(0, 2)),
                _expandedVideoRow(views.sublist(2, 3))
              ],
            ));
      case 4:
        return Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow(views.sublist(0, 2)),
                _expandedVideoRow(views.sublist(2, 4))
              ],
            ));
      default:
    }
    return Container();
  }

  void _onMicMute() {
    setState(() {
      mutedMic = !mutedMic;
    });
    _engine.muteLocalAudioStream(mutedMic);
  }


  Future<void> _chatScreen(BuildContext context) async {
    User u;
    if (widget.call.hasDialled == true) {
      u = await _authMethods.getUserDetailsById(widget.call.receiverId);
    }
    else {
      u = await _authMethods.getUserDetailsById(widget.call.callerId);
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatCallScreen(receiver: u)));
  }

  // Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onMicMute,
            child: Icon(
              mutedMic ? Icons.mic_off : Icons.mic,
              color: mutedMic ? Colors.white : Colors.blueAccent,
              size: 22.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: mutedMic ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () async {
               await callMethods.endCall(
                call: widget.call,
              );
               _onCallEnd(context);
            },
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 36.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: () async {
              await _chatScreen(context);
            },
            child: Icon(
              Icons.message_outlined,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _users.clear(); // clear users
    _engine.leaveChannel();
    _engine.destroy(); // destroy sdk
    callStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            _toolbar(),
          ],
        ),
      ),
    );
  }
}

void _onCallEnd(BuildContext context) {
  Navigator.pop(context);
}

