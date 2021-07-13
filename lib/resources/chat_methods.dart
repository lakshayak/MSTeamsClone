import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teams_clone/constants/strings.dart';
import 'package:teams_clone/models/contact.dart';
import 'package:teams_clone/models/message.dart';
import 'package:teams_clone/models/user.dart';

// Class containing methods needed for messaging
class ChatMethods {

  static final Firestore _firestore = Firestore.instance;
  final CollectionReference _messageCollection = _firestore.collection(MESSAGES_COLLECTION);
  final CollectionReference _userCollection = _firestore.collection(USERS_COLLECTION);

// Adding message to database
  Future<DocumentReference> addMessageToDb(Message message, User sender,
      User receiver) async {
    var map = message.toMap();

    Map<String, dynamic> m1 = map.map((a, b) =>
        MapEntry(a as String, b as dynamic));
    await _messageCollection
        .document(message.senderId)
        .collection(message.receiverId)
        .add(m1);

    addToContacts(senderId: message.senderId.toString(), receiverId: message.receiverId.toString());

    return await _messageCollection
        .document(message.receiverId)
        .collection(message.senderId)
        .add(m1);
  }

// Adding the user to contacts
  addToContacts({required String senderId, required String receiverId}) async {
    Timestamp currentTime = Timestamp.now();
    await addToSenderContacts(senderId, receiverId, currentTime);
    await addToReceiverContacts(senderId, receiverId, currentTime);
  }

  DocumentReference getContactsDocument({required String of, required String forContact}) =>
      _userCollection
          .document(of)
          .collection(CONTACTS_COLLECTION)
          .document(forContact);


  Future<void> addToSenderContacts(
      String senderId,
      String receiverId,
      currentTime,
      ) async {
    DocumentSnapshot senderSnapshot =
    await getContactsDocument(of: senderId, forContact: receiverId).get();

    if (!senderSnapshot.exists) {
      //does not exists
      Contact receiverContact = Contact(
        uid: receiverId,
        addedOn: currentTime,
      );

      var receiverMap = receiverContact.toMap(receiverContact);
      Map<String, dynamic> rm = receiverMap.map((a, b) => MapEntry(a as String, b as dynamic));
      await getContactsDocument(of: senderId, forContact: receiverId)
          .setData(rm);
    }
  }

  Future<void> addToReceiverContacts(
      String senderId,
      String receiverId,
      currentTime,
      ) async {
    DocumentSnapshot receiverSnapshot =
    await getContactsDocument(of: receiverId, forContact: senderId).get();

    if (!receiverSnapshot.exists) {
      //does not exists
      Contact senderContact = Contact(
        uid: senderId,
        addedOn: currentTime,
      );

      var senderMap = senderContact.toMap(senderContact);
      Map<String, dynamic> sm = senderMap.map((a, b) => MapEntry(a as String, b as dynamic));
      await getContactsDocument(of: receiverId, forContact: senderId).setData(sm);
    }
  }

// Method to send an image
  void setImageMsg(String url, String receiverId, String senderId) async {
    Message message;

    message = Message.imageMessage(
        message: "IMAGE",
        receiverId: receiverId,
        senderId: senderId,
        photoUrl: url,
        timestamp: Timestamp.now().toString(),
        type: 'image');

    // create imagemap
    var map = message.toImageMap();
    Map<String, dynamic> m1 = map.map((a, b) =>
        MapEntry(a as String, b as dynamic));

    // var map = Map<String, dynamic>();
    await _messageCollection
        .document(message.senderId)
        .collection(message.receiverId)
        .add(m1);

    _messageCollection
        .document(message.receiverId)
        .collection(message.senderId)
        .add(m1);
  }

  // Fetching contacts of a user
Stream<QuerySnapshot> fetchContacts({required String userId}) => _userCollection
    .document(userId)
    .collection(CONTACTS_COLLECTION)
    .snapshots();

  // Getting the last message to display on the chatlist screen
Stream<QuerySnapshot> fetchLastMessageBetween({
  required String senderId,
  required String receiverId,
}) =>
    _messageCollection
        .document(senderId)
        .collection(receiverId)
        .orderBy("timestamp")
        .snapshots();
}
