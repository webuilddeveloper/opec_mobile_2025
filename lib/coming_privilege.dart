import 'package:flutter/material.dart';

class ComingPrivilege extends StatefulWidget {
  @override
  _ComingPrivilege createState() => _ComingPrivilege();
}

class _ComingPrivilege extends State<ComingPrivilege> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Note: Sensitivity is integer used when you don't want to mess up vertical drag
        if (details.delta.dx > 10) {
          // Right Swipe
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        //appBar: header(context, goBack, title: 'สิทธิพิเศษ'),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            return false;
          },
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Container(
              padding: EdgeInsets.only(
                  left: ((MediaQuery.of(context).size.width / 100) * 5),
                  top: ((MediaQuery.of(context).size.width / 100) * 12)),
              alignment: Alignment.topLeft,
              //alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/background/bg_privilege.png"),
                  fit: BoxFit.fill,
                ),
              ),
              child: InkWell(
                onTap: () => goBack(),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:
                          AssetImage("assets/logo/icons/bg_left_privilege.png"),
                      //fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void goBack() async {
    Navigator.pop(context, false);
  }
}
