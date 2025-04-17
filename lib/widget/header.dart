import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/services.dart';

header(
  BuildContext context,
  Function functionGoBack, {
  String title = '',
  bool isButtonRight = false,
  Function? rightButton,
  String menu = '',
}) {
  return AppBar(
    centerTitle: true,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            Color(0xFFEEBA33),
            Color(0xFFEEBA33),
            Color(0xFFEEBA33),
          ],
        ),
      ),
    ),
    backgroundColor: Color(0xFF9A1120),
    elevation: 0.0,
    titleSpacing: 5,
    automaticallyImplyLeading: false,
    title: Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        fontFamily: 'Kanit',
        color: Colors.white,
      ),
    ),
    leading: InkWell(
      onTap: () => functionGoBack(),
      child: Container(
        // height: height * 7 / 100, // Your Height
        // width: width * 12 / 100, // Your width
        child: Image.asset(
          "assets/images/arrow_left.png",
          color: Colors.white,
          width: 40,
          height: 40,
        ),
      ),
    ),

    actions: <Widget>[
      isButtonRight == true
          ? menu == 'notification'
              ? Container(
                // padding: EdgeInsets.only(right: 10.0),
                child: Container(
                  child: Container(
                    width: 42.0,
                    height: 42.0,
                    margin: EdgeInsets.only(top: 6.0, right: 10.0, bottom: 6.0),
                    padding: EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap:
                          () => rightButton == null ? () => {} : rightButton(),
                      child: Image.asset('assets/images/task_list.png'),
                    ),
                  ),
                ),
              )
              : Container(
                // padding: EdgeInsets.only(right: 10.0),
                child: Container(
                  child: Container(
                    width: 42.0,
                    height: 42.0,
                    margin: EdgeInsets.only(top: 6.0, right: 10.0, bottom: 6.0),
                    padding: EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap:
                          () => rightButton == null ? () => {} : rightButton(),
                      child: Image.asset('assets/logo/icons/Group344.png'),
                    ),
                  ),
                ),
              )
          : Container(),
    ],
  );
}

headerV2(
  BuildContext context, {
  String title = '',
  required Function callback,
  int showNoti = 0,
}) {
  return AppBar(
    centerTitle: false,
    backgroundColor: Colors.white,
    elevation: 0.0,
    titleSpacing: 0,
    automaticallyImplyLeading: false,
    title: Image.asset('assets/images/header_opec.png', width: 175, height: 35),
    actions: <Widget>[
      Stack(
        children: [
          GestureDetector(
            onTap: () => callback(),
            child: Container(
              width: 40.0,
              height: 40.0,
              margin: EdgeInsets.only(right: 10, top: 6),
              decoration: BoxDecoration(
                borderRadius: new BorderRadius.circular(15),
                color: Color(0xFFEEBA33),
              ),
              padding: EdgeInsets.all(8.0),
              child: Image.asset('assets/logo/icons/Path1.png'),
            ),
          ),
          Positioned(
            top: 0,
            right: 2,
            child: badges.Badge(
              // padding: EdgeInsets.all(3),
              showBadge: showNoti > 0 ? true : false,
              position: badges.BadgePosition.topEnd(),
              badgeContent: Text(
                showNoti.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

headerV3(
  BuildContext context,
  Function functionGoBack, {
  String title = '',
  bool isButtonRight = false,
  required Function rightButton,
  String menu = '',
}) {
  return AppBar(
    centerTitle: true,
    flexibleSpace: Container(),
    backgroundColor: Color(0xFFF7F7F7),
    elevation: 0.0,
    titleSpacing: 10,
    automaticallyImplyLeading: false,
    title: Text(
      '',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        fontFamily: 'Kanit',
        color: Colors.white,
      ),
    ),
    leading: InkWell(
      onTap: () => functionGoBack(),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Container(
          padding: EdgeInsets.all(10),
          height: 40, // Your Height
          width: 40, // Your width
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0XFFE4E4E4),
          ),
          child: Image.asset(
            "assets/logo/icons/backLeft.png",
            color: Color(0XFF9A1120),
            fit: BoxFit.fill,
          ),
        ),
      ),
    ),
    actions: <Widget>[
      isButtonRight == true
          ? menu == 'notification'
              ? Container(
                // padding: EdgeInsets.only(right: 10.0),
                child: Container(
                  child: Container(
                    width: 42.0,
                    height: 42.0,
                    margin: EdgeInsets.only(top: 6.0, right: 10.0, bottom: 6.0),
                    padding: EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () => rightButton(),
                      child: Image.asset('assets/images/task_list.png'),
                    ),
                  ),
                ),
              )
              : Container(
                // padding: EdgeInsets.only(right: 10.0),
                child: Container(
                  child: Container(
                    width: 42.0,
                    height: 42.0,
                    margin: EdgeInsets.only(top: 6.0, right: 10.0, bottom: 6.0),
                    padding: EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () => rightButton(),
                      child: Image.asset('assets/logo/icons/Group344.png'),
                    ),
                  ),
                ),
              )
          : Container(),
    ],
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  );
}

headerCalendar(
  BuildContext context,
  Function functionGoBack,
  bool showCalendar, {
  String title = '',
  required Function rightButton,
}) {
  return AppBar(
    centerTitle: true,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[Color(0xFFEEBA33), Color(0xFFEEBA33)],
        ),
      ),
    ),
    backgroundColor: Color(0xFF000070),
    elevation: 0.0,
    titleSpacing: 5,
    automaticallyImplyLeading: false,
    title: Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        fontFamily: 'Kanit',
        color: Colors.white,
      ),
    ),
    leading: InkWell(
      onTap: () => functionGoBack(),
      child: Container(
        child: Image.asset(
          "assets/images/arrow_left.png",
          color: Colors.white,
          width: 40,
          height: 40,
        ),
      ),
    ),
    actions: <Widget>[
      Container(
        child: Container(
          child: Container(
            width: 42.0,
            height: 42.0,
            margin: EdgeInsets.only(top: 6.0, right: 10.0, bottom: 6.0),
            padding: EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => rightButton(),
              // child: Image.asset('assets/images/task_list.png'),
              child:
                  showCalendar
                      ? Image.asset('assets/logo/icons/Group878.png')
                      : Image.asset(
                        'assets/images/icon_calendar.png',
                        color: Colors.white,
                      ),
            ),
          ),
        ),
      ),
    ],
  );
}

