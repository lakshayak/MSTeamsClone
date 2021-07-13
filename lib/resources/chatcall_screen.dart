
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:teams_clone/constants/strings.dart';
import 'package:teams_clone/enum/view_state.dart';
import 'package:teams_clone/models/message.dart';
import 'package:teams_clone/models/user.dart';
import 'package:teams_clone/provider/image_upload_provider.dart';
import 'package:teams_clone/resources/chat_methods.dart';
import 'package:teams_clone/screens/chatscreens/widgets/cached_image.dart';
import 'package:teams_clone/utils/universal_variables.dart';
import 'package:teams_clone/utils/utilities.dart';
import 'package:teams_clone/widgets/appbar_call.dart';
import 'package:teams_clone/widgets/custom_tile.dart';
import 'package:teams_clone/resources/storage_methods.dart';
import 'package:teams_clone/resources/auth_methods.dart';

// Contains chat methods to access during a call
class ChatCallScreen extends StatefulWidget {
  final User receiver;
  ChatCallScreen({required this.receiver});

  @override
  _ChatCallScreenState createState() => _ChatCallScreenState();
}

class _ChatCallScreenState extends State<ChatCallScreen>{
  TextEditingController textFieldController= TextEditingController();
  final AuthMethods _authMethods = AuthMethods();
  final ChatMethods _chatMethods = ChatMethods();
  final StorageMethods _storageMethods = StorageMethods();

  ScrollController _listScrollController = ScrollController();
  late ImageUploadProvider _imageUploadProvider;

  late User sender;
  bool isWriting = false;
  bool showEmojiPicker = false;
  String _currentUserId = '';

