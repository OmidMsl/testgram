import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'models/user.dart';
import 'pages/IntroSliderpage.dart';
import 'pages/chats.dart';

void main() {
  runApp(MyApp());
}

// main color theme
const MaterialColor myColor = MaterialColor(0xFF311B92, const <int, Color>{
  50: Color.fromRGBO(49, 27, 146, .1),
  100: Color.fromRGBO(49, 27, 146, .2),
  200: Color.fromRGBO(49, 27, 146, .3),
  300: Color.fromRGBO(49, 27, 146, .4),
  400: Color.fromRGBO(49, 27, 146, .5),
  500: Color.fromRGBO(49, 27, 146, .6),
  600: Color.fromRGBO(49, 27, 146, .7),
  700: Color.fromRGBO(49, 27, 146, .8),
  800: Color.fromRGBO(49, 27, 146, .9),
  900: Color.fromRGBO(49, 27, 146, 1),
});

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Testgram',
      theme: ThemeData(
        primarySwatch: myColor,
        textTheme: TextTheme(
          headline2: TextStyle(
              fontFamily: 'Sans', color: Colors.white, fontSize: 16.0),
          headline3: TextStyle(
              fontFamily: 'Sans', color: Color(0xff414141), fontSize: 16.0),
          subtitle1: TextStyle(
              fontFamily: 'Sans', color: Color(0xff868686), fontSize: 12.0),
        ),
        appBarTheme: AppBarTheme(
          textTheme: TextTheme(
              headline1: TextStyle(color: Colors.white, fontFamily: 'Sans')),
          centerTitle: true,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: IntroSliderPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  // always marked "final".

  List<User> users = [];

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int userIndex = 0;
  // sidebar stuff
  bool isSidebarCollapsed = true;
  double screenWidth, screenHeight;
  final Duration duration = const Duration(milliseconds: 500);
  AnimationController _controller;
  double borderRadius = 0.0;
  ConnectionState connectionState = ConnectionState.waiting;

  @override
  void initState() {
    getUsers();

    _controller = AnimationController(vsync: this, duration: duration);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;

    if (connectionState == ConnectionState.done) {
      return WillPopScope(
        onWillPop: () async {
          if (!isSidebarCollapsed) {
            setState(() {
              _controller.reverse();
              borderRadius = 0.0;
              isSidebarCollapsed = !isSidebarCollapsed;
            });
            return false;
          } else
            return true;
        },
        child: Scaffold(
          backgroundColor:
              isSidebarCollapsed ? myColor : Color.fromRGBO(32, 33, 36, 1.0),
          body: Stack(
            children: <Widget>[
              /*Scaffold(
                backgroundColor: Colors.transparent,
                floatingActionButton: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: FloatingActionButton.extended(
                      heroTag: 'userFAB',
                      onPressed: () {},
                      label: Text(
                        'کاربر جدید',
                        style: TextStyle(fontFamily: 'Sans'),
                      ),
                      icon: Icon(Icons.add),
                    ),
                  ),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
              ),*/
              menu(context),
              // to manage sidebar collaosation
              AnimatedPositioned(
                  left: isSidebarCollapsed ? 0 : 0.6 * screenWidth,
                  right: isSidebarCollapsed ? 0 : -0.2 * screenWidth,
                  top: isSidebarCollapsed ? 0 : screenHeight * 0.1,
                  bottom: isSidebarCollapsed ? 0 : screenHeight * 0.1,
                  duration: duration,
                  curve: Curves.fastOutSlowIn,
                  child: dashboard(context)),
            ],
          ),
        ),
      );
    } else
      return Center(
        child: Container(
          width: 200,
          height: 100,
          child: Card(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircularProgressIndicator(),
                Text(
                  '... در حال اتصال',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sans',
                    color: Colors.deepPurple[900],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  void getUsers() async {
    Response response =
        await get("http://testgram-001-site1.etempurl.com/get_users.php");
    String data = utf8.decode(response.bodyBytes);
    if (data != 'error') {
      var userJson = json.decode(data);
      for (var uj in userJson) {
        User u = User(
            phoneNumber: uj['phone_number'],
            id: uj['id'],
            name: uj['name'],
            bio: uj['bio']);
        widget.users.add(u);
      }
      setState(() {
        connectionState = ConnectionState.done;
      });
    }
    getUsersMainImage();
  }

  void getUsersMainImage() async {
    Response response = await get(
        "http://testgram-001-site1.etempurl.com/get_users_profile_pictures.php");
    String data = utf8.decode(response.bodyBytes);
    if (data != 'error') {
      var userPicJson = json.decode(data);
      for (var upj in userPicJson) {
        String pn = upj['user_number'];
        for (User u in widget.users) {
          if (u.phoneNumber == pn) {
            if (u.imageNames == null) {
              u.imageNames = [];
            }
            u.imageNames.add((upj['picture_adress']).trim());
            break;
          }
        }
      }
      for (User u in widget.users) {
        if (u.imageNames.isNotEmpty)
          setState(() {
            u.image = NetworkImage(
                'http://testgram.parsaspace.com/profile_pics/' +
                    u.imageNames.last);
          });
      }
    }
  }

  Widget menu(context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.6,
            heightFactor: 0.75,
            child: ListView.builder(
                itemCount: widget.users == null ? 0 : widget.users.length,
                itemBuilder: (context, index) {
                  User user = widget.users[index];
                  return InkWell(
                    child: Card(
                      elevation: 0.0,
                      color: userIndex == index
                          ? Colors.white10
                          : Color.fromRGBO(32, 33, 36, 1.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(8.0),
                              topLeft: Radius.circular(8.0))),
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            textDirection: TextDirection.rtl,
                            children: [
                              Text(
                                user.name,
                                style: TextStyle(
                                  fontFamily: 'Vazir',
                                  fontWeight: FontWeight.bold,
                                  color: index == userIndex
                                      ? Colors.blue[400]
                                      : Colors.white,
                                ),
                              ),
                              if (user.image == null)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image:
                                              AssetImage('images/defImage.png'),
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: user.image, fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        userIndex = index;
                      });
                    },
                  );
                }),
          ),
        ),
      ),
    );
  }

  Widget dashboard(context) {
    return SafeArea(
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        type: MaterialType.card,
        animationDuration: duration,
        color: Theme.of(context).scaffoldBackgroundColor,
        elevation: 8,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          child: Scaffold(
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
                    icon: AnimatedIcon(
                      icon: AnimatedIcons.menu_close,
                      progress: _controller,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isSidebarCollapsed) {
                          _controller.forward();

                          borderRadius = 16.0;
                        } else {
                          _controller.reverse();

                          borderRadius = 0.0;
                        }
                        isSidebarCollapsed = !isSidebarCollapsed;
                      });
                    }),
                title: Text(
                  (widget.users.isNotEmpty
                      ? ' گفتگو های ' + widget.users[userIndex].name
                      : 'Testgram'),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).appBarTheme.textTheme.headline1,
                ),
                centerTitle: true,
              ),
            ),
            body: widget.users.isEmpty
                ? SizedBox()
                : ChatsPage(widget.users[userIndex]),
          ),
        ),
      ),
    );
  }
}
