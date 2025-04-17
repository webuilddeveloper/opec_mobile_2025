import 'package:flutter/material.dart';
import 'package:opec/widget/text_form_field.dart';

// ignore: must_be_immutable
class SchoolForm extends StatefulWidget {
  SchoolForm({Key? key, this.model}) : super(key: key);

  final dynamic model;

  @override
  _SchoolForm createState() => _SchoolForm();
}

class _SchoolForm extends State<SchoolForm> {
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
            textHeader(context, title: 'ข้อมูลโรงเรียน'),
            textRow(
              context,
              title: 'ชื่อโรงเรียน:',
              value: '${model['schoolName']}',
            ),
            textRow(context, title: 'เขต/อำเภอ:', value: model['district']),
            textRow(context, title: 'จังหวัด:', value: model['province']),
            textRow(
              context,
              title: 'ประเภทโรงเรียน:',
              value: model['schoolType'],
            ),
            SizedBox(height: 25.0),
            textHeader(context, title: 'ข้อมูลติดต่อ'),
            textRow(context, title: 'เว็ปไซต์:', value: '${model['website']}'),
            textRow(context, title: 'เบอร์ติดต่อ:', value: '${model['phone']}'),
          ],
        ),
      ),
    ],
  );
}
