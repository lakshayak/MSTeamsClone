import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:teams_clone/constants/strings.dart';
import 'package:teams_clone/models/message.dart';
import 'package:teams_clone/models/user.dart';
import 'package:teams_clone/provider/image_upload_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teams_clone/resources/chat_methods.dart';

// In order to store images
class StorageMethods {
  static final Firestore firestore = Firestore.instance;
  late StorageReference _storageReference;
  User user = User();


  Future<String?> uploadImageToStorage(File imageFile) async {
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');
      StorageUploadTask storageUploadTask =
      _storageReference.putFile(imageFile);
      var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
      return url;
    } catch (e) {
      return null;
    }
  }

void uploadImage(File image, String receiverId, String senderId,
    ImageUploadProvider imageUploadProvider) async{
  // Set some loading value to db and show it to user
  final ChatMethods chatMethods = ChatMethods();
  imageUploadProvider.setToLoading();

  // Get url from the image bucket
  String? url = await uploadImageToStorage(image);

  // Hide loading
  imageUploadProvider.setToIdle();

  chatMethods.setImageMsg(url!, receiverId, senderId);
}

}
