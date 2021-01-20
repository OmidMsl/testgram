import 'package:flutter/material.dart';

import 'message/text_message.dart';
import 'user.dart';

class Group {
  int id;
  String link, name, pictureName, description;
  bool isPublic;
  NetworkImage image;
  User creator;
  List<TextMessage> txtmsgs = [];

  Group({
    this.id,
    this.link,
    this.name,
    this.pictureName,
    this.image,
    this.description,
    this.isPublic,
    this.creator,
  });
}