  FocusNode textFieldFocus = FocusNode();
  @override
  void initState(){
    super.initState();
    _authMethods.getCurrentUser().then((user){
      _currentUserId = user.uid;
      setState(() {
        sender = User(
          uid: user.uid,
          name: user.displayName,
          profilePhoto: user.photoUrl,
        );
      }
      );
    });
  }
  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  @override
  Widget build(BuildContext context){
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: callcustomAppBar(context),
        body: Column(
          children: <Widget>[
            Flexible(
              child: messageList(),
            ),
            _imageUploadProvider.getViewState == ViewState.LOADING ?
            Container(child: CircularProgressIndicator(),
              margin: EdgeInsets.only(right:15),
              alignment: Alignment.centerRight,)
                :Container(),
            chatControls(),
            showEmojiPicker ? Container(child: emojiContainer()) : Container(),
          ],
        ),
    );
  }

  emojiContainer() {
    return EmojiPicker(
      bgColor: UniversalVariables.separatorColor,
      indicatorColor: UniversalVariables.blueColor,
      rows: 3,
      columns: 7,
      onEmojiSelected: (emoji, category) {
        setState(() {
          isWriting = true;
        });

        textFieldController.text = textFieldController.text + emoji.emoji;
      },
      recommendKeywords: ["face", "happy", "party", "sad"],
      numRecommended: 50,
    );
  }


  Widget messageList() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection(MESSAGES_COLLECTION)
          .document(_currentUserId)
          .collection(widget.receiver.uid)
          .orderBy(TIMESTAMP_FIELD, descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }



        return ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: snapshot.data!.documents.length,
          controller: _listScrollController,
          itemBuilder: (context, index) {
            return chatMessageItem(snapshot.data!.documents[index]);
          },
          reverse: true,
        );
      },
    );
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Container(
        alignment: _message.senderId == _currentUserId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: _message.senderId == _currentUserId
            ? senderLayout(_message)
            : receiverLayout(_message),
      ),
    );
  }


  Widget senderLayout(Message message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      child: Container(
        margin: EdgeInsets.only(top: 12),
        constraints:
        BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
        decoration: BoxDecoration(
          // color: Colors.grey[900],
          color: Color(0xff7474b0),
          borderRadius: BorderRadius.only(
            topLeft: messageRadius,
            topRight: messageRadius,
            bottomLeft: messageRadius,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: getMessage(message),
        ),
      ),
    );
  }

  getMessage(Message message) {
    return message.type != MESSAGE_TYPE_IMAGE ?
    Text(
      message.message.toString(),
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
      ),
    ) : CachedImage(message.photoUrl.toString(), height: 250, width:250, radius:10);
  }


  Widget receiverLayout(Message message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
      BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        //color: Color(0xff7474b0),
        color: Colors.grey[800],
        borderRadius: BorderRadius.only(
          bottomRight: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(message),
      ),
    );
  }

  Widget chatControls(){
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }
    addMediaModal(context){
      showModalBottomSheet(
          context: context,
          elevation:0,
          backgroundColor: Colors.grey[350],
          builder: (context) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: <Widget>[
                      TextButton(
                        child: Icon(
                          Icons.close,
                        ),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Content and tools",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    children: <Widget>[
                      ModalTile(
                        title: "Media",
                        subtitle: "Share Photos and Video",
                        icon: Icons.image_outlined,
                        onTap: () => pickImage(source: ImageSource.gallery),
                      ),
                    ],
                  ),
                ),
              ],
            );
          });
    }

    sendMessage() {
      var text = textFieldController.text;

      Message _message = Message(
        receiverId: widget.receiver.uid.toString(),
        senderId: sender.uid.toString(),
        message: text,
        timestamp: Timestamp.now().toString(),
        type: 'text',
      );

      setState(() {
        isWriting = false;
      });
      textFieldController.text = "";
      _chatMethods.addMessageToDb(_message, sender, widget.receiver);
    }


    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => addMediaModal(context),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                // gradient: UniversalVariables.fabGradient,
                shape: BoxShape.circle,
                color: Color(0xff7474b0),
              ),
              child: Icon(
                  Icons.add,
                  color: Colors.white),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: textFieldController,
                  focusNode: textFieldFocus,
                  onTap: () => hideEmojiContainer(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  onChanged: (val) {
                    (val.length > 0 && val.trim() != "")
                        ? setWritingTo(true)
                        : setWritingTo(false);
                  },
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(
                      color: UniversalVariables.greyColor,
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(5.0),
                        ),
                        borderSide: BorderSide(color: Colors.grey)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(5.0),
                        ),
                        borderSide: BorderSide(color: Colors.grey)
                    ),
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                    fillColor: Colors.grey[800],
                  ),
                ),
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    if (!showEmojiPicker) {
                      // keyboard is visible
                      hideKeyboard();
                      showEmojiContainer();
                    } else {
                      //keyboard is hidden
                      showKeyboard();
                      hideEmojiContainer();
                    }
                  },
                  icon: Icon(Icons.face,
                      color: Colors.grey[300]),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          isWriting
              ? Container()
              : GestureDetector(
            child: Icon(Icons.camera_alt_outlined,
                color: Colors.grey[300]),
            onTap: () => pickImage(source: ImageSource.camera),
          ),
          //    isWriting
          //      ? Container() :
          // Icon(Icons.mic_none_outlined, color: Colors.grey[300],),


          isWriting ? Container(
              margin: EdgeInsets.only(left: 10),
              child: IconButton(
                icon: Icon(
                    Icons.send,
                    size: 25,
                    color: Color(0xff7474b0)
                ),
                onPressed: () => {
                  sendMessage(),
                },
              )) : Container()
        ],
      ),
    );
  }


  void pickImage({required ImageSource source}) async {
    File selectedImage = await Utils.pickImage(source: source);
    _storageMethods.uploadImage(selectedImage,widget.receiver.uid.toString(),
        _currentUserId, _imageUploadProvider);
  }

  CallCustomAppBar callcustomAppBar(context) {

    return CallCustomAppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: false,
      title:  Text("Return to call: " + widget.receiver.name.toString(),
      style: TextStyle(fontSize: 16)),
      //title:  Text("Return to call"),
      actions: [],
    );
  }
}

Future<void> _handleCameraAndMic(Permission permission) async {
  final status = await permission.request();
  print(status);
}

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function()? onTap;

  const ModalTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: CustomTile(
        mini: false,
        onTap: onTap,
        leading: Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: UniversalVariables.receiverColor,
          ),
          padding: EdgeInsets.all(10),
          child: Icon(
            icon,
            color: UniversalVariables.greyColor,
            size: 38,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
    );
  }


}



