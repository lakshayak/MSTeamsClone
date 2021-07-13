import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teams_clone/models/contact.dart';
import 'package:teams_clone/provider/user_provider.dart';
import 'package:teams_clone/resources/chat_methods.dart';
import 'package:teams_clone/screens/callscreens/pickup/pickup_layout.dart';
import 'package:teams_clone/screens/pageviews/widgets/contact_view.dart';
import 'package:teams_clone/screens/pageviews/widgets/quiet_box.dart';
import 'package:teams_clone/widgets/teams_appbar.dart';

// List of conversations
class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: Colors.black,
        appBar: teamsAppBar(
          title: 'Chat',
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/search_screen");
              },
            ),
          ],
        ),
        body: ChatListContainer(),
      ),
    );
  }
}

class ChatListContainer extends StatelessWidget {
  final ChatMethods _chatMethods = ChatMethods();

  @override
  Widget build(BuildContext context) {
   late UserProvider userProvider = Provider.of<UserProvider>(context);
   return Container(
      child: StreamBuilder<QuerySnapshot>(
          stream: _chatMethods.fetchContacts(
            userId: userProvider.getUser!.uid.toString(),
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var docList = snapshot.data!.documents;

              if (docList.isEmpty) {
                return QuietBox(
                  heading: "Search for people to begin chatting",
                );
              }
              return ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: docList.length,
                itemBuilder: (context, index) {
                  Contact contact = Contact.fromMap(docList[index].data);
                  return ContactView(contact);
                },
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}