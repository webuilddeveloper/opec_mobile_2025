import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opec/widget/blank.dart';
import 'package:opec/widget/button.dart';
import 'package:opec/widget/gallery_view.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:opec/shared/api_provider.dart';
import 'package:flutter/services.dart';
import 'package:opec/shared/extension.dart';

class PrivilegeForm extends StatefulWidget {
  PrivilegeForm({Key? key, required this.code, this.model}) : super(key: key);
  final String code;
  final dynamic model;

  @override
  _PrivilegeDetailPageState createState() =>
      _PrivilegeDetailPageState(code: code);
}

class _PrivilegeDetailPageState extends State<PrivilegeForm> {
  _PrivilegeDetailPageState({required this.code});

  final storage = new FlutterSecureStorage();
  String profileCode = '';
  Future<dynamic> _futureModel = Future.value(null);
  // String _urlShared = '';
  String code;
  List urlImage = [];
  List<ImageProvider> urlImageProvider = [];

  @override
  void initState() {
    readGallery();
    _read();
    super.initState();
  }

  _read() async {
    profileCode = await storage.read(key: 'profileCode25') ?? "";
    _futureModel = postDio('${privilegeApi}read', {
      'skip': 0,
      'limit': 1,
      'code': widget.code,
    });
  }

  Future<dynamic> readGallery() async {
    final result = await postDio(privilegeGalleryApi, {'code': widget.code});

    // if (result['status'] == 'S') {
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
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder<dynamic>(
          future: _futureModel, // function where you call your api
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            // AsyncSnapshot<Your object type>

            if (snapshot.hasData) {
              return myContent(snapshot.data[0]);
            } else {
              if (widget.model != null) {
                return myContent(widget.model);
              } else {
                return BlankLoading();
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
                      // width: 500.0,
                      color: Color(0xFFFFFFF),
                      child: GalleryView(
                        imageUrl: [...image, ...urlImage],
                        imageProvider: [...imagePro, ...urlImageProvider],
                      ),
                    ),
                    Container(
                      // color: Colors.green,
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
                                backgroundImage:
                                    model['userList'][0]['imageUrl'] != null
                                        ? NetworkImage(
                                          '${model['userList'][0]['imageUrl']}',
                                        )
                                        : null,
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
                    ),
                    SizedBox(height: 20.0),
                    Container(
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
                              if (model['isPostHeader']) {
                                var path = model['linkUrl'];
                                if (profileCode != '') {
                                  var splitCheck =
                                      path.split('').reversed.join();
                                  if (splitCheck[0] != "/") {
                                    path = path + "/";
                                  }
                                  var codeReplae =
                                      "P" +
                                      profileCode.replaceAll('-', '') +
                                      model['code'].replaceAll('-', '');
                                  launch('$path$codeReplae');
                                  // launch(path);
                                }
                              } else
                                launch(model['linkUrl']);
                            },
                            child: Text(
                              model['textButton'],
                              style: TextStyle(
                                color: Color(0xFFA9151D),
                                fontFamily: 'Kanit',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
            // overflow: Overflow.clip,
          ),
        ],
      ),
    );
  }
}
