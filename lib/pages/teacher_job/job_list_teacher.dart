import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opec/pages/teacher_job/notification_job.dart';
import 'package:opec/pages/teacher_job/teacher_job_form.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/shared/extension.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/widget/loading.dart';

class JobListTeacherPage extends StatefulWidget {
  const JobListTeacherPage({
    Key? key,
    this.province,
    this.district,
    this.jobType,
    this.salaryStart,
    this.salaryEnd,
  }) : super(key: key);

  final province;
  final district;
  final jobType;
  final salaryStart;
  final salaryEnd;

  @override
  State<JobListTeacherPage> createState() => _JobListTeacherPageState();
}

class _JobListTeacherPageState extends State<JobListTeacherPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final storage = FlutterSecureStorage();
  Future<dynamic> _future = Future.value(null);
  dynamic profile = {
    'firstName': '',
    'lastName': '',
  };
  final int _limit = 10;
  dynamic filter;

  void initState() {
    _setFuture();
    super.initState();
    _callResumeData();
  }

  _setFuture() async {
    setState(() {
      print(widget.jobType);
      print(widget.province);
      print(widget.district);
      print(widget.salaryStart);
      print(widget.salaryEnd);
      _future = postDio(server + 'm/teacherjob/read', {
        'skip': 0,
        'limit': _limit,
        'jobType': widget.jobType,
        'province': widget.province,
        'district': widget.district,
        'salaryStart': widget.salaryStart,
        'salaryEnd': widget.salaryEnd,
      });
    });
  }

  _callResumeData() async {
    var value = await storage.read(key: 'resumeData') ?? "";
    var result = json.decode(value);

    setState(() {
      profile = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
// This is the correct approach of calling unfocus on primary focus
        FocusManager.instance.primaryFocus?.unfocus();
        TextEditingController().clear();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        endDrawer: NotificationJobDrawer(),
        appBar: AppBar(
          elevation: 0,
          actions: [Container()],
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          toolbarHeight: 50,
          flexibleSpace: Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 15,
              right: 15,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    child: Image.asset('assets/images/arrow_left_box_red.png'),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: ListView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 15),
          children: [
            SizedBox(height: 10),
            FutureBuilder<dynamic>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.length > 0) {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      separatorBuilder: (_, __) => SizedBox(height: 10),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) =>
                          _card(snapshot.data[index]),
                    );
                  } else {
                    return Container(
                      height: 500,
                      width: double.infinity,
                      // color: Colors.red,
                      child: Center(
                        child: Text('ไม่มีข้อมูล'),
                      ),
                    );
                  }
                } else if (snapshot.hasError) {
                  return Center(
                    child: Container(
                      color: Colors.white,
                      child: dialogFail(context, reloadApp: true),
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
            SizedBox(height: 10),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 30),
          ],
        ),
      ),
    );
  }

  Widget _card(dynamic model) {
    return GestureDetector(
      onTap: () => {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeacherJobForm(model: model),
          ),
        ),
      },
      child: Container(
        height: 130,
        width: double.infinity,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color(0xFFF7F7F7),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              alignment: Alignment.center,
              child: loadingImageNetwork(
                model['imageUrl'],
                height: 45,
                width: 45,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model['title'],
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 2,
                  ),
                  Text(
                    model['schoolName'],
                    style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF707070),
                        overflow: TextOverflow.ellipsis),
                    maxLines: 1,
                  ),
                  Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFF707070),
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          model['jobTypeName'] == 'PartTime'
                              ? 'ชั่วคราว'
                              : 'ประจำ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF707070),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFF707070),
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          checkSalary(model['salaryStart'], model['salaryEnd']),
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF707070),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => updateBookmark(context, model, profile),
              child: Container(
                height: 30,
                width: 30,
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/bookmark_box_pink.png',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  //
}
