import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:opec/pages/event_calendar/event_calendar_form.dart';
import 'package:opec/pages/knowledge/knowledge_form.dart';
import 'package:opec/pages/news/news_form.dart';
import 'package:opec/pages/notification/main_page_form.dart';
import 'package:opec/pages/notification/notification_expireform.dart';
import 'package:opec/pages/poi/poi_form.dart';
import 'package:opec/pages/poll/poll_form.dart';
import 'package:opec/pages/privilege/privilege_form.dart';
import 'package:opec/pages/welfare/welfare_form.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opec/shared/extension.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/widget/header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NotificationList extends StatefulWidget {
  NotificationList({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _NotificationList createState() => _NotificationList();
}

class _NotificationList extends State<NotificationList>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  Future<dynamic> _futureModel = Future.value(null);
  Future<dynamic> _futureProfile = Future.value(null);
  Future<dynamic> _futureNoti = Future.value(null);
  final storage = FlutterSecureStorage();
  final _controller = ScrollController();

  var loadingAction = false;
  int notiCount = 0;
  dynamic profileCode;
  List<dynamic> listData = [];
  List<dynamic> listResultData = [];
  int totalSelected = 0;
  bool isNoActive = false;
  int totalStatusActive = 0;
  bool chkListCount = false;
  bool chkListActive = false;

  bool isCheckSelect = false;
  bool isLoading = false;

  List<dynamic> listCategoryDays = [
    {'code': '1', 'title': 'วันนี้'},
    {'code': '2', 'title': 'เมื่อวาน'},
    {'code': '3', 'title': '7 วันก่อน'},
    {'code': '4', 'title': 'เก่ากว่า 7 วัน'},
    {'code': '5', 'title': 'ยังไม่อ่าน'},
  ];

  var selectedCategoryDays = "";
  var selectedCategoryDaysName = "";
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  @override
  void initState() {
    _loading();
    super.initState();
    WidgetsBinding.instance.removeObserver(this);
  }

  _readNoti() async {
    profileCode = await storage.read(key: 'profileCode25');
    if (profileCode != '' && profileCode != null) {
      setState(() {
        _futureProfile = postDio(profileReadApi, {"code": profileCode});
      });
    }
    var _profile = await _futureProfile;
    if (_profile != null) {
      dynamic _username = _profile["username"];
      dynamic _category = _profile["category"];
      _futureNoti = postDio('${notificationApi}count', {
        "username": _username,
        "category": _category,
      });
      var _norti = await _futureNoti;
      setState(() {
        notiCount = _norti['total'];
      });
    }
  }

  _loading() async {
    _readNoti();
    // var profileCode = await storage.read(key: 'profileCode8');
    // if (profileCode != '' && profileCode != null) {
    selectedCategoryDays = "";
    setState(() {
      _futureModel = postDio('${notificationApi}read', {
        'skip': 0,
        'limit': 999,
        // 'profileCode': profileCode,
      });
    });

    var listModel = await _futureModel;
    setState(() {
      listData = [];
      listResultData = [];
      if (listModel.length > 0) {
        for (var i = 0; i < listModel.length; i++) {
          var categoryDays =
              listModel[i]['totalDays'] == 0
                  ? "1"
                  : listModel[i]['totalDays'] == 1
                  ? "2"
                  : listModel[i]['totalDays'] <= 7 &&
                      listModel[i]['totalDays'] > 0
                  ? "3"
                  : listModel[i]['totalDays'] > 7
                  ? "4"
                  : "";
          listModel[i]['categoryDays'] = categoryDays;
          listModel[i]['isSelected'] = false;
          listData.add(listModel[i]);
        }
        // if (listData.length < aa.length)
        // listData = [...listData1, ...listData2, ...listData3, ...listData4];
        // listData = aa;
      }
      listResultData = listData;
      chkListCount = listResultData.length > 0 ? true : false;
      chkListActive =
          listData.where((x) => x['status'] != "A").toList().length > 0
              ? true
              : false;
      totalSelected = 0;
    });
    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  checkNavigationPage(String page, dynamic model) {
    switch (page) {
      case 'newsPage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => NewsForm(
                    // url: '${newsApi}read',
                    code: model['reference'],
                    model: model,
                    // urlComment: newsCommentApi,
                    // urlGallery: newsGalleryApi,
                  ),
            ),
          ).then((value) => {_loading()});
        }
        break;

      case 'eventPage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => EventCalendarForm(
                    // url: '${eventCalendarApi}read',
                    code: model['reference'],
                    model: model,
                    // urlComment: eventCalendarCommentApi,
                    // urlGallery: eventCalendarGalleryApi,
                  ),
            ),
          ).then((value) => {_loading()});
        }
        break;

      case 'privilegePage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      PrivilegeForm(code: model['reference'], model: model),
            ),
          ).then((value) => {_loading()});
        }
        break;

      case 'knowledgePage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      KnowledgeForm(code: model['reference'], model: model),
            ),
          ).then((value) => {_loading()});
        }
        break;

      case 'poiPage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => PoiForm(
                    url: '${poiApi}read',
                    code: model['reference'],
                    model: model,
                    urlComment: poiCommentApi,
                    urlGallery: poiGalleryApi,
                  ),
            ),
          ).then((value) => {_loading()});
        }
        break;

      case 'pollPage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => PollForm(code: model['reference'], model: model, titleHome: '',),
            ),
          ).then((value) => {_loading()});
        }
        break;

      // case 'warningPage':
      //   {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => WarningForm(
      //           code: model['reference'],
      //           model: model,
      //         ),
      //       ),
      //     ).then((value) => {_loading()});
      //   }
      //   break;

      case 'welfarePage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      WelfareForm(code: model['reference'], model: model),
            ),
          ).then((value) => {_loading()});
        }
        break;

      case 'mainPage':
        {
          return Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      MainPageForm(code: model['reference'], model: model),
            ),
          ).then((value) => {_loading()});
        }
      case 'notiPage':
        {
          return Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      MainPageForm(code: model['reference'], model: model),
            ),
          ).then((value) => {_loading()});
        }

      case 'examPage':
        {
          return Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => NotificationExpireForm(
                    model: model,
                  ),
            ),
          ).then((value) => {_loading()});
        }
      default:
        {
          return toastFail(context, text: 'เกิดข้อผิดพลาด');
        }
    }
  }

  void goBack() async {
    Navigator.pop(context);
    _loading();
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
        appBar: headerV2Notification(
          context,
          () => goBack(),
          title: widget.title,
          isButtonRight: true,
          rightButton: () => _handleClickMe(),
          menu: 'notification',
          notiCount: notiCount,
        ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            return false;
          },
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              children: [
                SizedBox(height: 10),
                Expanded(
                  child: SmartRefresher(
                    enablePullDown: false,
                    enablePullUp: false,
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
                    onLoading: _loading,
                    child: Stack(
                      children: <Widget>[
                        selectedCategoryDays == ""
                            ? Container(
                              child: FadingEdgeScrollView.fromScrollView(
                                child: ListView(
                                  // shrinkWrap: true,
                                  controller: _controller,
                                  physics: ClampingScrollPhysics(), // 2nd
                                  children: <Widget>[
                                    for (
                                      int i = 0;
                                      i < listCategoryDays.length;
                                      i++
                                    )
                                      _builCategory(listCategoryDays[i]),
                                  ],
                                ),
                              ),
                            )
                            : listResultData.length > 0
                            ? Container(
                              child: FadingEdgeScrollView.fromScrollView(
                                child: ListView(
                                  controller: _controller,
                                  // shrinkWrap: true,
                                  physics: ClampingScrollPhysics(), // 2nd
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(left: 30),
                                      child: Text(
                                        '$selectedCategoryDaysName',
                                        style: TextStyle(
                                          color: Color(0xFFEEBA33),
                                          fontFamily: 'Kanit',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                      ),
                                    ),
                                    for (
                                      int i = 0;
                                      i < listResultData.length;
                                      i++
                                    )
                                      Container(
                                        child: cardV2(
                                          context,
                                          listResultData[i],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )
                            : Container(
                              height: MediaQuery.of(context).size.height,
                              width: (MediaQuery.of(context).size.width),
                              margin: EdgeInsets.symmetric(horizontal: 40),
                              child: Center(
                                child: Text(
                                  textNotiEmpty(selectedCategoryDays),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF707070).withOpacity(0.5),
                                    fontFamily: 'Kanit',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                        isCheckSelect
                            ? Positioned(
                              top: -10.0,
                              right: 0.0,
                              child: Padding(
                                padding: EdgeInsets.zero,
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: Color(0xFFEEBA33),
                                      size: 40,
                                    ),
                                    onPressed: () {
                                      _clearSelected();
                                    },
                                  ),
                                ),
                              ),
                            )
                            : Container(),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.white.withOpacity(0.0),
                  height: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: (MediaQuery.of(context).size.width / 100) * 40,
                        margin: EdgeInsets.only(bottom: 22.0),
                        child:
                            chkListActive
                                ? Material(
                                  elevation: 5.0,
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xFFEEBA33),
                                  child: MaterialButton(
                                    height: 30,
                                    onPressed: () {
                                      _DialogUpdate();
                                    },
                                    child: Text(
                                      totalSelected > 0
                                          ? 'อ่านแล้ว  (${totalSelected.toString()})'
                                          : 'อ่านทั้งหมด',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Kanit',
                                      ),
                                    ),
                                  ),
                                )
                                : ElevatedButton(
                                  style: ButtonStyle(
                                    padding:
                                        MaterialStateProperty.all<EdgeInsets>(
                                          EdgeInsets.all(10),
                                        ),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                          Colors.white,
                                        ),
                                    shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder
                                    >(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          10.0,
                                        ),
                                        side: BorderSide(
                                          color: Color(0xFFB7B7B7),
                                        ),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: Text(
                                    'อ่านทั้งหมด',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Color(0xFFB7B7B7),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Kanit',
                                    ),
                                  ),
                                ),
                      ),
                      SizedBox(width: 20),
                      Container(
                        width: (MediaQuery.of(context).size.width / 100) * 40,
                        margin: EdgeInsets.only(bottom: 22.0),
                        child:
                            chkListCount
                                ? Material(
                                  elevation: 5.0,
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xFFEEBA33),
                                  child: MaterialButton(
                                    height: 30,
                                    onPressed: () async {
                                      _DialogDelete();
                                    },
                                    child: Text(
                                      totalSelected > 0
                                          ? 'ลบรายการ  (${totalSelected.toString()})'
                                          : 'ลบทั้งหมด',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Kanit',
                                      ),
                                    ),
                                  ),
                                )
                                : ElevatedButton(
                                  style: ButtonStyle(
                                    padding:
                                        MaterialStateProperty.all<EdgeInsets>(
                                          EdgeInsets.all(10),
                                        ),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                          Colors.white,
                                        ),
                                    shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder
                                    >(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          10.0,
                                        ),
                                        side: BorderSide(
                                          color: Color(0xFFB7B7B7),
                                        ),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: Text(
                                    'ลบทั้งหมด',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Color(0xFFB7B7B7),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Kanit',
                                    ),
                                  ),
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
    );
  }

  _builCategory(dynamic model) {
    if (isNoActive) {
      listResultData =
          listData
              .where(
                (x) => x['categoryDays'] == model['code'] && x['status'] != "A",
              )
              .toList();
    } else {
      listResultData =
          listData.where((x) => x['categoryDays'] == model['code']).toList();
    }

    return listResultData.length > 0
        ? Container(
          // margin: EdgeInsets.only(top: height * 1.5 / 100, left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 30),
                child: Text(
                  '${model['title']}',
                  style: TextStyle(
                    color: Color(0xFFEEBA33),
                    fontFamily: 'Kanit',
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              for (int i = 0; i < listResultData.length; i++)
                cardV2(context, listResultData[i]),
              SizedBox(height: 34),
            ],
          ),
        )
        : Container();
  }

  void _holdClick(dynamic model) {
    setState(() {
      // isCheckSelect = !isCheckSelect;
      if (!isCheckSelect) {
        isCheckSelect = true;
        for (int j = 0; j < listData.length; j++) {
          if (listData[j]['code'] == model['code']) {
            listData[j]['isSelected'] = !listData[j]['isSelected'];
          }
        }
      } else {
        for (int j = 0; j < listData.length; j++) {
          if (listData[j]['code'] == model['code']) {
            listData[j]['isSelected'] = !listData[j]['isSelected'];
          }
        }
      }
      totalSelected =
          listData.where((i) => i['isSelected'] == true).toList().length;
    });
  }

  void _clearSelected() {
    setState(() {
      isCheckSelect = false;
      for (int j = 0; j < listData.length; j++) {
        listData[j]['isSelected'] = false;
      }

      totalSelected =
          listData.where((i) => i['isSelected'] == true).toList().length;
    });
  }

  void _singleClick(dynamic model) {
    setState(() {
      for (int j = 0; j < listData.length; j++) {
        if (listData[j]['code'] == model['code']) {
          listData[j]['isSelected'] = !listData[j]['isSelected'];
        }
      }

      totalSelected =
          listData.where((i) => i['isSelected'] == true).toList().length;
    });
  }

  Widget cardV2(BuildContext context, dynamic model) {
    // print('aek $model');
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return InkWell(
      onLongPress: () {
        _holdClick(model);
      },
      onTap: () async {
        if (isCheckSelect) {
          _singleClick(model);
        } else {
          postDio('${notificationApi}update', {
            'category': '${model['category']}',
            "code": '${model['code']}',
          });
          checkNavigationPage(model['category'], model);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        height: (height * 15) / 100,
        // width:isCheckSelect ? (width*20)/100,
        decoration: BoxDecoration(
          color:
              model['status'] == 'A'
                  ? Color(0xFFB7B7B7).withOpacity(0.1)
                  : Color(0xFFEEBA33).withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height * 1 / 100),
                color:
                    model['status'] == 'A'
                        ? Color(0xFFB7B7B7).withOpacity(0.1)
                        : Colors.red,
              ),
              height: height * 1.5 / 100,
              width: height * 1.5 / 100,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // color: Colors.red,
                  width: (width / 100) * 55,
                  padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Text(
                    // '${model['title']}',
                    checkCategoryName(model['category'], model),
                    style: TextStyle(
                      color: Color(0xFF707070),
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                Container(
                  // color: Colors.red,
                  width: (width / 100) * 55,
                  // margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Text(
                    '${model['title']}',
                    style: TextStyle(
                      color: Color(0xFF707070),
                      fontFamily: 'Arial',
                      fontWeight: FontWeight.normal,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child: Text(
                    model['categoryDays'] == "1"
                        ? '${timeString(model['docTime'])} น.'
                        : '${dateStringToDateStringFormatV2(model['createDate'])}',
                    style: TextStyle(
                      color: Color(0xFFB7B7B7),
                      fontFamily: 'Arial',
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                model['isSelected']
                    ? Container(
                      height: (height * 12) / 100,
                      width: (height * 12) / 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Color(0xFFEEBA33),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Image.asset(
                          'assets/logo/icons/check.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                    : model['imageUrl'] != "" && model['imageUrl'] != null
                    ? Container(
                      height: (height * 12) / 100,
                      width: (height * 12) / 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          // image: AssetImage(
                          //   'assets/images/bot_menu3.png',
                          // ),
                          image: NetworkImage(model['imageUrl']),
                        ),
                      ),
                    )
                    : Container(
                      height: (height * 12) / 100,
                      width: (height * 12) / 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage('assets/icon.png'),
                        ),
                      ),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleClickMe() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          titlePadding: EdgeInsets.all(0),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close, color: Color(0xFFEEBA33), size: 35),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Center(
                child: Text(
                  'เลือกแสดงผล',
                  style: TextStyle(
                    color: Color(0xFFEEBA33),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            SizedBox(height: 15),
            Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedCategoryDays = "";
                    isNoActive = false;
                    unSelectall();
                    chkListCount = listData.length > 0 ? true : false;
                    chkListActive =
                        listData
                                    .where((x) => x['status'] != "A")
                                    .toList()
                                    .length >
                                0
                            ? true
                            : false;

                    Navigator.pop(context);

                    // listResultData = listData;
                  });
                },
                child: Container(
                  child: Text(
                    'ทั้งหมด',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF707070),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1.5, color: Colors.grey[400] ?? Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    unSelectall();

                    selectedCategoryDays = "5";
                    selectedCategoryDaysName = "ยังไม่อ่าน";
                    isNoActive = true;
                    listResultData =
                        listData.where((x) => x['status'] != "A").toList();
                    chkListCount = listResultData.length > 0 ? true : false;
                    chkListActive = listResultData.length > 0 ? true : false;
                    Navigator.pop(context);
                  });
                },
                child: Container(
                  child: Text(
                    'ยังไม่อ่าน',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF707070),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1.5, color: Colors.grey[400] ?? Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    unSelectall();

                    selectedCategoryDays = "1";
                    selectedCategoryDaysName = "วันนี้";
                    listResultData =
                        listData
                            .where(
                              (i) => i['categoryDays'] == selectedCategoryDays,
                            )
                            .toList();
                    chkListCount = listResultData.length > 0 ? true : false;
                    chkListActive =
                        listResultData
                                    .where((x) => x['status'] != "A")
                                    .toList()
                                    .length >
                                0
                            ? true
                            : false;

                    Navigator.pop(context);
                  });
                },
                child: Container(
                  child: Text(
                    'วันนี้',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF707070),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1.5, color: Colors.grey[400] ?? Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    unSelectall();
                    selectedCategoryDays = "2";
                    selectedCategoryDaysName = "เมื่อวาน";
                    listResultData =
                        listData
                            .where(
                              (i) => i['categoryDays'] == selectedCategoryDays,
                            )
                            .toList();
                    chkListCount = listResultData.length > 0 ? true : false;
                    chkListActive =
                        listResultData
                                    .where((x) => x['status'] != "A")
                                    .toList()
                                    .length >
                                0
                            ? true
                            : false;

                    Navigator.pop(context);
                  });
                },
                child: Container(
                  child: Text(
                    'เมื่อวาน',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF707070),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1.5, color: Colors.grey[400] ?? Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    unSelectall();

                    selectedCategoryDays = "3";
                    selectedCategoryDaysName = "7 วันก่อน";
                    listResultData =
                        listData
                            .where(
                              (i) => i['categoryDays'] == selectedCategoryDays,
                            )
                            .toList();
                    chkListCount = listResultData.length > 0 ? true : false;
                    chkListActive =
                        listResultData
                                    .where((x) => x['status'] != "A")
                                    .toList()
                                    .length >
                                0
                            ? true
                            : false;
                    Navigator.pop(context);
                  });
                },
                child: Container(
                  child: Text(
                    '7 วันก่อน',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF707070),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1.5, color: Colors.grey[400] ?? Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    unSelectall();

                    selectedCategoryDays = "4";
                    selectedCategoryDaysName = "เก่ากว่า 7 วัน";
                    listResultData =
                        listData
                            .where(
                              (i) => i['categoryDays'] == selectedCategoryDays,
                            )
                            .toList();
                    chkListCount = listResultData.length > 0 ? true : false;
                    chkListActive =
                        listResultData
                                    .where((x) => x['status'] != "A")
                                    .toList()
                                    .length >
                                0
                            ? true
                            : false;
                    Navigator.pop(context);
                  });
                },
                child: Container(
                  child: Text(
                    'เก่ากว่า 7 วัน',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF707070),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget animationsList() {
    return Expanded(
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Colors.transparent, Colors.red],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstATop,

        child: Container(height: 200.0, width: 200.0, color: Colors.blue),
        // blendMode: BlendMode.dstATop,
      ),
    );
  }

  _DialogUpdate() {
    return showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            backgroundColor: Colors.white,
            titlePadding: EdgeInsets.all(0),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Color(0xFFEEBA33), size: 35),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        totalSelected > 0
                            ? 'เปลี่ยน $totalSelected รายการที่เลือก เป็นอ่านแล้วใช่หรือไม่'
                            : textDialogUpdate(selectedCategoryDays),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFEEBA33),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: (MediaQuery.of(context).size.width / 100) * 30,
                    margin: EdgeInsets.symmetric(vertical: 20.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.all(10),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.white,
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(color: Color(0xFFB7B7B7)),
                              ),
                            ),
                      ),
                      child: Text(
                        "ยกเลิก",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Kanit',
                          color: Color(0xFFB7B7B7),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: (MediaQuery.of(context).size.width / 100) * 30,
                    margin: EdgeInsets.symmetric(vertical: 20.0),
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xFFEEBA33),
                      child: MaterialButton(
                        height: 30,
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                            Navigator.pop(context);
                          });
                          if (totalSelected > 0) {
                            var listSelected =
                                listData
                                    .where((i) => i['isSelected'] == true)
                                    .toList();

                            var listCode = "";
                            for (var i = 0; i < totalSelected; i++) {
                              if (listCode == '') {
                                listCode = listSelected[i]['code'];
                              } else {
                                listCode =
                                    '$listCode,' + listSelected[i]['code'];
                              }
                            }
                            await postDio('${notificationApi}updateSelect', {
                              "code": listCode,
                            });
                            setState(() {
                              isCheckSelect = false;
                            });
                          } else if (selectedCategoryDays != "") {
                            var listCode = "";
                            for (var i = 0; i < listResultData.length; i++) {
                              if (listCode == '') {
                                listCode = listResultData[i]['code'];
                              } else {
                                listCode =
                                    '$listCode,' + listResultData[i]['code'];
                              }
                            }
                            await postDio('${notificationApi}updateSelect', {
                              "code": listCode,
                            });
                            setState(() {
                              isCheckSelect = false;
                            });
                          } else {
                            await postDio('${notificationApi}update', {});
                          }
                          setState(() {
                            isLoading = false;
                            _loading();
                          });
                          // Navigator.pop(context);
                        },
                        child: Text(
                          'ใช่',
                          style: TextStyle(
                            fontSize: 17.0,
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Kanit',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
    ).then((value) => _loading());
  }

  _DialogDelete() {
    return showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            backgroundColor: Colors.white,
            titlePadding: EdgeInsets.all(0),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Color(0xFFEEBA33), size: 35),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        totalSelected > 0
                            ? 'ลบ $totalSelected รายการที่เลือก ออกจากแจ้งเตือนใช่หรือไม่'
                            : textDialogDelete(selectedCategoryDays),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFEEBA33),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: (MediaQuery.of(context).size.width / 100) * 30,
                    margin: EdgeInsets.symmetric(vertical: 20.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.all(10),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.white,
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(color: Color(0xFFB7B7B7)),
                              ),
                            ),
                      ),
                      child: Text(
                        "ยกเลิก",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Kanit',
                          color: Color(0xFFB7B7B7),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: (MediaQuery.of(context).size.width / 100) * 30,
                    margin: EdgeInsets.symmetric(vertical: 20.0),
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xFFEEBA33),
                      child: MaterialButton(
                        height: 30,
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                            Navigator.pop(context);
                          });
                          if (totalSelected > 0) {
                            var listSelected =
                                listData
                                    .where((i) => i['isSelected'] == true)
                                    .toList();
                            var listCode = "";
                            for (var i = 0; i < totalSelected; i++) {
                              if (listCode == '') {
                                listCode = listSelected[i]['code'];
                              } else {
                                listCode =
                                    '$listCode,' + listSelected[i]['code'];
                              }
                            }
                            await postDio('${notificationApi}deleteSelect', {
                              "code": listCode,
                            });
                            setState(() {
                              isCheckSelect = false;
                            });
                          } else if (selectedCategoryDays != "") {
                            var listCode = "";
                            for (var i = 0; i < listResultData.length; i++) {
                              if (listCode == '') {
                                listCode = listResultData[i]['code'];
                              } else {
                                listCode =
                                    '$listCode,' + listResultData[i]['code'];
                              }
                            }
                            await postDio('${notificationApi}deleteSelect', {
                              "code": listCode,
                            });
                            setState(() {
                              isCheckSelect = false;
                            });
                          } else {
                            await postDio('${notificationApi}delete', {});
                          }
                          setState(() {
                            _loading();
                            isLoading = false;
                          });
                        },
                        child: Text(
                          'ใช่',
                          style: TextStyle(
                            fontSize: 17.0,
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Kanit',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
    ).then((value) => _loading());
  }

  unSelectall() {
    setState(() {
      for (var i = 0; i < listData.length; i++) {
        listData[i]['isSelected'] = false;
      }
      totalSelected = 0;
      isCheckSelect = false;
    });
  }

  checkCategoryName(String page, dynamic model) {
    switch (page) {
      case 'newsPage':
        {
          return "ข่าวประชาสัมพันธ์";
        }
        

      case 'eventPage':
        {
          return "ปฏิทินกิจกรรม";
        }
        

      case 'contactPage':
        {
          return "เบอร์ติดต่อเร่งด่วน";
        }
        

      case 'privilegePage':
        {
          return "สิทธิประโยชน์";
        }
        

      case 'knowledgePage':
        {
          return "สารคุรุสภา";
        }
        

      case 'poiPage':
        {
          return "จุดน่าสนใจ";
        }
        

      case 'pollPage':
        {
          return "แบบประเมิน (Poll)";
        }
        

      case 'mainPage':
        {
          return "กำหนดเอง";
        }
        

      default:
        {
          return "";
        }
        
    }
  }

  textNotiEmpty(String categoryDay) {
    switch (categoryDay) {
      case '1':
        {
          return "ท่านไม่มีข้อมูลการแจ้งเตือนสำหรับวันนี้";
        }
        

      case '2':
        {
          return "ท่านไม่มีข้อมูลการแจ้งเตือนสำหรับเมื่อวาน";
        }
        

      case '3':
        {
          return "ท่านไม่มีข้อมูลการแจ้งเตือนเมื่อ 7 วันก่อน";
        }
        

      case '4':
        {
          return "ท่านไม่มีข้อมูลการแจ้งเตือนที่เก่ากว่า 7 วัน";
        }
        
      case '5':
        {
          return "ท่านไม่มีข้อมูลการแจ้งเตือนที่ยังไม่อ่าน";
        }
        

      default:
        {
          return "";
        }
        
    }
  }
}

