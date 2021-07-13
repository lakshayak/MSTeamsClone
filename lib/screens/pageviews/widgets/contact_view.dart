import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teams_clone/models/contact.dart';
import 'package:teams_clone/models/user.dart';
import 'package:teams_clone/provider/user_provider.dart';
import 'package:teams_clone/resources/auth_methods.dart';
import 'package:teams_clone/resources/chat_methods.dart';
import 'package:teams_clone/screens/chatscreens/chat_screen.dart';
import 'package:teams_clone/screens/chatscreens/widgets/cached_image.dart';
import 'package:teams_clone/widgets/custom_tile.dart';
import 'package:teams_clone/widgets/last_message_container.dart';
import 'package:teams_clone/widgets/online_dot_indicator.dart';

// Screen when viewing a contact's information
class ContactView extends StatelessWidget {
  final Contact contact;
  final AuthMethods _authMethods = AuthMethods();

  ContactView(this.contact);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future : _authMethods.getUserDetailsById(contact.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User? user = snapshot.data;

          return ViewLayout(
            contact: user!
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class ViewLayout extends StatelessWidget {
  final User contact;
  final ChatMethods _chatMethods = ChatMethods();

  ViewLayout({
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return CustomTile(
      mini: false,
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiver: contact,
            ),
          )),
      title: Text(
        (contact != null ? contact.name : null) != null ? contact.name.toString() : "..",
        style:
        TextStyle(color: Colors.white, fontFamily: "Arial", fontSize: 19),
      ),
      subtitle: LastMessageContainer(
        stream: _chatMethods.fetchLastMessageBetween(
          senderId: userProvider.getUser!.uid.toString(),
          receiverId: contact.uid.toString(),
        ),
      ),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
        child: Stack(
          children: <Widget>[
            CachedImage(
              contact.profilePhoto.toString(),
              radius: 80,
              isRound: true,
            ),
            OnlineDotIndicator(
              uid: contact.uid.toString(),
            ),
          ],
        ),
      ),
    );
  }
}