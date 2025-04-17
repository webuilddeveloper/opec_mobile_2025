import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opec/pages/event_calendar/event_calendar_list_vertical.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:http/http.dart' as http;
import 'package:opec/widget/key_search.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class EventCalendarList extends StatefulWidget {
  EventCalendarList({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _EventCalendarList createState() => _EventCalendarList();
}

class _EventCalendarList extends State<EventCalendarList> {
  late EventCalendarList eventCalendarList;
  late EventCalendarListVertical gridView;

  // final ScrollController _controller = ScrollController();
  bool hideSearch = true;
  // Future<dynamic> _futureEventCalendarCategory;
  List<dynamic> listData = [];
  List<dynamic> category = [];
  bool isMain = true;
  String categorySelected = '';
  String keySearch = '';
  bool isHighlight = false;
  int _limit = 10;

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    // _futureEventCalendarCategory =
    //     post('${eventCalendarCategoryApi}read', {'skip': 0, 'limit': 100});
    categoryRead();
    super.initState();
  }

  Future<dynamic> categoryRead() async {
    var body = json.encode({
      "permission": "all",
      "skip": 0,
      "limit": 999, // integer value type
    });
    var response = await http.post(
      Uri.parse(eventCategoryReadApi),
      body: body,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
    );

    var data = json.decode(response.body);
    setState(() {
      category = data['objectData'];
    });

    if (category.length > 0) {
      for (int i = 0; i <= category.length - 1; i++) {
        var res = postDio(eventReadApi, {
          'limit': 100,
          'category': category[i]['code'],
          'keySearch': keySearch,
        });
        listData.add(res);
      }
    }
  }

  reloadList() {
    return gridView = EventCalendarListVertical(
      model: postDio(eventReadApi, {
        'limit': _limit,
        'keySearch': keySearch,
        'isHighlight': isHighlight,
        'category': categorySelected,
      }),
      urlGallery: eventGalleryReadApi,
      url: eventReadApi,
    );
  }

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;

      gridView = EventCalendarListVertical(
        model: postDio(eventReadApi, {
          'skip': 0,
          'limit': _limit,
          'keySearch': keySearch,
          'isHighlight': isHighlight,
          'category': categorySelected,
        }),
        urlGallery: eventGalleryReadApi,
        url: eventReadApi,
      );
    });

    await Future.delayed(Duration(milliseconds: 10000));

    _refreshController.loadComplete();
  }

  void goBack() async {
    Navigator.pop(context, false);
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => MenuV2(),
    //   ),
    // );
  }

  FutureBuilder<dynamic> tabCategory() {
    return FutureBuilder<dynamic>(
      future: postCategory(eventCategoryReadApi, {
        'skip': 0,
        'limit': 100,
      }), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          return Container(
            height: 45.0,
            padding: EdgeInsets.only(left: 5.0, right: 5.0),
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              borderRadius: BorderRadius.circular(6.0),
              color: Colors.white,
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    if (snapshot.data[index]['code'] != '') {
                      setState(() {
                        // keySearch = '';
                        // isMain = false;
                        categorySelected = snapshot.data[index]['code'];
                      });
                    } else {
                      setState(() {
                        // isHighlight = true;
                        categorySelected = '';
                        isMain = true;
                      });
                    }
                    setState(() {
                      categorySelected = snapshot.data[index]['code'];
                      // selectedIndex = index;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.0,
                      vertical: 10.0,
                    ),
                    child: Text(
                      snapshot.data[index]['title'],
                      style: TextStyle(
                        color:
                            categorySelected == snapshot.data[index]['code']
                                ? Colors.black
                                : Colors.grey,
                        decoration:
                            categorySelected == snapshot.data[index]['code']
                                ? TextDecoration.underline
                                : null,
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 1.2,
                        fontFamily: 'Kanit',
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Container(
            height: 45.0,
            padding: EdgeInsets.only(left: 5.0, right: 5.0),
            margin: EdgeInsets.symmetric(horizontal: 30.0),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              borderRadius: BorderRadius.circular(6.0),
              color: Colors.white,
            ),
          );
        }
      },
    );
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
        // appBar: header(context, goBack, title: widget.title),
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
                SizedBox(height: 5.0),
                tabCategory(),
                SizedBox(height: 10.0),
                KeySearch(
                  show: hideSearch,
                  onKeySearchChange: (String val) {
                    setState(() {
                      keySearch = val;
                    });
                  },
                ),
                SizedBox(height: 10.0),
                Expanded(
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
                    controller: _refreshController,
                    onLoading: _onLoading,
                    child: reloadList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
