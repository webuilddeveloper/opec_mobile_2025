import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:opec/widget/dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:opec/shared/api_provider.dart';

// ignore: must_be_immutable
class PolicyPage extends StatefulWidget {
  PolicyPage({Key? key, required this.category, required this.navTo})
    : super(key: key);

  final String category;
  final Function navTo;

  @override
  _PolicyPage createState() => _PolicyPage();
}

class _PolicyPage extends State<PolicyPage> {
  late DateTime? currentBackPressTime;

  late ScrollController scrollController;

  @override
  void initState() {
    scrollController = new ScrollController();

    _read();

    super.initState();
  }

  Future<dynamic> _futureModel = Future.value(null);
  int currentCardIndex = 0;
  int policyLength = 0;
  bool lastPage = false;

  List acceptPolicyList = [];

  _read() async {
    _futureModel =
        widget.category == "AtoZ"
            ? postDio("${server}m/policy/getAtoZ", {"skip": 0, "limit": 100})
            : widget.category == "AI"
            ? postDio("${server}m/policy/getAI", {"skip": 0, "limit": 100})
            : postDio("${server}m/policy/read", {
              "skip": 0,
              "limit": 100,
              "category": widget.category,
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            return false;
          },
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (OverscrollIndicatorNotification overScroll) {
              return false;
            },
            child: Container(
              alignment: Alignment.center,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  alignment: Alignment.topCenter,
                  image: AssetImage('assets/images/background_policy.png'),
                ),
              ),
              child: _futureBuilderModel(),
            ),
          ),
        ),
        onWillPop: widget.category == 'application' ? confirmExit : null,
      ),
    );
  }

  Future<bool> confirmExit() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      toastFail(
        context,
        text: 'กดอีกครั้งเพื่อออก',
        color: Colors.black,
        fontColor: Colors.white,
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  _futureBuilderModel() {
    return FutureBuilder<dynamic>(
      future: _futureModel, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return _screen(snapshot.data);
          // _logicShowCard(snapshot.data, currentCardIndex);
        } else if (snapshot.hasError) {
          return Container();
        } else {
          return _screen([
            {'title': '', 'description': ''},
          ]);
        }
      },
    );
  }

  _screen(dynamic model) {
    policyLength = model.length;
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 50,
              left: 40,
              right: 40,
            ),
            color: Colors.transparent,
            child: Text(
              'การศึกษาเอกชน',
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'Kanit',
                color: Colors.white,
              ),
            ),
          ),
        ),
        lastPage ? _buildListCard(model) : _buildCard(model[currentCardIndex]),
      ],
    );
  }

  _buildListCard(dynamic model) {
    var height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.75,
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 40),
      padding: EdgeInsets.only(bottom: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              // color: Colors.blueAccent,
              alignment: Alignment.topCenter,
              child: ListView.builder(
                shrinkWrap: true, // 1st add
                physics: ClampingScrollPhysics(),
                itemCount: model.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  model[index]['title'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Kanit',
                                  ),
                                  // maxLines: 3,
                                ),
                              ),
                              // SizedBox(width: 10),
                              Container(
                                height: 40,
                                width: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Color(0xFFEEBA33),
                                ),
                                child: Text(
                                  '${index + 1}/$policyLength',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontFamily: 'Kanit',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: height * 0.4,
                          margin: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 20,
                          ),
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              physics: ClampingScrollPhysics(),
                              controller: scrollController,
                              child: Container(
                                alignment: Alignment.topLeft,
                                child: Html(
                                  data: model[index]['description'],
                                  onLinkTap:
                                      (url, attributes, element) =>
                                          launchUrl(Uri.parse(url ?? "")),
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildButton(
                          acceptPolicyList[index]['isActive']
                              ? 'ยอมรับ'
                              : 'ไม่ยอมรับ',
                          acceptPolicyList[index]['isActive']
                              ? Color(0xFF9A1120)
                              : Color(0xFF707070),
                          corrected: true,
                          onTap: () {},
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          _buildButton(
            'บันทึกข้อมูล',
            Color(0xFF9A1120),
            onTap: () {
              sendAcceptedPolicy();
              // dialogConfirm();
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  _buildCard(dynamic model) {
    var height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.75,
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 40),
      padding: EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    model['title'],
                    style: TextStyle(fontSize: 20, fontFamily: 'Kanit'),
                    // maxLines: 3,
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xFFEEBA33),
                  ),
                  child: Text(
                    '${currentCardIndex + 1}/$policyLength',
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'Kanit',
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              // isAlwaysShown: false,
              controller: scrollController,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Container(
                  alignment: Alignment.topLeft,
                  // child: HtmlView(
                  //   data: model['description'],
                  //   scrollable:
                  //       false, //false to use MarksownBody and true to use Marksown
                  // ),
                  child: Html(
                    data: model['description'],
                    onLinkTap:
                        (url, attributes, element) =>
                            launchUrl(Uri.parse(url ?? "")),
                  ),
                  // child: Text(parseHtmlString(model['description'])),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          _buildButton(
            'ยอมรับ',
            Color(0xFF9A1120),
            onTap: () {
              widget.category == "AtoZ"
                  ? sendAcceptedPolicyv2()
                  : widget.category == "AI"
                  ? sendAcceptedPolicyv2()
                  : nextIndex(model, true);
            },
          ),
          SizedBox(height: 15),
          _buildButton(
            'ไม่ยอมรับ',
            Color(0xFF707070),
            onTap: () {
              widget.category == "AtoZ"
                  ? Navigator.pop(context, false)
                  : widget.category == "AI"
                  ? Navigator.pop(context, false)
                  : nextIndex(model, false);
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  _buildButton(
    String title,
    Color color, {
    required Function onTap,
    bool corrected = false,
  }) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        height: 40,
        width: 285,
        alignment: Alignment.center,
        // margin: EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color,
        ),
        child: Row(
          children: [
            SizedBox(width: 40),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Kanit',
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child:
                  corrected
                      ? Image.asset(
                        'assets/images/correct.png',
                        height: 15,
                        width: 15,
                      )
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> dialogConfirm() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: AlertDialog(
            contentPadding: EdgeInsets.all(0),
            content: Container(
              width: 220,
              height: 155,
              // width: MediaQuery.of(context).size.width / 1.3,
              // height: MediaQuery.of(context).size.height / 2.5,
              decoration: new BoxDecoration(
                shape: BoxShape.rectangle,
                color: const Color(0xFFFFFF),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'สมัครสมาชิกเรียบร้อย',
                      style: TextStyle(fontSize: 20, fontFamily: 'Kanit'),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'เราจะทำการส่งเรื่องของท่าน',
                      style: TextStyle(fontSize: 13, fontFamily: 'Kanit'),
                    ),
                    Text(
                      'เพื่อทำการยืนยันต่อไป',
                      style: TextStyle(fontSize: 13, fontFamily: 'Kanit'),
                    ),
                    SizedBox(height: 15),
                    InkWell(
                      onTap: () {
                        widget.navTo();
                      },
                      child: Container(
                        height: 35,
                        width: 160,
                        alignment: Alignment.center,
                        // margin: EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFF9A1120),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'ตกลง',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'Kanit',
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // child: //Contents here
            ),
          ),
        );
      },
    );
  }

  nextIndex(dynamic model, bool accepted) {
    scrollController.jumpTo(0);
    if (currentCardIndex == policyLength - 1) {
      setState(() {
        lastPage = true;
        acceptPolicyList.add({
          'index': currentCardIndex,
          'reference': model['code'],
          'isActive': accepted,
        });
      });
    } else {
      setState(() {
        acceptPolicyList.add({
          'index': currentCardIndex,
          'reference': model['code'],
          'isActive': accepted,
        });
        currentCardIndex++;
      });
    }
  }

  sendAcceptedPolicy() async {
    acceptPolicyList.forEach((e) {
      postDio('${server}m/policy/create', e);
    });
    return dialogConfirm();
  }

  sendAcceptedPolicyv2() async {
    postDio('${server}m/policy/create', {
      "reference": widget.category,
      "isActive": true,
    });

    widget.navTo();
  }
}
