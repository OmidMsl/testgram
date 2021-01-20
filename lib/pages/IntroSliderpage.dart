import 'dart:math';

import 'package:flutter/material.dart';

import '../main.dart';

class IntroSliderPage extends StatefulWidget {
  @override
  _IntroSliderPageState createState() => _IntroSliderPageState();
}

class _IntroSliderPageState extends State<IntroSliderPage> {
  int page = 0;
  final pageController = PageController();

  final pages = [
    Container(
      color: Colors.yellowAccent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 0.0, left: 64.0, right: 64.0),
            child: Image.asset('images/vpn.png'),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'متاسفانه دامنه ما فیلتر است \nلطفا از فیلترشکن استفاده نمایید.',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                    fontFamily: 'Sans', color: Colors.black, fontSize: 30.0),
              ),
            ),
          ),
        ],
      ),
    ),
    Container(
      color: Colors.pink,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 0.0),
              child: Image.asset('images/drawer.png', height: 130.0,),
            ),
          ),
          Center(
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 32.0, right: 32.0, top: 50.0),
              child: Text(
                'میتوانید از منوی بالا کاربر مورد نظر خود را تعین کنید.',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                    fontFamily: 'Sans', color: Colors.white, fontSize: 30.0),
              ),
            ),
          ),
        ],
      ),
    ),
    Container(
      color: Colors.cyanAccent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 32, right: 32),
            child: Image.asset('images/text_only.png'),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'میتوانید به کاربر دیگر پیغام بفرستید \nاما فقط پیغام متنی!.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Sans', color: Colors.black, fontSize: 30.0),
              ),
            ),
          ),
        ],
      ),
    ),
    Container(
      color: Colors.black,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Image.asset('images/take_it_easy.jpeg'),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              'این برنامه صرفا آزمایشی است\nلطفا سخت نگیرید',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Sans', color: Colors.white, fontSize: 30.0),
            ),
          ),
        ],
      ),
    ),
  ];

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((page ?? 0) - index).abs(),
      ),
    );
    double zoom = 1.0 + (2.0 - 1.0) * selectedness;
    return new Container(
      width: 25.0,
      child: new Center(
        child: new Material(
          color: Colors.white,
          type: MaterialType.circle,
          child: new Container(
            width: 8.0 * zoom,
            height: 8.0 * zoom,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageView.builder(
              controller: pageController,
              itemCount: pages.length,
              onPageChanged: (int pn) {
                setState(() {
                  page = pn;
                });
              },
              itemBuilder: (_, index) {
                return pages[index];
              }),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Expanded(child: SizedBox()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(pages.length, _buildDot),
                ),
              ],
            ),
          ),
          Visibility(
            visible: page == pages.length - 1,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 90.0),
                child: RaisedButton(
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => MyHomePage()));
                  },
                  child: Text(
                    'ورود به برنامه',
                    style: TextStyle(
                        color: Colors.pink, fontFamily: 'Sans', fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: page != pages.length - 1,
            child: Align(
              alignment: page == 0 || page == 2 ? Alignment.topRight : Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => MyHomePage()));
                  },
                  child: Text(
                    "ورود به برنامه",
                    style: TextStyle(fontFamily: 'Sans'),
                  ),
                  color: Colors.white.withOpacity(0.01),
                ),
              ),
            ),
          ),
          Visibility(
            visible: page != pages.length - 1,
            child: Align(
              alignment: page == 0 || page == 2 ? Alignment.topLeft : Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: FlatButton(
                  onPressed: () {
                    pageController.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut);
                  },
                  child: Text("بعدی", style: TextStyle(fontFamily: 'Sans')),
                  color: Colors.white.withOpacity(0.01),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
