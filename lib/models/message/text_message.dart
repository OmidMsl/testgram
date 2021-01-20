class TextMessage {
  int id, receiverId;
  bool seen, isEdited;
  DateTime sendDate;
  String text, senderNumber;
  ReceiverType receiverType;

  TextMessage({
    this.id,
    this.seen,
    this.sendDate,
    this.text,
    this.isEdited,
    this.senderNumber,
    this.receiverId,
    this.receiverType,
  });
}

enum ReceiverType {
  user,
  group,
  channel,
}
