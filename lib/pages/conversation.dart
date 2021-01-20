import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:testgram/models/channel.dart';
import 'package:testgram/models/group.dart';
import 'package:testgram/models/message/text_message.dart';
import 'package:testgram/models/user.dart';

class ConversationPage extends StatefulWidget {
  final User user;
  final Group group;
  final Channel channel;
  final String myNumber;
  List<TextMessage> messages;

  ConversationPage(
      {@required this.myNumber,
      @required this.messages,
      this.user,
      this.group,
      this.channel});

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  TextEditingController textController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size pageSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          // appbar shadow
          elevation: 6.0,
          // round shape corners
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.0),
                  bottomRight: Radius.circular(32.0))),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  Navigator.of(context).pop();
                });
              }),
          title: Row(
            textDirection: TextDirection.ltr,
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: widget.user != null
                          ? (widget.user.image == null
                              ? AssetImage('images/defImage.png')
                              : widget.user.image)
                          : widget.group != null
                              ? (widget.group.image == null
                                  ? AssetImage('images/defImage.png')
                                  : widget.group.image)
                              : (widget.channel.image == null
                                  ? AssetImage('images/defImage.png')
                                  : widget.channel.image),
                      fit: BoxFit.cover),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    widget.user != null
                        ? widget.user.name
                        : widget.group != null
                            ? widget.group.name
                            : widget.channel.name,
                    style: Theme.of(context).textTheme.headline2,
                    textAlign: TextAlign.left,
                  ),
                  if (widget.user != null)
                    Text(
                      widget.user.lastSeen.toString(),
                      style: Theme.of(context).textTheme.subtitle1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      textDirection: TextDirection.rtl,
                    ),
                ],
              ),
            ],
          ),
          centerTitle: true,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                children: List.generate(widget.messages.length, (index) {
                  TextMessage message = widget.messages[index];

                  bool amISender = message.senderNumber == widget.myNumber;
                  return Padding(
                    padding: EdgeInsets.only(
                        left: amISender ? 80.0 : 0.0,
                        right: amISender ? 0.0 : 80.0),
                    child: Align(
                      alignment:
                          amISender ? Alignment.topRight : Alignment.topLeft,
                      child: Card(
                        color: amISender ? Colors.blue[700] : Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                          Radius.circular(16.0),
                        )),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                message.text.trim().replaceAll('<nn>', '\n'),
                                style: TextStyle(
                                    fontFamily: 'Sans',
                                    color: amISender
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Container(
            height: 50,
            width: pageSize.width,
            color: Theme.of(context).primaryColor,
            child: Row(
              textDirection: TextDirection.ltr,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0))),
                  color: Colors.white70,
                  child: Container(
                    width: pageSize.width - 60,
                    child: TextField(
                      controller: textController,
                      textDirection: TextDirection.rtl,
                      cursorColor: Colors.blue,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Sans',
                          fontSize: 16.0),
                      decoration: InputDecoration(
                        hintText: 'Message',
                        hintStyle: TextStyle(
                            color: Colors.white70, fontFamily: 'Sans'),
                        alignLabelWithHint: true,
                        contentPadding: const EdgeInsets.all(8.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: () {
                      if (textController.text.trim().isNotEmpty) {
                        String sid;
                        ReceiverType rt;
                        if (widget.user != null) {
                          sid = widget.user.phoneNumber;
                          rt = ReceiverType.user;
                        } else if (widget.group != null) {
                          sid = widget.group.id.toString();
                          rt = ReceiverType.group;
                        } else {
                          sid = widget.channel.id.toString();
                          rt = ReceiverType.channel;
                        }
                        TextMessage message = TextMessage(
                            isEdited: false,
                            seen: false,
                            sendDate: DateTime.now(),
                            text: textController.text.trim(),
                            senderNumber: widget.myNumber,
                            receiverId: int.parse(sid),
                            receiverType: rt);
                        setState(() {
                          widget.messages.add(message);
                          textController.text = '';
                        });
                        insertText(message);
                      }
                    })
              ],
            ),
          ),
        ],
      ),
    );
  }

  void insertText(TextMessage message) {
    post("http://testgram-001-site1.etempurl.com/import_text.php", body: {
      'text': message.text.replaceAll('\n', '<nn>'),
      'sender_number': message.senderNumber,
      (message.receiverType == ReceiverType.user
          ? 'user_receiver_number'
          : message.receiverType == ReceiverType.group
              ? 'group_receiver_id'
              : 'channel_receiber_id'): message.receiverId.toString(),
    }).then((response) {
      String res = utf8.decode(response.bodyBytes);
      print(res);
    });
  }
}
