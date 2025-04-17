import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opec/pages/teacher_job/job_list.dart';
import 'package:opec/pages/teacher_job/job_region_list.dart';
import 'package:opec/pages/teacher_job/notification_job.dart';
import 'package:opec/pages/teacher_job/profile_job.dart';
import 'package:opec/pages/teacher_job/search_list_job_teacher.dart';
import 'package:opec/pages/teacher_job/teacher_job_form.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/shared/extension.dart';
import 'package:opec/widget/loading.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TeacherJobPage extends StatefulWidget {
  const TeacherJobPage({Key? key, this.model}) : super(key: key);

  final dynamic model;

  @override
  State<TeacherJobPage> createState() => _TeacherJobPageState();
}

class _TeacherJobPageState extends State<TeacherJobPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final storage = FlutterSecureStorage();
  Future<dynamic> _futureNotable = Future.value(null);
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  dynamic profile = {'firstName': '', 'lastName': ''};
  dynamic _countData = {'job': '0', 'fullTime': '0', 'bookmark': '0'};
  String jobType = '';
  String profileCode = '';

  // List<AutocompletePrediction> _predictions = [];
  final TextEditingController _searchTextEditingController =
      TextEditingController();

  void initState() {
    _callRead();
    _callReadCount();
    super.initState();
  }

  _callReadCount() async {
    var profileCodeS = await storage.read(key: 'profileCode25') ?? "";
    var result = await postDio('${server}m/teacherjob/resume/count', {
      'profileCode': profileCodeS,
      'jobType': jobType,
    });

    setState(() {
      _countData = result;
      profileCode = profileCodeS;
    });
  }

  void dispose() {
    super.dispose();
  }

  _callRead() async {
    _futureNotable = postDio('${server}m/teacherjob/read', {
      'skip': 0,
      'limit': 2,
      'isFeaturedWork': true,
      'profileCode': '',
    });

    setState(() {
      profile = widget.model;
      jobType =
          profile['isFullTime'] == true && profile['isPartTime'] == false
              ? '0'
              : profile['isFullTime'] == false && profile['isPartTime'] == true
              ? '1'
              : '';
    });
  }

  _onRefresh() {
    _callReadCount();
    setState(() {
      _futureNotable = postDio('${server}m/teacherjob/read', {
        'skip': 0,
        'limit': 2,
        'profileCode': '',
      });
    });
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      endDrawer: NotificationJobDrawer(),
      endDrawerEnableOpenDragGesture: false,
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [Container()],
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
              Row(
                children: [
                  GestureDetector(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ProfileJobPage(title: 'แก้ไขข้อมูล'),
                          ),
                        ),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        IconData(0xe3c6, fontFamily: 'MaterialIcons'),
                        color: Color(0xFF9A1120),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
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
              Text('สวัสดีตอนเช้า', style: TextStyle(fontSize: 15)),
              Text(
                '${profile['firstName']} ${profile['lastName']}',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9A1120),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextFormField(
                        controller: _searchTextEditingController,
                        autofocus: false,
                        enableInteractiveSelection: false,
                        onFieldSubmitted: (String value) {
                          print('You just typed a new entry  $value');
                        },
                        onChanged: (value) {
                          // print(_predictions.length);
                          // if (value.isEmpty) {
                          //   setState(() {
                          //     _predictions = [];
                          //   });
                          // }
                        },
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () {
                              _searchTextEditingController.clear();
                            },
                            icon: Icon(Icons.clear),
                          ),
                          prefixIcon: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => JobListPage(
                                        filter: {
                                          'keySearch':
                                              _searchTextEditingController.text,
                                          profileCode: '',
                                        },
                                        profileCode: '',
                                      ),
                                ),
                              );
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
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchListJobTeacherPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFEFBA33)),
                      ),
                      child: Icon(
                        IconData(0xf755, fontFamily: 'MaterialIcons'),
                        color: Color(0xFFEFBA33),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 27),
              Text(
                'งานแนะนำ',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => JobListPage(
                                    filter: {'jobType': jobType},
                                    profileCode: '',
                                  ),
                            ),
                          ),
                      child: Container(
                        height: 170,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/images/teacher_job_image_1.png',
                            ),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${_countData['job']}',
                              style: TextStyle(
                                fontSize: 79,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 0.8,
                              ),
                            ),
                            Text(
                              'งานที่เราแนะนำ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: SizedBox(
                      height: 170,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => JobListPage(
                                            filter: {'jobType': '0'},
                                            profileCode: '',
                                          ),
                                    ),
                                  ),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      'assets/images/bg_yellow.png',
                                    ),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/school_box.png',
                                      height: 50,
                                      width: 50,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${_countData['fullTime']}',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            'งานประจำ',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white.withOpacity(
                                                0.5,
                                              ),
                                              height: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          Expanded(
                            child: GestureDetector(
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => JobListPage(
                                            filter: {'isBookmark': true},
                                            profileCode: profileCode,
                                          ),
                                    ),
                                  ),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      'assets/images/bg_pink.png',
                                    ),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/bookmark_box_red.png',
                                      height: 50,
                                      width: 50,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${_countData['bookmark']}',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            'งานที่บันทึกไว้',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white.withOpacity(
                                                0.5,
                                              ),
                                              height: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'งานเด่น',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => JobListPage(filter: {}, profileCode: ''),
                          ),
                        ),
                    child: Text(
                      'งานทั้งหมด',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
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
                future: _futureNotable,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.separated(
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder:
                          ((context, index) => _card(snapshot.data[index])),
                      separatorBuilder: (_, __) => SizedBox(height: 10),
                      itemCount: snapshot.data.length,
                    );
                  } else {
                    return Container(
                      height: 304,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        color: Color(0xFFEEBA33),
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 17),
              Text(
                'งานตามภูมิภาค',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 140,
                child: ListView(
                  physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _cardRegion(
                      'assets/images/region_1.png',
                      'ภาคกลาง',
                      'center',
                    ),
                    SizedBox(width: 10),
                    _cardRegion(
                      'assets/images/region_2.png',
                      'ภาคเหนือ',
                      'north',
                    ),
                    SizedBox(width: 10),
                    _cardRegion(
                      'assets/images/region_3.png',
                      'ภาคอีสาน',
                      'eastern',
                    ),
                    SizedBox(width: 10),
                    _cardRegion(
                      'assets/images/region_4.png',
                      'ภาคใต้',
                      'south',
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(dynamic model) {
    return GestureDetector(
      onTap:
          () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TeacherJobForm(model: model)),
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
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFF707070)),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFF707070)),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          checkSalary(model['salaryStart'], model['salaryEnd']),
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF707070),
                          ),
                        ),
                      ),
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
                child: Image.asset('assets/images/bookmark_box_pink.png'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _cardRegion(String image, String title, String value) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JobRegionListPage(image: image, region: value),
            ),
          ),
      child: Container(
        height: 135,
        width: 100,
        child: Column(
          children: [
            Image.asset(image),
            Container(
              height: 55,
              width: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color(0xFFF7F7F7),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Text(
                title,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
