import 'package:flutter/material.dart';

import 'message/text_message.dart';

class User {
  String phoneNumber, id, name, bio;
  DateTime lastSeen;
  List<String> imageNames;
  NetworkImage image;
  List<TextMessage> contactMessages = [];

  User(
      {this.phoneNumber,
      this.id,
      this.name,
      this.bio,
      this.lastSeen,
      this.imageNames,
      this.image});
}
