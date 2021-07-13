import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:teams_clone/screens/callscreens/pickup/meet_screen.dart';
import 'dart:async';

// Joining a group meeting
class MeetScreen extends StatefulWidget {
  @override
  _MeetScreen createState() => _MeetScreen();
}

class _MeetScreen extends State<MeetScreen> {
  final myController = TextEditingController();
  bool _validateError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        title: Text('Join a meeting'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 250.0,
                  width: 350.0,
                  child: Image.asset('assets/clip.jpg'),
                  //height: MediaQuery.of(context).size.height * 1,
                ),
                //Padding(padding: EdgeInsets.only(top: 5)),
                Text(
                  'Enter the channel name:',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    controller: myController,
                    decoration: InputDecoration(
                      labelText: 'Channel Name',
                      labelStyle: TextStyle(color: Colors.white),
                      hintText: 'Enter',
                      hintStyle: TextStyle(color: Colors.white),
                      errorText:
                      _validateError ? 'Channel name is mandatory' : null,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  child: MaterialButton(
                    onPressed: onJoin,
                    height: 40,
                    color: Colors.deepPurple,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Join',
                          style: TextStyle(color: Colors.white),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onJoin() async {
    setState(() {
      myController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });

    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(channelName: myController.text),
        ));
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}