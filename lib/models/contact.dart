import 'package:cloud_firestore/cloud_firestore.dart';

// For accessing a contact
class Contact  {
  String uid = '';
  late Timestamp addedOn;

  // Required parameters
  Contact({
    required this.uid,
    required this.addedOn,
  });

  // Information provided to contact map
  Map toMap(Contact contact) {
    var data = Map<String, dynamic>();
    data['contact_id'] = contact.uid;
    data['added_on'] = contact.addedOn;
    return data;
  }
  // Information retrieved from contact map
  Contact.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['contact_id'];
    this.addedOn = mapData["added_on"];
  }
}