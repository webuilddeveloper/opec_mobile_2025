import 'package:flutter/material.dart';
import 'package:opec/pages/teacher/teacher_list_vertical.dart';
import 'package:opec/shared/api_provider.dart' as service;
import 'package:opec/widget/header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TeacherList extends StatefulWidget {
  TeacherList({Key? key, required this.keySearch}) : super(key: key);

  final String keySearch;

  @override
  _TeacherList createState() => _TeacherList(name: this.keySearch);
}

class _TeacherList extends State<TeacherList> {
  _TeacherList({required this.name});

  late String name;
  late TeacherListVertical teacher;
  late bool hideSearch = true;
  final txtDescription = TextEditingController();
  String keySearch = '';
  String firstName = '';
  String lastName = '';
  late int _limit = 10;

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  // final ScrollController _controller = ScrollController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  @override
  void initState() {
    txtDescription.text = name;
    checkName(name);
    super.initState();

    teacher = new TeacherListVertical(
      model: service.post('${service.teacherApi}read', {
        'firstName': firstName,
        'lastName': lastName,
      }),
    );
  }

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;

      teacher = new TeacherListVertical(
        model: service.post('${service.teacherApi}read', {
          "firstName": keySearch,
          'lastName': '',
        }),
      );
    });

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  void goBack() async {
    Navigator.pop(context, false);
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
        backgroundColor: Color(0xFFf2f1f3),
        appBar: header(context, goBack, title: 'ตรวจสอบข้อมูลครู'),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            return false;
          },
          child: new InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              children: [
                // SizedBox(height: 5),
                // KeySearch(
                //   initialValue: txtDescription.text,
                //   show: hideSearch,
                //   onKeySearchChange: (String val) {
                //     checkName(val);
                //   },
                // ),
                SizedBox(height: 10),
                Expanded(
                  child: SmartRefresher(
                    enablePullDown: false,
                    enablePullUp: true,
                    footer: ClassicFooter(
                      loadingText: ' ',
                      canLoadingText: ' ',
                      idleText: ' ',
                      idleIcon: Icon(
                        Icons.arrow_upward,
                        color: Colors.transparent,
                      ),
                    ),
                    controller: _refreshController,
                    onLoading: _onLoading,
                    child: ListView(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      children: [teacher],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  checkName(String value) {
    if (value != '') {
      var arr = value.split(' ');
      if (arr.length == 1) {
        firstName = arr[0];
      } else {
        firstName = arr[0];
        lastName = arr[1];
      }
    }

    setState(() {
      keySearch = value;
      teacher = new TeacherListVertical(
        model: service.post('${service.teacherApi}read', {
          "firstName": firstName,
          'lastName': lastName,
        }),
      );
    });
  }
}
