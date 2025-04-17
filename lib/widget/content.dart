import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/shared/extension.dart';
import 'package:opec/widget/gallery_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

// ignore: must_be_immutable
class Content extends StatefulWidget {
  Content({
    Key? key,
    required this.code,
    required this.url,
    this.model,
    required this.urlGallery,
    required this.pathShare,
  }) : super(key: key);

  final String code;
  final String url;
  final dynamic model;
  final String urlGallery;
  final String pathShare;

  @override
  _Content createState() => _Content();
}

class _Content extends State<Content> {
  Future<dynamic> _futureModel = Future.value(null);

  String _urlShared = '';
  List urlImage = [];
  List<ImageProvider> urlImageProvider = [];

  @override
  void initState() {
    super.initState();
    sharedApi();
    _futureModel = postDio(widget.url, {
      'skip': 0,
      'limit': 1,
      'code': widget.code,
    });

    readGallery();
  }

  Future<dynamic> readGallery() async {
    var result = await postDio(widget.urlGallery, {'code': widget.code});

    if (result != null) {
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
    }
  }

  Future<dynamic> sharedApi() async {
    await postConfigShare().then(
      (result) => {
        if (result['status'] == 'S')
          {
            setState(() {
              _urlShared = result['objectData']['description'];
            }),
          },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _futureModel, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>
        if (snapshot.hasData) {
          // setState(() {
          //   urlImage = [snapshot.data[0].imageUrl];
          // });
          return myContent(
            snapshot.data[0],
          ); //   return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Container();
          // return myContent(
          //   widget.model,
          // );
          // return myContent(widget.model);
        }
      },
    );
  }

  myContent(dynamic model) {
    print(model);
    List image = ['${model['imageUrl']}'];
    List<ImageProvider> imagePro = [];
    if (model['imageUrl'] != null) {
      imagePro.add(NetworkImage(model['imageUrl']));
    }
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true, // 1st add
      physics: ClampingScrollPhysics(), // 2nd
      children: [
        Container(
          // width: 500.0,
          // color: Color(0xFFFFFFF),
          color: Colors.white,
          child: GalleryView(
            imageUrl: [...image, ...urlImage],
            imageProvider: [...imagePro, ...urlImageProvider],
            typeImage: '',
            typeImageUrl: model['typeImageUrl'],
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
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(right: 10, left: 10),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      child:
                          model['userList'] != null &&
                                  model['userList'].length > 0
                              ? CircleAvatar(
                                backgroundImage:
                                    model['userList'][0]['imageUrl'] != null
                                        ? NetworkImage(
                                          '${model['userList'][0]['imageUrl']}',
                                        )
                                        : null,
                              )
                              : Container(),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model['userList'] != null &&
                                    model['userList'].length > 0
                                ? '${model['userList'][0]['firstName']} ${model['userList'][0]['lastName']}'
                                : '${model['createBy']}',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w300,
                            ),
                            maxLines: 3,
                          ),
                          Row(
                            children: [
                              Text(
                                model['createDate'] != null
                                    ? dateStringToDate(model['createDate']) +
                                        ' | '
                                    : '',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Kanit',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                'เข้าชม ' + '${model['view']}' + ' ครั้ง',
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
            ),
            Container(
              width: 90,
              child: Container(
                width: 100.0,
                height: 35.0,
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.all(0.0), // กำหนด padding ตามที่ต้องการ
                    // backgroundColor:
                    //     Colors
                    //         .transparent, // ใช้สีที่โปร่งใสเพื่อไม่ให้มีสีพื้นหลัง
                  ),
                  onPressed: () {
                    final RenderBox box =
                        context.findRenderObject() as RenderBox;
                    ;
                    Share.share(
                      '$_urlShared${widget.pathShare}${model['code']} ${model['title']}',
                      subject: '${model['title']}',
                      sharePositionOrigin:
                          box.localToGlobal(Offset.zero) & box.size,
                    );
                  },
                  child: Image.asset('assets/images/share.png'),
                ),
              ),
            ),
          ],
        ),
        Container(height: 10),
        Padding(
          padding: const EdgeInsets.only(right: 10, left: 10),
          // child: HtmlView(
          //   data: model['description'],
          //   scrollable:
          //       false, //false to use MarksownBody and true to use Marksown
          // ),
          child: Html(
            data: model['description'],
            onLinkTap:
                (url, attributes, element) => launchUrl(Uri.parse(url ?? "")),
          ),
        ),
        Container(height: 10),
        model['linkUrl'] != '' && model['textButton'] != ''
            ? linkButton(model)
            : Container(),
        Container(height: 10),
        model['fileUrl'] != '' ? fileUrl(model) : Container(),
      ],
    );
  }

  linkButton(dynamic model) {
    return Container(
      alignment: Alignment.center,
      height: 45.0,
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: Color(0xFFFF7514)),
          ),
          child: MaterialButton(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            onPressed: () {
              launch('${model['linkUrl']}');
            },
            child: Text(
              '${model['textButton']}',
              style: TextStyle(color: Color(0xFFFF7514), fontFamily: 'Kanit'),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
      ),
    );
  }

  fileUrl(dynamic model) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      alignment: Alignment.center,
      child: InkWell(
        onTap: () {
          launch('${model['fileUrl']}');
        },
        child: Text(
          'เปิดเอกสารแนบ',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 14.0,
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
