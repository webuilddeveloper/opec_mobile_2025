import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/shared/extension.dart';
import 'package:opec/widget/button.dart';
import 'package:opec/widget/comment.dart';
import 'package:opec/widget/gallery_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class CarouselForm extends StatefulWidget {
  CarouselForm({
    Key? key,
    required this.url,
    required this.code,
    this.model,
    required this.urlGallery,
  }) : super(key: key);

  final String url;
  final String code;
  final dynamic model;
  final String urlGallery;

  @override
  _CarouselForm createState() => _CarouselForm();
}

class _CarouselForm extends State<CarouselForm> {
  late Comment comment;
  late int _limit;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;
    });

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  @override
  void initState() {
    setState(() {
      _limit = 10;
    });

    // comment = Comment(
    //   code: widget.code,
    //   url: widget.urlComment,
    //   model: post('${newsCommentApi}read',
    //       {'skip': 0, 'limit': _limit, 'code': widget.code}),
    //   limit: _limit,
    // );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return MaterialApp(
      title: '',
      home: Scaffold(
        backgroundColor: Colors.white,
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            return false;
          },
          child: SmartRefresher(
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
              shrinkWrap: true,
              children: [
                Stack(
                  // fit: StackFit.expand,
                  // alignment: AlignmentDirectional.bottomCenter,
                  // shrinkWrap: true,
                  // physics: ClampingScrollPhysics(),
                  children: [
                    ContentCarousel(
                      code: widget.code,
                      url: widget.url,
                      model: widget.model,
                      urlGallery: widget.urlGallery,
                    ),
                    Positioned(
                      right: 0,
                      top: statusBarHeight + 5,
                      child: Container(
                        child: buttonCloseBack(context),
                      ),
                    ),
                  ],
                  // overflow: Overflow.clip,
                ),
                // widget.urlComment != '' ? comment : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ignore: must_be_immutable
class ContentCarousel extends StatefulWidget {
  ContentCarousel({
    Key? key,
    required this.code,
    required this.url,
    this.model,
    required this.urlGallery,
  }) : super(key: key);

  final String code;
  final String url;
  final dynamic model;
  final String urlGallery;

  @override
  _ContentCarousel createState() => _ContentCarousel();
}

class _ContentCarousel extends State<ContentCarousel> {
  Future<dynamic> _futureModel = Future.value(null);

  // String _urlShared = '';
  List urlImage = [];
  List<ImageProvider> urlImageProvider = [];

  @override
  void initState() {
    super.initState();
    _futureModel = postDio(
        widget.url + 'read', {'skip': 0, 'limit': 1, 'code': widget.code});
    readGallery();
    // sharedApi();
  }

  Future<dynamic> readGallery() async {
    final result = await postDio(widget.urlGallery, {'code': widget.code});
    if (result != null) {
      List data = [];
      List<ImageProvider> dataPro = [];
      for (var item in result) {
        data.add(item['imageUrl']);

        dataPro.add(NetworkImage(item['imageUrl']));
      }
      setState(() {
        urlImage = data;
        urlImageProvider = dataPro;
      });
    }
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
          return myContent(
            widget.model,
          );
          // return myContent(widget.model);
        }
      },
    );
  }

  myContent(dynamic model) {
    List image = [model['imageUrl']];
    List<ImageProvider> imagePro = [NetworkImage(model['imageUrl'])];
    return ListView(
      shrinkWrap: true, // 1st add
      physics: ClampingScrollPhysics(), // 2nd
      children: [
        Container(
          // color: Colors.green,
          padding: EdgeInsets.only(
            right: 10.0,
            left: 10.0,
          ),
          margin: EdgeInsets.only(right: 50.0, top: 10.0),
          child: Text(
            '${model['title']}',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Kanit',
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: 10,
                left: 10,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        NetworkImage('${model['imageUrlCreateBy']}'),
                    // child: Image.network(
                    //     '${snapshot.data[0]['imageUrlCreateBy']}'),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${model['createBy']}',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Kanit',
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              dateStringToDate(model['createDate']),
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'Kanit',
                              ),
                            ),
                            // Text(
                            //   ' | ' + 'เข้าชม ' + '${model['view']}' + ' ครั้ง',
                            //   style: TextStyle(
                            //     fontSize: 10,
                            //     fontFamily: 'Kanit',
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Container(
            //   width: 74.0,
            //   height: 31.0,
            //   decoration: BoxDecoration(
            //       image: DecorationImage(
            //     image: AssetImage('assets/images/share.png'),
            //   )),
            //   alignment: Alignment.centerRight,
            //   child: FlatButton(
            //     padding: EdgeInsets.all(0.0),
            //     onPressed: () {
            //       final RenderBox box = context.findRenderObject();
            //       Share.share(
            //         _urlShared +
            //             'content/news/' +
            //             '${model['code']}' +
            //             '${model['title']}',
            //         subject: '${model['title']}',
            //         sharePositionOrigin:
            //             box.localToGlobal(Offset.zero) & box.size,
            //       );
            //     },
            //   ),
            // )
          ],
        ),
        Container(
          // width: 500.0,
          color: Color(0xFFFFFFF),
          child: GalleryView(
            imageUrl: [...image, ...urlImage],
            imageProvider: [...imagePro, ...urlImageProvider],
          ),
        ),
        Container(
          height: 10,
        ),
        // Image.network('${model['imageUrl']}'),
        // Container(
        //   height: 20,
        // ),
        Padding(
          padding: const EdgeInsets.only(
            right: 10,
            left: 10,
          ),
          // child: HtmlView(
          //   data: model['description'],
          //   scrollable:
          //       false, //false to use MarksownBody and true to use Marksown
          //),
          child: Html(
            data: model['description'],
          onLinkTap: (url, attributes, element) => launchUrl(Uri.parse(url ?? "")),
          ),
        ),
      ],
    );
  }
}


