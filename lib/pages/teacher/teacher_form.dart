import 'package:flutter/material.dart';
import 'package:opec/pages/teacher/check_certificate_teacher.dart';
import 'package:opec/shared/extension.dart';
import 'package:opec/widget/text_form_field.dart';

// ignore: must_be_immutable
class TeacherForm extends StatefulWidget {
  TeacherForm({Key? key, this.model}) : super(key: key);

  final dynamic model;

  @override
  _TeacherForm createState() => _TeacherForm();
}

class _TeacherForm extends State<TeacherForm> {
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
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            return false;
          },
          child: card(context, widget.model),
        ),
      ),
    );
  }
}

card(BuildContext context, dynamic model) {
  double statusBarHeight = MediaQuery.of(context).padding.top;
  return Stack(
    children: [
      Container(
        height: 200,
        width: double.infinity,
        color: Theme.of(context).primaryColor,
        child: Image.asset(
          'assets/background/background_teacher_form.png',
          fit: BoxFit.cover,
        ),
      ),
      Container(
        margin: EdgeInsets.only(top: statusBarHeight + 10, left: 15),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
        child: InkWell(
          onTap: () => {Navigator.pop(context)},
          child: Image.asset('assets/logo/icons/arrow_left.png', width: 30),
        ),
      ),
      // Container(
      //   alignment: Alignment.topCenter,
      //   child: imageCircle(context,
      //       image: '${model['imageUrl']}', margin: EdgeInsets.only(top: 125.0)),
      // ),
      Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 190.0, left: 15.0),
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textHeader(context, title: 'ข้อมูลส่วนบุคคล'),
            textRow(
              context,
              title: 'ชื่อ - สกุล:',
              value: '${model['fullName']}',
            ),
            // textRow(
            //   context,
            //   title: 'สังกัดโรงเรียน:',
            //   value: model['schoolName'],
            // ),
            // textRow(
            //   context,
            //   title: 'กลุ่มวิชาที่สอน:',
            //   value: model['teachSubjectName'],
            // ),
            // textRow(
            //   context,
            //   title: 'ระดับชั้นที่สอน:',
            //   value: model['teachDegreeLevelName'],
            // ),
            textRow(
              context,
              title: 'ตำแหน่ง:',
              value: model['employeePositionName'],
            ),
            SizedBox(height: 25.0),
            textHeader(context, title: 'เกี่ยวกับใบประกอบวิชาชีพ'),
            Row(
              children: [
                Container(
                  width: 145.0,
                  child: Text(
                    'สถานะใบประกอบ วิชาชีพ:',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                  ),
                ),
                Container(child: checkCertificateTeacher(model)),
              ],
            ),
            textRow(
              context,
              title: 'ประเภทใบประกอบ วิชาชีพ:',
              value: model['certificateTypeName'],
            ),
            textRow(
              context,
              title: 'วันออกใบอนุญาต:',
              value: dateStringToDateStringFormat(model['certificateStart']),
            ),
            textRow(
              context,
              title: 'วันหมดอายุ:',
              value: dateStringToDateStringFormat(model['certificateStop']),
            ),
            SizedBox(height: 25.0),
            textHeader(context, title: 'ข้อมูลติดต่อ'),
            textRow(context, title: 'อีเมล:', value: '${model['email']}'),
            textRow(context, title: 'เบอร์ติดต่อ:', value: '${model['phone']}'),
          ],
        ),
      ),
    ],
  );
}
