import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opec/pages/school/school_index.dart';
import 'package:opec/pages/school/school_list_vertical.dart';
import 'package:opec/pages/teacher/teacher_index.dart';
import 'package:opec/pages/teacher/teacher_list_vertical.dart';
import 'package:opec/shared/api_provider.dart' as service;
import 'package:opec/widget/header.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchListTeacherSchoolPage extends StatefulWidget {
  @override
  _SearchListTeacherSchoolPageState createState() =>
      _SearchListTeacherSchoolPageState();
}

class _SearchListTeacherSchoolPageState
    extends State<SearchListTeacherSchoolPage> {
  Future<dynamic> futureModel = Future.value(null);
  ScrollController scrollController = ScrollController();
  // RefreshController _refreshController = RefreshController(
  //   initialRefresh: false,
  // );

  String keySearch = '';
  var tempData = [];

  late TeacherListVertical teacher;
  String firstName = '';
  String lastName = '';

  late SchoolListVertical school;
  bool showSchool = true;

  @override
  void initState() {
    _callRead();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, () {
        Navigator.pop(context, false);
      }, title: 'สช. On Mobile'),
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(0),
      //   child: AppBar(
      //     backgroundColor: Theme.of(context).primaryColorDark,
      //   ),
      // ),
      backgroundColor: Colors.white,
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            //_buildHead(),
            //     Expanded(
            //   child: _buildSmartRefresher(
            //     _screen(),
            //   ),
            // ),
            SizedBox(height: 10),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        showSchool = true;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: (MediaQuery.of(context).size.width / 100) * 48,
                      height: (MediaQuery.of(context).size.height / 100) * 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0XFFEEBA33),
                      ),
                      child: Text(
                        'ตรวจสอบรายชื่อครู',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF9A1120),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        showSchool = false;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: (MediaQuery.of(context).size.width / 100) * 48,
                      height: (MediaQuery.of(context).size.height / 100) * 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0XFFEEBA33),
                      ),
                      child: Text(
                        'ตรวจสอบโรงเรียนสังกัด สช.',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF9A1120),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            showSchool
                ? Expanded(child: BuildTeacherIndex(isAppbar: true))
                : Expanded(child: BuildSchoolIndex(isAppbar: true)),
          ],
        ),
      ),
    );
  }

  // _buildHead() {
  //   return Container(
  //     color: Theme.of(context).primaryColorDark,
  //     padding: EdgeInsets.only(bottom: 10),
  //     child: Container(
  //       // height: 120,
  //       width: double.infinity,
  //       child: Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 15),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             SizedBox(height: 10),
  //             Stack(
  //               alignment: Alignment.centerLeft,
  //               children: [
  //                 InkWell(
  //                   onTap: () {
  //                     Navigator.pop(context);
  //                   },
  //                   child: Container(
  //                     child: Icon(Icons.arrow_back_ios, color: Colors.white),
  //                   ),
  //                 ),
  //                 Container(
  //                   alignment: Alignment.center,
  //                   height: 40,
  //                   child: Text(
  //                     'สช. On Mobile',
  //                     style: TextStyle(
  //                       fontFamily: 'Kanit',
  //                       fontSize: 25,
  //                       color: Colors.white,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 10),
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: Container(
  //                     height: 30,
  //                     // padding: EdgeInsets.symmetric(horizontal: 10),
  //                     decoration: BoxDecoration(
  //                       color: Colors.white,
  //                       borderRadius: BorderRadius.circular(15),
  //                     ),
  //                     child: KeySearch(
  //                       onKeySearchChange: (String val) {
  //                         setState(() {
  //                           keySearch = val;
  //                           if (val != '') {
  //                             var arr = val.split(' ');
  //                             if (arr.length == 1) {
  //                               firstName = arr[0];
  //                             } else {
  //                               firstName = arr[0];
  //                               lastName = arr[1];
  //                             }
  //                           }
  //                         });
  //                         _onLoading();
  //                       },
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // _buildSmartRefresher(Widget child) {
  //   return SmartRefresher(
  //     enablePullDown: true,
  //     enablePullUp: false,
  //     // shrinkWrap: true, // use it
  //     physics: ClampingScrollPhysics(),
  //     footer: CustomFooter(
  //       builder: (BuildContext context, LoadStatus? mode) {
  //         Widget? body;
  //         return Container(child: Center(child: body));
  //       },
  //     ),
  //     controller: _refreshController,
  //     onRefresh: _onRefresh,
  //     onLoading: _onLoading,
  //     child: child,
  //   );
  // }

  // _screen() {
  //   return ListView(
  //     physics: ClampingScrollPhysics(),
  //     children: [
  //       SizedBox(height: 10),
  //       Padding(
  //         padding: EdgeInsets.only(left: 10),
  //         child: Text(
  //           'ผลการค้นหาคุณครู ' + keySearch,
  //           style: TextStyle(
  //             fontFamily: 'Kanit',
  //             fontSize: 15,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ),
  //       SizedBox(height: 10),
  //       teacher,
  //       SizedBox(height: 10),
  //       Padding(
  //         padding: EdgeInsets.only(left: 10),
  //         child: Text(
  //           'ผลการค้นหาโรงเรียน ' + keySearch,
  //           style: TextStyle(
  //             fontFamily: 'Kanit',
  //             fontSize: 15,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ),
  //       SizedBox(height: 10),
  //       school,
  //     ],
  //   );
  // }

  // void _onRefresh() async {
  //   // getCurrentUserData();
  //   // _getLocation();
  //   _callRead();

  //   // if failed,use refreshFailed()
  //   _refreshController.refreshCompleted();
  //   // _refreshController.loadComplete();
  // }

  // void _onLoading() async {
  //   _callRead();
  //   await Future.delayed(Duration(milliseconds: 1000));
  //   _refreshController.loadComplete();
  // }

  _callRead() {
    teacher = TeacherListVertical(
      model: service.post('${service.teacherApi}read', {
        'firstName': firstName,
        'lastName': lastName,
      }),
    );

    school = SchoolListVertical(
      model: service.postDio('${service.schoolApi}read', {
        'schoolName': firstName,
        'provinceCode': '',
      }),
    );

    for (var i = 0; i < 10; i++) {
      tempData.add({'title': '', 'imageUrl': ''});
    }
  }
}