headerV2Notification(
  BuildContext context,
  Function functionGoBack, {
  String title = '',
  bool isButtonRight = false,
  required Function rightButton,
  String menu = '',
  required int notiCount,
}) {
  return AppBar(
    centerTitle: false,
    flexibleSpace: Container(),
    backgroundColor: Colors.white,
    elevation: 0.0,
    titleSpacing: 5,
    automaticallyImplyLeading: false,
    title: Row(
      children: [
        InkWell(
          onTap: () => functionGoBack(),
          child: Container(
            child: Image.asset(
              "assets/images/arrow_left.png",
              color: Color(0xFFEEBA33),
              width: 35,
              height: 50,
            ),
          ),
        ),
        // SizedBox(width: 15),
        Text(
          title,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Kanit',
            color: Color(0xFF707070),
          ),
        ),
        SizedBox(width: 15),
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.red,
          ),
          height: 30,
          width: 30,
          child: Text(
            notiCount.toString(),
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
              fontFamily: 'Kanit',
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
    // leading: InkWell(
    //   onTap: () => functionGoBack(),
    //   child: Container(
    //     child: Image.asset(
    //       "assets/images/arrow_left.png",
    //       color: Color(0xFFEEBA33),
    //       width: 20,
    //       height: 20,
    //     ),
    //   ),
    // ),
    actions: <Widget>[
      isButtonRight == true
          ? menu == 'notification'
              ? Container(
                child: Container(
                  child: Container(
                    width: 45.0,
                    height: 45.0,
                    margin: EdgeInsets.only(top: 6.0, right: 10.0, bottom: 6.0),
                    padding: EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () => rightButton(),
                      child: Image.asset(
                        'assets/noti_list.png',
                        color: Color(0xFFEEBA33),
                      ),
                    ),
                  ),
                ),
              )
              : Container(
                child: Container(
                  child: Container(
                    width: 24.0,
                    height: 24.0,
                    margin: EdgeInsets.only(top: 6.0, right: 10.0, bottom: 6.0),
                    padding: EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () => rightButton(),
                      child: Image.asset('assets/logo/icons/Group344.png'),
                    ),
                  ),
                ),
              )
          : Container(),
    ],
  );
}
