import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opec/pages/question_and_answer/answer_list.dart';
import 'package:opec/pages/question_and_answer/question_form.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/shared/extension.dart';
import 'package:opec/widget/blank.dart';
import 'package:opec/widget/button.dart';
import 'package:opec/widget/header.dart';
import 'package:opec/widget/image_circle.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BuildQuestionList extends StatefulWidget {
  BuildQuestionList({Key? key, this.menuModel, required this.isSchool})
    : super(key: key);

  final dynamic menuModel;
  final bool isSchool;

  @override
  BuildQuestionListState createState() => BuildQuestionListState();
}

class BuildQuestionListState extends State<BuildQuestionList> {
  List<dynamic> items = [];
  Future<dynamic> _futureModel = Future.value(null);
  int _limit = 0;
  String profileCode = '';

  final textEditingController = TextEditingController();
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    initFunc();
    super.initState();
  }

  initFunc() async {
    await getStorage();
    _onLoading();
  }

  getStorage() async {
    final storage = new FlutterSecureStorage();
    var sto = await storage.read(key: 'dataUserLoginOPEC') ?? "";
    var data = json.decode(sto);
    setState(() {
      profileCode = data['code'];
    });
  }

  _onLoading() async {
    await getStorage();
    _limit = _limit + 10;
    setState(() {
      _futureModel = post('${questionApi}read', {
        'limit': _limit,
        'skip': 0,
        'profileCode': profileCode,
      });
    });
    await Future.delayed(Duration(milliseconds: 2000));
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Note: Sensitivity is integer used when you don't want to mess up vertical drag
        if (details.delta.dx > 10) {
          // Right Swipe
          Navigator.pop(context);
        } else if (details.delta.dx < -0) {
          //Left Swipe
        }
      },
      child: Scaffold(
        backgroundColor: Color(0xFFFAFAF9),
        appBar: header(
          context,
          () => {Navigator.pop(context)},
          title: widget.menuModel['title'],
        ),
        body: new InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: screen(),
        ),
      ),
    );
  }

  Column screen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isSchool) boxMain(),
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.only(left: 15, bottom: 10.0),
          child: Text(
            widget.isSchool ? 'ประวัติคำถามของคุณ' : 'รายการคำถาม',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: futureList()),
      ],
    );
  }

  FutureBuilder futureList() {
    return FutureBuilder<dynamic>(
      future: _futureModel,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return listData(snapshot.data);
          } else {
            return Container(
              alignment: Alignment.center,
              child: Text(
                'ยังไม่มีคำถาม',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Container(
            height: 90,
            child: Center(
              child: Text(
                'ไม่พบสัญญาณอินเตอร์เน็ต กรุณาตรวจสอบสัญญาณอินเตอร์เน็ต',
              ),
            ),
          );
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 5.0),
                height: 150,
                child: BlankLoading(),
              );
            },
          );
        }
      },
    );
  }

  SmartRefresher listData(dynamic model) {
    return SmartRefresher(
      enablePullDown: false,
      enablePullUp: true,
      controller: _refreshController,
      onLoading: _onLoading,
      footer: ClassicFooter(
        loadingText: ' ',
        canLoadingText: ' ',
        idleText: ' ',
        idleIcon: Icon(Icons.arrow_upward, color: Colors.transparent),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: model.length,
        itemBuilder: (context, index) {
          return card(model[index]);
        },
      ),
    );
  }

  Container boxMain() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10.0),
          Image.asset('assets/icon96x96.png', width: 81),
          SizedBox(height: 10.0),
          Text(
            'สังคมของ สช. ยุคใหม่',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10.0),
          buttonFull(
            title: 'ตั้งคำถามใหม่',
            width: 200,
            fontSize: 15,
            elevation: 0.0,
            fontWeight: FontWeight.w500,
            backgroundColor: Theme.of(context).primaryColor,
            fontColor: Colors.white,
            callback:
                () => {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  QuestionForm(menuModel: widget.menuModel),
                        ),
                      )
                      .then(
                        (value) => {
                          _onLoading(),
                          // update isHighlight question.
                        },
                      ),
                },
          ),
          SizedBox(height: 15.0),
        ],
      ),
    );
  }

  InkWell card(dynamic model) {
    var image = model['imageUrlCreateBy'];
    var title = model['title'];
    var createBy = model['createBy'];
    var isHighlight = model['isHighlight'];
    var createDate = model['createDate'];
    var totalAnswer = '${model['totalAnswer']}';
    return InkWell(
      onTap:
          () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AnswerForm(
                      menuModel: widget.menuModel,
                      question: model,
                    ),
              ),
            ).then(
              (value) => {
                _onLoading(),
                // update isHighlight question.
              },
            ),
          },
      child: Container(
        color: isHighlight ? Color(0xFFE9F2E9) : Colors.white,
        margin: EdgeInsets.only(bottom: 5.0),
        padding: EdgeInsets.only(left: 15.0, top: 10, bottom: 6),
        child: Column(
          children: [
            Row(
              children: [
                imageCircle(context, image: image, width: 20.0, height: 20.0),
                SizedBox(width: 5.0),
                Text(
                  createBy,
                  style: TextStyle(fontFamily: 'Kanit', fontSize: 8.0),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Q:',
                  style: TextStyle(fontFamily: 'Kanit', fontSize: 40.0),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      title,
                      style: TextStyle(fontFamily: 'Kanit', fontSize: 15.0),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 46.0),
                Container(
                  padding: EdgeInsets.all(2.0),
                  width: 15.0,
                  height: 15.0,
                  decoration: BoxDecoration(
                    color: isHighlight ? Color(0xFF408C40) : Color(0xFF707070),
                    borderRadius: BorderRadius.circular(7.5),
                  ),
                  child: Image.asset('assets/logo/icons/check.png'),
                ),
                SizedBox(width: 5.0),
                Text(
                  differenceCurrentDate(createDate),
                  style: TextStyle(fontFamily: 'Kanit', fontSize: 8.0),
                ),
                SizedBox(width: 20.0),
                Text(
                  '$totalAnswer การตอบกลับ',
                  style: TextStyle(fontFamily: 'Kanit', fontSize: 8.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // .end
}
