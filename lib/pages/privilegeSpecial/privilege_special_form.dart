import 'dart:ui';
import 'package:flutter_html/flutter_html.dart';
import 'package:opec/widget/blank.dart';
import 'package:opec/widget/button.dart';
import 'package:opec/widget/gallery_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/shared/extension.dart';

class PrivilegeSpecialForm extends StatefulWidget {
  PrivilegeSpecialForm({Key? key, required this.code, this.model})
    : super(key: key);
  final String code;
  final dynamic model;

  @override
  _PrivilegeSpecialDetailPageState createState() =>
      _PrivilegeSpecialDetailPageState(code: code);
}

class _PrivilegeSpecialDetailPageState extends State<PrivilegeSpecialForm> {
  _PrivilegeSpecialDetailPageState({required this.code});

  Future<dynamic> _futureModel = Future.value(null);

  String code;

  List urlImage = [];
  List<ImageProvider> urlImageProvider = [];

  RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    _onLoading();
  }

  void _onLoading() async {
    _futureModel = postDio(privilegeSpecialReadApi, {
      'skip': 0,
      'limit': 1,
      'code': widget.code,
    });
    readGallery();
    setState(() {});

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  Future<dynamic> readGallery() async {
    final result = await postDio(privilegeGalleryApi, {'code': widget.code});

    List data = [];
    List<ImageProvider> dataPro = [];

    for (var item in result) {
      data.add(item['imageUrl']);

      if (item['imageUrl'] != null) {
        dataPro.add(NetworkImage(item['imageUrl']));
      }
    }
    setState(() {
      urlImage = data;
      urlImageProvider = dataPro;
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
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
        backgroundColor: Colors.white,
        body: FutureBuilder<dynamic>(
          future: _futureModel,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return myContent(snapshot.data[0]);
            } else {
              if (widget.model != null) {
                return myContent(widget.model);
              } else {
                return BlankLoading();
                // return myContentElse();
              }
            }
          },
        ),
      ),
    );
  }

  myContent(dynamic model) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    List image = ['${model['imageUrl']}'];
    List<ImageProvider> imagePro = [];
    if (model['imageUrl'] != null) {
      imagePro.add(NetworkImage(model['imageUrl']));
    }
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView(
        shrinkWrap: true,
        children: [
          Stack(
            children: [
              Container(
                child: ListView(
                  shrinkWrap: true, // 1st add
                  physics: ClampingScrollPhysics(), // 2nd
                  children: [
                    Container(
                      color: Color(0xFFFFFFF),
                      child: GalleryView(
                        imageUrl: [...image, ...urlImage],
                        imageProvider: [...imagePro, ...urlImageProvider],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 10.0, left: 10.0),
                      margin: EdgeInsets.only(right: 50.0, top: 10.0),
                      child: Text(
                        '${model['title']}',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  model['userList'] != null
                                      ? '${model['userList'][0]['imageUrl']}'
                                      : '${model['imageUrlCreateBy']}',
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      model['userList'] != null
                                          ? '${model['userList'][0]['firstName']} ${model['userList'][0]['lastName']}'
                                          : '${model['createBy']}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Kanit',
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          dateStringToDate(
                                                model['createDate'],
                                              ) +
                                              ' | ',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontFamily: 'Kanit',
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        Text(
                                          'เข้าชม ' +
                                              '${model['view']}' +
                                              ' ครั้ง',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontFamily: 'Kanit',
                                            fontWeight: FontWeight.w300,
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
                      ],
                    ),
                    Container(height: 10),
                    Container(
                      padding: const EdgeInsets.only(right: 10, left: 10),
                      child: Html(
                        data: model['description'],
                        onLinkTap:
                            (url, attributes, element) =>
                                linkUrl(Uri.parse(url ?? "")),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    model['linkUrl'] != '' ? linkUrl(model) : Container(),
                    SizedBox(height: 20.0),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                top: statusBarHeight + 5,
                child: Container(child: buttonCloseBack(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  linkUrl(dynamic model) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 80.0),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: Color(0xFFA9151D)),
          ),
          child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            onPressed: () {
              launch(model['linkUrl']);
            },
            child: Text(
              model['textButton'] != '' ? model['textButton'] : 'ไปยังลิงค์',
              style: TextStyle(color: Color(0xFFA9151D), fontFamily: 'Kanit'),
            ),
          ),
        ),
      ),
    );
  }

  myContentElse() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topCenter,
            // overflow: Overflow.visible,
            children: [
              Stack(
                children: [
                  Container(height: 540, width: double.infinity),
                  Container(height: 540, color: Colors.black.withOpacity(0.5)),
                ],
              ),
              Column(
                children: [
                  SizedBox(height: 60.0),
                  Container(
                    height: 110,
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      top: 10.0,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '',
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontFamily: 'Kanit',
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontFamily: 'Kanit',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    width: 400.0,
                    padding: EdgeInsets.only(left: 90.0, right: 90.0),
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                      child: Container(
                        alignment: Alignment(1, 1),
                        child: MaterialButton(
                          minWidth: MediaQuery.of(context).size.width,
                          onPressed: () {},
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Image.asset(
                                    'assets/logo/icons/Group337.png',
                                    height: 5.0,
                                    width: 5.0,
                                  ),
                                ),
                                width: 35.0,
                                height: 35.0,
                              ),
                              Text(
                                'อ่าน',
                                style: TextStyle(
                                  color: Color(0xFF1B6CA8),
                                  fontFamily: 'Kanit',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 50.0),
        ],
      ),
    );
  }

  linkButton(dynamic model) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: 45.0,
      padding: EdgeInsets.symmetric(horizontal: 80.0),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: Color(0xFF1B6CA8)),
          ),
          child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            onPressed: () {
              launch('${model['linkUrl']}');
            },
            child: Text(
              '${model['textButton']}',
              style: TextStyle(color: Color(0xFF1B6CA8), fontFamily: 'Kanit'),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
      ),
    );
  }
}
