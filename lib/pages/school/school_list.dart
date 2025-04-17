import 'package:flutter/material.dart';
import 'package:opec/pages/school/school_list_vertical.dart';
import 'package:opec/shared/api_provider.dart' as service;
import 'package:opec/widget/header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SchoolList extends StatefulWidget {
  SchoolList({Key? key, required this.keySearch, required this.province}) : super(key: key);

  final String keySearch;
  final String province;

  @override
  _SchoolList createState() => _SchoolList(name: this.keySearch);
}

class _SchoolList extends State<SchoolList> {
  _SchoolList({required this.name});

  late String name;
  late SchoolListVertical school;
  late bool hideSearch = true;
  final txtDescription = TextEditingController();
  late String keySearch;
  late String firstName;
  late String lastName;
  late int _limit = 10;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

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
    // checkName(name);
    super.initState();

    school = new SchoolListVertical(
      model: service.postDio('${service.schoolApi}read',
          {'schoolName': name, 'provinceCode': widget.province}),
    );
  }

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;

      school = new SchoolListVertical(
        model: service.postDio('${service.schoolApi}read',
            {'schoolName': name, 'provinceCode': widget.province}),
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
        appBar: header(context, goBack, title: 'ตรวจสอบข้อมูลโรงเรียน'),
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
                      children: [
                        school,
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // checkName(String value) {
  //   setState(
  //     () => {
  //       keySearch = value,
  //       school = new SchoolListVertical(
  //         model: service.post('${service.schoolApi}read',
  //             {"schoolName": keySearch, 'provinceCode': widget.province}),
  //       )
  //     },
  //   );
  // }
}