class CarouselRotation extends StatefulWidget {
  CarouselRotation({Key? key, required this.model, required this.nav}) : super(key: key);

  final Future<dynamic> model;
  final Function(String, String, dynamic, String) nav;

  @override
  _CarouselRotation createState() => _CarouselRotation();
}

class _CarouselRotation extends State<CarouselRotation> {
  final txtDescription = TextEditingController();
  int _current = 0;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: (height * 18.5) / 100,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    autoPlay: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    },
                  ),
                  items: snapshot.data.map<Widget>(
                    (document) {
                      return new InkWell(
                        onTap: () {
                          widget.nav(
                            snapshot.data[_current]['linkUrl'],
                            snapshot.data[_current]['action'],
                            snapshot.data[_current],
                            snapshot.data[_current]['code'],
                          );
                        },
                        child: Container(
                          child: Center(
                            child: Image.network(
                              document['imageUrl'],
                              fit: BoxFit.fill,
                              height: (height * 18.5) / 100,
                              width: (width * 100) / 100,
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Container(
                    child: Text(
                      (_current + 1).toString() +
                          '/' +
                          snapshot.data.length.toString(),
                    ),
                  ),
                ]

                    // snapshot.data.map<Widget>(
                    //   (url) {
                    //     int index = snapshot.data.indexOf(url);

                    //     return Container(
                    //       width: _current == index ? 20.0 : 5.0,
                    //       height: 5.0,
                    //       margin: _current == index
                    //           ? EdgeInsets.symmetric(
                    //               vertical: 5.0, horizontal: 1.0)
                    //           : EdgeInsets.symmetric(
                    //               vertical: 5.0, horizontal: 2.0),
                    //       decoration: BoxDecoration(
                    //         borderRadius: BorderRadius.circular(5),
                    //         // shape: BoxShape.circle,
                    //         color: _current == index
                    //             ? Color(0xFF6F0100)
                    //             : Color.fromRGBO(0, 0, 0, 0.4),
                    //       ),
                    //     );
                    //   },
                    // ).toList(),
                    ),
              ],
            );
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }
}
