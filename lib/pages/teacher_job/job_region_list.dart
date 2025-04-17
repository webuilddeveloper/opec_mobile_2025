import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opec/pages/teacher_job/notification_job.dart';
import 'package:opec/pages/teacher_job/teacher_job_form.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/shared/extension.dart';
import 'package:opec/widget/loading.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class JobRegionListPage extends StatefulWidget {
  const JobRegionListPage({Key? key, required this.image, required this.region}) : super(key: key);

  final String image;
  final String region;

  @override
  State<JobRegionListPage> createState() => _JobRegionListPageState();
}

class _JobRegionListPageState extends State<JobRegionListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final storage = FlutterSecureStorage();
  Future<dynamic> _future = Future.value(null);
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late TextEditingController _searchTextEditingController;
  dynamic profile = {
    'firstName': '',
    'lastName': '',
  };
  int _limit = 10;

  void initState() {
    _searchTextEditingController = TextEditingController();
    super.initState();
    _setFuture();
    _callResumeData();
  }

  _callResumeData() async {
    var value = await storage.read(key: 'resumeData') ?? "";
    var result = json.decode(value);

    setState(() {
      profile = result;
    });
  }

  _setFuture() {
    setState(() {
      _future = postDio('${server}m/teacherjob/read', {
        'skip': 0,
        'limit': _limit,
        'region': widget.region,
        'keySearch': _searchTextEditingController.text,
      });
    });
  }

  _onLoading() {
    setState(() {
      _limit += 10;
    });
    _setFuture();

    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
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
                      child:
                          Image.asset('assets/images/arrow_left_box_red.png'),
                    )),
                GestureDetector(
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
        body: SmartRefresher(
          enablePullDown: false,
          enablePullUp: true,
          footer: ClassicFooter(
            loadingText: ' ',
            canLoadingText: ' ',
            idleText: ' ',
            idleIcon: Icon(Icons.arrow_upward, color: Colors.transparent),
          ),
          controller: _refreshController,
          onLoading: _onLoading,
          child: ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 15),
            children: [
              SizedBox(height: 20),
              Text(
                'สวัสดีตอนเช้า',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              Text(
                '${profile['firstName']} ${profile['lastName']}',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(
                    0xFF9A1120,
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: _searchTextEditingController,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () {
                        _searchTextEditingController.clear();
                      },
                      icon: Icon(Icons.clear),
                    ),
                    prefixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _limit = 10;
                        });
                        _setFuture();
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        width: 35,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xFFEEBA33),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Image.asset(
                          'assets/images/search.png',
                          color: Colors.white,
                          height: 18,
                        ),
                      ),
                    ),
                    contentPadding: EdgeInsets.only(left: 10),
                    labelText: "ค้นหาสถานที่",
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF707070).withOpacity(0.7),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Color(0xFFEEBA33),
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Color(0xFFEEBA33).withOpacity(0.5),
                        width: 1.0,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {}
                  },
                ),
              ),
              SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  widget.image,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'งานทั้งหมด',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Image.asset(
                  //   'assets/images/sort_box_red.png',
                  //   height: 35,
                  //   width: 35,
                  // ),
                ],
              ),
              SizedBox(height: 20),
              FutureBuilder<dynamic>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.separated(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          separatorBuilder: (_, __) => SizedBox(height: 10),
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) =>
                              _card(snapshot.data[index]));
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return CircularProgressIndicator.adaptive();
                    } else {
                      return Container();
                    }
                  }),
              SizedBox(height: 10),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 30),
            ],
          ),
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
}
