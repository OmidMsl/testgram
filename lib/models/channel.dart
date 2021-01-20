import 'package:flutter/material.dart';

import 'message/text_message.dart';

class Channel {
  int id;
  String link, name, pictureName, description;
  bool signMessages, isPublic, isNotificationsOn;
  NetworkImage image;
  List<TextMessage> txtmsgs = [];

  Channel({
    this.id,
    this.link,
    this.name,
    this.pictureName,
    this.image,
    this.signMessages,
    this.isPublic,
    this.description,
    this.isNotificationsOn,
  });
}
