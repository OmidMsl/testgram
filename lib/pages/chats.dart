import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:testgram/models/channel.dart';
import 'package:testgram/models/group.dart';
import 'package:testgram/models/message/text_message.dart';
import 'package:testgram/models/user.dart';
import 'package:testgram/pages/conversation.dart';
import 'package:testgram/parsers.dart';

class ChatsPage extends StatefulWidget {
  final User user;
  ChatsPage(this.user);
  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  List<Channel> channels = [];
  List<Group> groups = [];
  List<TextMessage> txtmsgs = [];
  List<User> contacts = [];
  String currentPn;
  // chats
  List<ChatItem> chats = [];

  bool firstTime = true;

  @override
  void initState() {
    // TODO: implement initState
    if (widget.user != null && chats.isEmpty) {
      firstTime = false;
      getChannels();
      getGroups();
      getChats();
      currentPn = widget.user.phoneNumber;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //print('user: ' + widget.user.name);
    if (currentPn != widget.user.phoneNumber) {
      chats = [];
      channels = [];
      groups = [];
      txtmsgs = [];
      contacts = [];
      getChannels();
      getGroups();
      getChats();
      currentPn = widget.user.phoneNumber;
    }
    Size pageSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: List.generate(chats.length, (index) {
            ChatItem ci = chats[index];
            return Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              child: InkWell(
                child: ci.getAsWidget(
                    pageSize.height / 11, pageSize.width, context),
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => ConversationPage(
                                myNumber: widget.user.phoneNumber,
                                messages: ci.user != null
                                    ? ci.user.contactMessages
                                    : ci.group != null
                                        ? ci.group.txtmsgs
                                        : ci.channel.txtmsgs,
                                user: ci.user,
                                channel: ci.channel,
                                group: ci.group,
                              )))
                      .then((value) {
                    chats = [];
                    channels = [];
                    groups = [];
                    txtmsgs = [];
                    contacts = [];
                    getChannels();
                    getGroups();
                    getChats();
                  });
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  void getGroups() async {
    Response response = await post(
        "http://testgram-001-site1.etempurl.com/get_groups.php",
        body: {
          'phone_number': widget.user.phoneNumber,
        });
    String data = utf8.decode(response.bodyBytes);
    if (data != 'error') {
      var groupJson = json.decode(data);
      for (var c in groupJson) {
        Group group = Group(
            id: c['id'],
            link: c['link'],
            name: c['name'],
            pictureName: c['picture_adress'],
            description: c['description'],
            isPublic: c['type'] == '1',
            creator: User(phoneNumber: c['creator_number']));
        if (group.pictureName != null) {
          group.image = NetworkImage(
              'http://testgram.parsaspace.com/channel_group_pics/' +
                  group.pictureName.trim());
        }
        groups.add(group);
      }
    }
    for (Group g in groups) print('group: ' + g.name);
  }

  void getChannels() async {
    Response response = await post(
        "http://testgram-001-site1.etempurl.com/get_channels.php",
        body: {
          'phone_number': widget.user.phoneNumber,
        });
    String data = utf8.decode(response.bodyBytes);
    if (data != 'error') {
      var channelJson = json.decode(data);
      for (var c in channelJson) {
        Channel channel = Channel(
            id: c['id'],
            link: c['link'],
            name: c['name'],
            pictureName: c['picture_adress'],
            signMessages: c['sign_messages'] == '1',
            isPublic: c['type'] == '1',
            description: c['description'],
            isNotificationsOn: c['is_notifications_on'] == '1');
        if (channel.pictureName != null)
          channel.image = NetworkImage(
              'http://testgram.parsaspace.com/channel_group_pics/' +
                  channel.pictureName.trim());
        channels.add(channel);
      }
    }
  }

  void getChats() async {
    Response response = await post(
        "http://testgram-001-site1.etempurl.com/get_text_messages.php",
        body: {
          'phone_number': widget.user.phoneNumber,
        });
    String data = utf8.decode(response.bodyBytes);
    if (data != 'error') {
      var txtmsgJson = json.decode(data);
      for (var tmg in txtmsgJson) {
        String rid = tmg['user_receiver_number'];
        ReceiverType rt = ReceiverType.user;
        if (rid == null) {
          rid = tmg['group_receiver_id'].toString();
          rt = ReceiverType.group;
        }
        if (rid == null) {
          rid = tmg['channel_receiber_id'];
          rt = ReceiverType.channel;
        }
        TextMessage txt = TextMessage(
            id: tmg['id'],
            seen: tmg['seen'] == '1',
            sendDate: Parsers.toDateTime(tmg['send_date'].toString()),
            text: tmg['text'],
            isEdited: tmg['edited'] == '1',
            senderNumber: tmg['sender_number'],
            receiverId: int.parse(rid),
            receiverType: rt);
        txtmsgs.add(txt);
      }
    }
    getContacts();
  }

  void getContacts() async {
    String s = '';
    for (TextMessage tm in txtmsgs) {
      if (tm.receiverType == ReceiverType.user) {
        if (tm.senderNumber == widget.user.phoneNumber)
          s += tm.receiverId.toString() + ', ';
        else
          s += tm.senderNumber + ', ';
      }
    }
    s = s.isEmpty ? '' : s.substring(0, s.length - 2);
    Response response = await post(
        "http://testgram-001-site1.etempurl.com/get_contacts.php",
        body: {
          'contacts': s,
        });
    String data = utf8.decode(response.bodyBytes);
    if (data != 'error') {
      var userJson = json.decode(data);
      for (var u in userJson) {
        List<dynamic> imgs = u['images'];
        User usr = User(
          phoneNumber: u['phone_number'],
          id: u['id'],
          name: u['name'],
          bio: u['bio'],
          lastSeen: Parsers.toDateTime(u['last_seen'].toString()),
        );
        usr.imageNames = [];
        for (int i = 0; i < imgs.length; i++) {
          usr.imageNames.add(imgs[i]);
        }
        contacts.add(usr);
      }
    }
    //createChatItems();
    getContactsImages();
  }

  void createChatItems() {
    for (TextMessage tm in txtmsgs) {
      switch (tm.receiverType) {
        case ReceiverType.user:
          if (widget.user.phoneNumber == tm.receiverId.toString())
            for (User u in contacts) {
              if (u.phoneNumber == tm.senderNumber) {
                u.contactMessages.add(tm);
                break;
              }
            }
          else
            for (User u in contacts) {
              if (u.phoneNumber == tm.receiverId.toString()) {
                u.contactMessages.add(tm);
                break;
              }
            }
          break;
        case ReceiverType.group:
          for (Group g in groups) {
            if (g.id == tm.receiverId) {
              g.txtmsgs.add(tm);
              break;
            }
          }
          break;
        case ReceiverType.channel:
          for (Channel c in channels) {
            if (c.id == tm.receiverId) {
              c.txtmsgs.add(tm);
              break;
            }
          }
          break;
      }
    }

    setState(() {
      for (User u in contacts) {
        chats.add(ChatItem(
            name: u.name,
            lastMessage: u.contactMessages.isEmpty
                ? ''
                : (u.contactMessages.last.senderNumber ==
                            widget.user.phoneNumber
                        ? 'من:'
                        : u.name.split(' ')[0]) +
                    ' ' +
                    u.contactMessages.last.text,
            lastMessageTime: TimeOfDay(
                hour: u.contactMessages.isEmpty
                    ? 0
                    : u.contactMessages.last.sendDate.hour,
                minute: u.contactMessages.isEmpty
                    ? 0
                    : u.contactMessages.last.sendDate.minute),
            numOfNewMessages: 0,
            image: u.image,
            user: u,
            isOnline: false));
      }
      for (Group g in groups) {
        chats.add(ChatItem(
            name: g.name,
            lastMessage: g.txtmsgs.isEmpty ? '' : g.txtmsgs.last.text,
            lastMessageTime: TimeOfDay(
                hour: g.txtmsgs.isEmpty ? 0 : g.txtmsgs.last.sendDate.hour,
                minute: g.txtmsgs.isEmpty ? 0 : g.txtmsgs.last.sendDate.minute),
            numOfNewMessages: 0,
            image: g.image,
            group: g,
            isOnline: false));
      }
      for (Channel c in channels) {
        chats.add(ChatItem(
            name: c.name,
            lastMessage: c.txtmsgs.isEmpty ? '' : c.txtmsgs.last.text,
            lastMessageTime: TimeOfDay(
                hour: c.txtmsgs.isEmpty ? 0 : c.txtmsgs.last.sendDate.hour,
                minute: c.txtmsgs.isEmpty ? 0 : c.txtmsgs.last.sendDate.minute),
            numOfNewMessages: 0,
            image: c.image,
            channel: c,
            isOnline: false));
      }
    });
  }

  void getContactsImages() {
    for (User u in contacts) {
      print(u.imageNames.last);
      setState(() {
        u.image = NetworkImage('http://testgram.parsaspace.com/profile_pics/' +
            u.imageNames.last.trim());
      });
    }
    chats = [];
    createChatItems();
  }
}

class ChatItem {
  String name, lastMessage;
  TimeOfDay lastMessageTime;
  int numOfNewMessages;
  bool isOnline;
  NetworkImage image;
  User user;
  Group group;
  Channel channel;

  ChatItem(
      {this.name,
      this.lastMessage,
      this.isOnline,
      this.lastMessageTime,
      this.numOfNewMessages,
      this.user,
      this.group,
      this.channel,
      this.image});

  Widget getAsWidget(double height, double width, BuildContext context) {
    if (height < 50) height = 50;
    return Container(
      width: width - 32,
      height: height,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Stack(
              children: [
                Container(
                  height: height,
                  width: height,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: image == null
                            ? AssetImage('images/defImage.png')
                            : image,
                        fit: BoxFit.cover),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    bottom: height / 9,
                    child: Image.asset(
                      'images/is_online.png',
                      height: height / 5,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: width - 32 - height - 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.headline3,
                  textAlign: TextAlign.start,
                  textDirection: TextDirection.rtl,
                ),
                Text(
                  lastMessage.replaceAll('<nn>', ' '),
                  style: Theme.of(context).textTheme.subtitle1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  lastMessageTime.hour.toString() +
                      ':' +
                      (lastMessageTime.minute < 10
                          ? lastMessageTime.minute.toString() + '0'
                          : lastMessageTime.minute.toString()),
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Color(0xff707070),
                      fontFamily: 'Vazir')),
              numOfNewMessages != 0
                  ? Card(
                      color: Color(0xffffb300),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(32.0))),
                      child: Container(
                        height: height / 3,
                        width: height / 3.5 +
                            numOfNewMessages.toString().length * 4,
                        child: Text(
                          (numOfNewMessages.toString().length > 3
                              ? '...'
                              : numOfNewMessages.toString()),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'Vazir'),
                        ),
                      ),
                    )
                  : SizedBox(
                      width: 1,
                      height: 1,
                    ),
            ],
          )
        ],
      ),
    );
  }
}
