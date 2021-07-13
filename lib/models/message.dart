import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
// For sending or receiving a message
class Message {
  String? senderId;
  String? receiverId;
  String? type;
  String? message;
  String? timestamp;
  String? photoUrl;

  Message({required this.senderId, required this.receiverId, required this.type, required this.timestamp, required this.message});

  // Will be only called when an image is sent
  Message.imageMessage(
      {required this.senderId,
        required this.receiverId,
        required this.message,
        required this.type,
        required this.timestamp,
        required this.photoUrl});

  // Providing information to message map
  Map toMap() {
    var map = Map<String, dynamic>();
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['message'] = this.message;
    map['timestamp'] = this.timestamp;
    map['photoUrl'] = this.photoUrl;
    return map;
  }

  // Retrieving information from message map
  Message.fromMap(Map<String, dynamic> map) {
    this.senderId = map['senderId'];
    this.receiverId = map['receiverId'];
    this.type = map['type'];
    this.message = map['message'];
    this.timestamp = map['timestamp'];
    this.photoUrl = map['photoUrl'];
  }
  // Providing information to image map
  Map toImageMap() {
    var map = Map<String, dynamic>();
    map['message'] = this.message;
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['timestamp'] = this.timestamp;
    map['photoUrl'] = this.photoUrl;
    return map;
  }



}