textDialogDelete(String categoryDay) {
  switch (categoryDay) {
    case '1':
      {
        return "ลบรายการทั้งหมดของวันนี้ออกจากการแจ้งเตือนใช่หรือไม่";
      }
      

    case '2':
      {
        return "ลบรายการทั้งหมดของเมื่อวานออกจากการแจ้งเตือนใช่หรือไม่";
      }
      

    case '3':
      {
        return "ลบรายการทั้งหมดของเมื่อ 7 วันก่อนออกจากการแจ้งเตือนใช่หรือไม่";
      }
      

    case '4':
      {
        return "ลบรายการทั้งหมดที่เก่ากว่า 7 วันก่อนออกจากการแจ้งเตือนใช่หรือไม่";
      }
      

    default:
      {
        return "ลบรายการทั้งหมด ออกจากแจ้งเตือนใช่หรือไม่";
      }
      
  }
}

textDialogUpdate(String categoryDay) {
  switch (categoryDay) {
    case '1':
      {
        return "เปลี่ยนรายการทั้งหมดของวันนี้เป็นอ่านแล้วใช่หรือไม่";
      }
      

    case '2':
      {
        return "เปลี่ยนรายการทั้งหมดของเมื่อวานเป็นอ่านแล้วใช่หรือไม่";
      }
      

    case '3':
      {
        return "เปลี่ยนรายการทั้งหมดของเมื่อ 7 วันก่อนเป็นอ่านแล้วใช่หรือไม่";
      }
      

    case '4':
      {
        return "เปลี่ยนรายการทั้งหมดที่เก่ากว่า 7 วันก่อนเป็นอ่านแล้วใช่หรือไม่";
      }
      

    default:
      {
        return "เปลี่ยนรายการทั้งหมด เป็นอ่านแล้วใช่หรือไม่";
      }
      
  }
}
