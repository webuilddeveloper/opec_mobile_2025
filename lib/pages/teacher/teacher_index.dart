import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:opec/pages/teacher/teacher_list.dart';
import 'package:opec/widget/button.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/widget/header.dart';

class BuildTeacherIndex extends StatefulWidget {
  BuildTeacherIndex({
    Key? key,
    this.menuModel,
    this.model,
    this.isAppbar = false,
  }) : super(key: key);

  final Future<dynamic>? model;
  final Future<dynamic>? menuModel;
  final bool isAppbar;

  @override
  BuildTeacherIndexState createState() => BuildTeacherIndexState();
}

class BuildTeacherIndexState extends State<BuildTeacherIndex> {
  dynamic _tempModel = {'imageUrl': '', 'firstName': '', 'lastName': ''};
  final textEditingController = TextEditingController();

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
        backgroundColor: Colors.white,
        appBar:
            widget.isAppbar
                ? PreferredSize(
                  preferredSize: Size.fromHeight(0),
                  child: AppBar(),
                )
                : header(
                  context,
                  () => {Navigator.pop(context)},
                  title: 'ตรวจสอบข้อมูลครู',
                ),
        body: new InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: FutureBuilder<dynamic>(
            future: widget.menuModel,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                return screen(snapshot.data, false);
              } else if (snapshot.hasError) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  height: 90,
                  child: Center(child: Text('Network ขัดข้อง')),
                );
              } else {
                return screen(_tempModel, true);
              }
            },
          ),
        ),
      ),
    );
  }

  screen(dynamic model, bool isLoading) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text(
              'ค้นหาข้อมูลคุณครู',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Container(
            child: Text(
              'กรุณากรอกชื่อและนามสกุลของคุณครูที่ท่านต้องการตรวจสอบ',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          SizedBox(height: 30),
          Center(
            child: Container(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      'ชื่อ นามสกุล',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  TextFormField(
                    obscureText: false,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Kanit',
                      fontSize: 16.0,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFE8CACD),
                      contentPadding: EdgeInsets.fromLTRB(15.0, 5.0, 5.0, 5.0),
                      hintText: 'กรุณากรอกชื่อและนามสกุล',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      errorStyle: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Kanit',
                        fontSize: 10.0,
                      ),
                    ),
                    controller: textEditingController,
                  ),
                  SizedBox(height: 20),
                  buttonFull(
                    title: 'ค้นหา',
                    backgroundColor: Theme.of(context).primaryColor,
                    fontColor: Colors.white,
                    callback: () => {checkNameEmpty()},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  checkNameEmpty() {
    FocusScope.of(context).unfocus();
    if (textEditingController.text != '') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => TeacherList(keySearch: textEditingController.text),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialogFail(
            context,
            title: 'กรุณากรอกชื่อและนามสกุล',
            background: Colors.transparent,
          );
        },
      );
    }
  }

  // .end
}
