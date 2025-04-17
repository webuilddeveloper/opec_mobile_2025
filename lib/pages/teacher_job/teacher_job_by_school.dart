import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opec/pages/teacher_job/notification_job.dart';
import 'package:opec/pages/teacher_job/post_teacher_job_form.dart';
import 'package:opec/pages/teacher_job/profile_job_by_school.dart';
import 'package:opec/pages/teacher_job/teacher_job_form_by_school.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/shared/extension.dart';
import 'package:opec/user.dart';
import 'package:opec/widget/dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TeacherJobBySchoolPage extends StatefulWidget {
  const TeacherJobBySchoolPage({
    Key? key,
    this.model,
    required this.userData,
    this.color,
    required this.profileCode,
  }) : super(key: key);

  final dynamic model;
  final User userData;
  final Color? color;
  final String profileCode;

  @override
  State<TeacherJobBySchoolPage> createState() => _TeacherJobBySchoolPageState();
}

class _TeacherJobBySchoolPageState extends State<TeacherJobBySchoolPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final storage = FlutterSecureStorage();
  Future<dynamic> _futureNotable = Future.value(null);
  Future<dynamic> _futureResume = Future.value(null);
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  dynamic profile = {'firstName': '', 'lastName': ''};

  void initState() {
    _callRead();
    _setFuture();

    super.initState();
  }

  _setFuture() async {
    setState(() {
      _futureResume = postDio('${server}m/teacherjob/resume/read', {
        'skip': 0,
        'limit': 4,
        'profileCode': '',
      });
    });
  }

  void dispose() {
    super.dispose();
  }

  _callRead() {
    _futureNotable = postDio('${server}m/teacherjob/read', {
      "profileCode": widget.profileCode,
    });
  }

  _onRefresh() {
    setState(() {
      _futureNotable = postDio('${server}m/teacherjob/read', {
        "profileCode": widget.profileCode,
      });
    });
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawerEnableOpenDragGesture: false,
      endDrawer: NotificationJobDrawer(),
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        toolbarHeight: 50,
        actions: [Container()],
        flexibleSpace: Container(
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            left: 15,
            right: 15,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  child: Image.asset('assets/images/arrow_left_box_red.png'),
                ),
              ),
              InkWell(
                onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                child: Container(
                  width: 40,
                  height: 40,
                  child: Image.asset('assets/images/bell_box_red.png'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // This is the correct approach of calling unfocus on primary focus
          FocusManager.instance.primaryFocus?.unfocus();
          TextEditingController().clear();
        },
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          footer: ClassicFooter(
            loadingText: ' ',
            canLoadingText: ' ',
            idleText: ' ',
            idleIcon: Icon(Icons.arrow_upward, color: Colors.transparent),
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 15),
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('สวัสดีตอนเช้า', style: TextStyle(fontSize: 15)),
                      Text(
                        '${widget.userData.firstName} ${widget.userData.lastName}',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color:
                              widget.userData.opecCategoryId == '18' ||
                                      widget.userData.opecCategoryId == '19'
                                  ? Color(0xFF1177B6)
                                  : Color(0xFF9A1120),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  InkWell(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => PostTeacherJobForm(
                                  userData: widget.userData,
                                  profileCode: widget.profileCode,
                                  title: 'โรงเรียนหาครู',
                                ),
                          ),
                        ),
                    child: Image.asset(
                      'assets/images/add_post_teacher_job.png',
                      height: 40,
                      width: 40,
                    ),
                  ),
                ],
              ),
              Container(
                height: 200,
                child: FutureBuilder<dynamic>(
                  future: _futureNotable,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.length > 0) {
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          separatorBuilder: (_, __) => SizedBox(width: 15),
                          itemCount: snapshot.data.length,
                          itemBuilder:
                              (context, index) =>
                                  _cardJob(snapshot.data[index]),
                        );
                      } else {
                        return Container(
                          height: 500,
                          width: double.infinity,
                          // color: Colors.red,
                          child: Center(child: Text('ไม่มีข้อมูล')),
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
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ครูอัพเดตโปรไฟล์ล่าสุด',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  // InkWell(
                  //   onTap: () => Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (_) => JobListPage(filter: {}),
                  //     ),
                  //   ),
                  //   child: Text(
                  //     'ดูทั้งหมด',
                  //     style: TextStyle(
                  //       fontSize: 13,
                  //       fontWeight: FontWeight.normal,
                  //       decoration: TextDecoration.underline,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                // color: Colors.red,
                height: 160,
                child: FutureBuilder<dynamic>(
                  future: _futureResume,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.length > 0) {
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          separatorBuilder: (_, __) => SizedBox(width: 10),
                          itemCount: snapshot.data.length,
                          itemBuilder:
                              (context, index) =>
                                  _cardTeacherJob(snapshot.data[index]),
                        );
                      } else {
                        return Container(
                          height: 500,
                          width: double.infinity,
                          // color: Colors.red,
                          child: Center(child: Text('ไม่มีข้อมูล')),
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
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 30),
            ],
          ),
        ),
      ),
    );
  }

  _cardJob(dynamic model) {
    return InkWell(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => TeacherJobFormBySchool(
                    model: model,
                    profileCode: widget.profileCode,
                  ),
            ),
          ),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: 250,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      model['imageUrl'],
                      height: 140,
                      width: 250,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Container(
                    width: 90,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/bg_card_job.png'),
                      ),
                    ),
                    child: Text(
                      'จนถึง ${dateStringToDateStringFormat(model['dateEnd'])}',
                      style: TextStyle(fontSize: 11, color: Color(0xFFFFFFFF)),
                    ),
                  ),
                  // Image.asset(
                  //   'assets/images/bg_card_job.png',
                  //   height: 30,
                  //   width: 90,
                  // ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text(
                    model['title'],
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: Color(0xFF707070)),
                        ),
                        child: Text(
                          'รับ ${model['receivedAmount']} อัตรา',
                          style: TextStyle(
                            color: Color(0xFF707070),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: Color(0xFF707070)),
                        ),
                        child: Text(
                          'จำนวนผู้สมัคร ${model['workExperience']} คน',
                          style: TextStyle(
                            color: Color(0xFF707070),
                            fontSize: 13,
                          ),
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
    );
  }

  _cardTeacherJob(dynamic model) {
    return InkWell(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileJobBySchoolPage(model: model),
            ),
          ),
      child: Container(
        height: 160,
        width: 120,
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Color(0xFFF3E4E6)),
        ),
        child: Column(
          children: [
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: Image.network(
                model['imageUrl'],
                height: 85,
                width: 85,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '${model['firstName']} ${model['lastName']}',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              margin: EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: Color(0xFFF3E4E6),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                'ประสบการณ์ ${model['workExperience']} ปี',
                style: TextStyle(
                  color: Color(0xFF9A1120),
                  fontSize: 11,
                  // fontWeight: FontWeight.normal,
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
