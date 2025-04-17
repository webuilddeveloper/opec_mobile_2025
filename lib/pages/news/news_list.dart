import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opec/pages/fund/fund_list_vertical.dart';
import 'package:opec/pages/news/news_card.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/blank.dart';
import 'package:opec/widget/header.dart';
import 'package:opec/widget/key_search.dart';
import 'package:opec/widget/tab_category.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NewsList extends StatefulWidget {
  NewsList({
    Key? key,
    required this.title,
    this.profileCode = "",
    this.profileUserName = "",
    this.profileCategory = "",
  }) : super(key: key);

  final String title;
  final String profileCode;
  final String profileUserName;
  final String profileCategory;

  @override
  _NewsList createState() => _NewsList();
}

class _NewsList extends State<NewsList> {
  bool hideSearch = true;
  final txtDescription = TextEditingController();
  String keySearch = '';
  String category = '';
  int _limit = 10;

  bool showNews = true;

  final storage = FlutterSecureStorage();
  Future<dynamic> futureModel = Future.value(null);
  Future<dynamic> futureCategory = Future.value(null);
  Future<dynamic> futureFundModel = Future.value(null);
  Future<dynamic> futureFundCategory = Future.value(null);
  List<dynamic> listTemp = [
    {
      'code': '',
      'title': '',
      'imageUrl': '',
      'createDate': '',
      'userList': [
        {'imageUrl': '', 'firstName': '', 'lastName': ''},
      ],
    },
  ];
  bool showLoadingItem = true;

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  final RefreshController _refreshController2 = RefreshController(
    initialRefresh: false,
  );

  // final ScrollController _controller = ScrollController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  @override
  void initState() {
    futureModel = post(newsReadApi, {
      'skip': 0,
      'limit': _limit,
      "category": category,
      "keySearch": keySearch,
      'profileCode': widget.profileCode,
      'username': widget.profileUserName,
      'phone': widget.profileCategory,
    });

    futureCategory = postCategory('${newsCategoryApi}read', {
      'skip': 0,
      'limit': 100,
    });

    futureFundModel = post('${fundApi}read', {
      'skip': 0,
      'limit': _limit,
      "category": category,
      "keySearch": keySearch,
    });

    futureFundCategory = postCategory('${fundCategoryApi}read', {
      'skip': 0,
      'limit': 100,
    });

    super.initState();
  
  }

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;
      futureModel = post(newsReadApi, {
        'skip': 0,
        'limit': _limit,
        "category": category,
        "keySearch": keySearch,
        'profileCode': widget.profileCode,
        'username': widget.profileUserName,
        'phone': widget.profileCategory,
      });
    });

    await Future.delayed(Duration(milliseconds: 2000));

    _refreshController.loadComplete();
  }

  void _onLoading2() async {
    setState(() {
      _limit = _limit + 10;

      futureFundModel = post('${fundApi}read', {
        'skip': 0,
        'limit': _limit,
        "keySearch": keySearch,
        "category": category,
      });
    });

    await Future.delayed(Duration(milliseconds: 2000));

    _refreshController2.loadComplete();
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
        } else if (details.delta.dx < -0) {
          //Left Swipe
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: header(context, goBack, title: widget.title),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            return false;
          },
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              children: [
                SizedBox(height: 10),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        onTap: () {
                          postTrackClick("ข่าว สช.");
                          setState(() {
                            showNews = true;
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: (MediaQuery.of(context).size.width / 100) * 48,
                          height:
                              (MediaQuery.of(context).size.height / 100) * 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0XFFEEBA33),
                          ),
                          child: Text(
                            'ข่าว สช.',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0XFF9A1120),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          postTrackClick("ข่าวกองทุน");
                          setState(() {
                            showNews = false;
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: (MediaQuery.of(context).size.width / 100) * 48,
                          height:
                              (MediaQuery.of(context).size.height / 100) * 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0XFFEEBA33),
                          ),
                          child: Text(
                            'ข่าวกองทุน',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0XFF9A1120),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                showNews
                    ? CategorySelector(
                      model: futureCategory,
                      onChange: (String val) {
                        setData(val, keySearch);
                      },
                    )
                    : CategorySelector(
                      model: futureFundCategory,
                      onChange: (String val) {
                        setDataFund(val, keySearch);
                      },
                    ),
                SizedBox(height: 5),
                showNews
                    ? KeySearch(
                      key: Key('news'),
                      show: hideSearch,
                      onKeySearchChange: (String val) {
                        setData(category, val);
                      },
                    )
                    : KeySearch(
                      key: Key('fund'),
                      show: hideSearch,
                      onKeySearchChange: (String val) {
                        setDataFund(category, val);
                      },
                    ),
                SizedBox(height: 10),
                showNews
                    ? Expanded(child: buildNewsList())
                    : Expanded(
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
                        controller: _refreshController2,
                        onLoading: _onLoading2,
                        child: ListView(
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            FundListVertical(
                              site: "OPEC",
                              model: futureFundModel,
                              url: '${fundApi}read',
                              urlGallery: '$fundGalleryApi',
                              urlComment: '$fundCommentApi',
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  FutureBuilder buildNewsList() {
    return FutureBuilder<dynamic>(
      future: futureModel, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (showLoadingItem) {
            return blankListData(context, height: 300);
          } else {
            return refreshList(listTemp);
          }
        } else if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return Container(
              alignment: Alignment.center,
              height: 200,
              child: Text(
                'ไม่พบข้อมูล',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Kanit',
                  color: Colors.grey,
                ),
              ),
            );
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                showLoadingItem = false;
                listTemp = snapshot.data;
              });
            });
            return refreshList(snapshot.data);
          }
        } else if (snapshot.hasError) {
          // return dialogFail(context);
          return InkWell(
            onTap: () {
              setState(() {
                futureModel = post(newsReadApi, {
                  'skip': 0,
                  'limit': _limit,
                  "category": category,
                  "keySearch": keySearch,
                  'profileCode': widget.profileCode,
                  'username': widget.profileUserName,
                  'phone': widget.profileCategory,
                });
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, size: 50.0, color: Colors.blue),
                Text('ลองใหม่อีกครั้ง'),
              ],
            ),
          );
        } else {
          return refreshList(listTemp);
        }
      },
    );
  }

  SmartRefresher refreshList(List<dynamic> model) {
    return SmartRefresher(
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
      child: ListView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: model.length,
        itemBuilder: (context, index) {
          return newsCard(
            context,
            model[index],
            username: widget.profileUserName,
            category: widget.profileCategory,
          );
        },
      ),
    );
  }

  setData(String category, String keySearkch) {
    setState(() {
      if (keySearch != "") {
        showLoadingItem = true;
      }
      keySearch = keySearkch;
      _limit = 10;
      futureModel = post(newsReadApi, {
        'skip': 0,
        'limit': _limit,
        "category": category,
        "keySearch": keySearch,
        'profileCode': widget.profileCode,
        'username': widget.profileUserName,
        'phone': widget.profileCategory,
      });
    });
  }

  setDataFund(String category, String keySearkch) {
    setState(() {
      if (keySearch != "") {
        showLoadingItem = true;
      }
      keySearch = keySearkch;
      _limit = 10;
      futureFundModel = post('${fundApi}read', {
        'skip': 0,
        'limit': _limit,
        "keySearch": keySearch,
        'category': category,
      });
    });
  }
}
