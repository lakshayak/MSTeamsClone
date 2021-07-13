import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teams_clone/constants/strings.dart';
import 'package:teams_clone/models/call.dart';

// Class that contains methods needed to make a call
class CallMethods {
  final CollectionReference callCollection =
  Firestore.instance.collection(CALL_COLLECTION);

  Stream<DocumentSnapshot> callStream({required String uid}) =>
      callCollection.document(uid).snapshots();

  Future<bool> makeCall({required Call call}) async {
    try {
      call.hasDialled = true; // Checking if user has made the call
      Map<String, dynamic> hasDialledMap = call.toMap(call);

      call.hasDialled = false;
      Map<String, dynamic> hasNotDialledMap = call.toMap(call);

      await callCollection.document(call.callerId).setData(hasDialledMap);
      await callCollection.document(call.receiverId).setData(hasNotDialledMap);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> endCall({required Call call}) async {
    try {
      // Deleting call from firebase
      await callCollection.document(call.callerId).delete();
      await callCollection.document(call.receiverId).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}