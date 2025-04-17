import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opec/shared/extension.dart';
import 'package:opec/widget/button.dart';
import 'package:opec/widget/comment.dart';

// ignore: must_be_immutable
class NotificationExpireForm extends StatefulWidget {
  NotificationExpireForm({
    Key? key,
    this.model,
  }) : super(key: key);

  final dynamic model;

  @override
  _NotificationExpireForm createState() => _NotificationExpireForm();
}

class _NotificationExpireForm extends State<NotificationExpireForm> {
  late Comment comment;
  late int totalExpireDate;
  late String reNewTo;

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overScroll) {
          return false;
        },
        child: ListView(
          shrinkWrap: true,
          children: [
            // Expanded(
            //   child:
            Stack(
              // fit: StackFit.expand,
              // alignment: AlignmentDirectional.bottomCenter,
              // shrinkWrap: true,
              // physics: ClampingScrollPhysics(),
              children: [
                _listView(widget.model),
                Positioned(
                  left: 0,
                  top: (height * 0.5 / 100),
                  child: Container(
                    child: buttonCloseBack(context),
                  ),
                ),
              ],
              // overflow: Overflow.clip,
            ),
            SizedBox(
              height: 50,
            )
            // ),
            // widget.urlComment != '' ? comment : Container(),
          ],
        ),
      ),
    );
  }

  _listView(dynamic model) {
    return ListView(
      shrinkWrap: true, // 1st add
      physics: ClampingScrollPhysics(), // 2nd
      children: [
        SizedBox(
          height: 5.0,
        ),
        Container(
          // color: Colors.green,
          padding: EdgeInsets.only(
            right: 10.0,
            left: 10.0,
          ),
          margin: EdgeInsets.only(left: 10.0, top: 60.0),
          child: Text(
            '${model['title']}',
            style: TextStyle(
              fontSize: 18.0,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w500,
              color: Color(0xFF1B6CA8),
            ),
          ),
        ),
        model["category"] == "examPage"
            ? Container(
                // color: Colors.green,
                padding: EdgeInsets.only(
                  right: 10.0,
                  left: 10.0,
                ),
                margin: EdgeInsets.only(left: 10.0, top: 15.0),
                child: Text(
                  model["description"],
                  style: TextStyle(
                    fontSize: 13.0,
                    fontFamily: 'Kanit',
                    fontWeight: FontWeight.normal,
                  ),
                ),
              )
            : Container(),
        SizedBox(
          height: 10.0,
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          color: Color(0xFF707070).withOpacity(0.5),
          height: 1,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: 10,
                left: 10,
              ),
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(model['imageUrlCreateBy']),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${model['createBy']}',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.w300,
                          ),
                          maxLines: 3,
                        ),
                        Row(
                          children: [
                            Text(
                              model['createSendDate'] != null
                                  ? dateStringToDate(model['createSendDate'])
                                  : '',
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
