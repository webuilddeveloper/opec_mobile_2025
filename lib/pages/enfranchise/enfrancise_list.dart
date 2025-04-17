import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opec/pages/enfranchise/enfrancise.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/widget/header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class EnfranciseListPage extends StatefulWidget {
  @override
  _EnfranciseListPageState createState() => _EnfranciseListPageState();
}

class _EnfranciseListPageState extends State<EnfranciseListPage> {
  Future<dynamic> futureModel = Future.value(null);
  ScrollController scrollController = new ScrollController();
  @override
  void initState() {
    _callRead();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,goBack, title: 'สิทธิ์ที่เคยได้รับ'),
      backgroundColor: Colors.white,
      body: FutureBuilder<dynamic>(
        future: futureModel,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return card(snapshot.data);
          } else if (snapshot.hasError) {
            return Center(
              child: Container(
                color: Colors.white,
                child: dialogFail(context, reloadApp: true),
              ),
            );
          } else {
            return Center(child: Container());
          }
        },
      ),
    );
  }

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  void _onRefresh() async {
    _callRead();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    _refreshController.loadComplete();
  }

  _callRead() {
    setState(() {
      futureModel = postDio('${server}m/enfranchise/readAccept', {});
    });
  }

  card(dynamic model) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: false,
      header: WaterDropHeader(
        complete: Container(child: Text('')),
        completeDuration: Duration(milliseconds: 0),
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        // controller: _controller,
        children: [
          Container(
            // color: Colors.transparent,
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            margin: EdgeInsets.only(top: 10),
            child: ListView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: model.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      margin: EdgeInsets.only(bottom: 5.0),
                      // width: 600,
                      child: Column(
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              minHeight: 50,
                              minWidth: double.infinity,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: new BorderRadius.circular(5.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 0,
                                  blurRadius: 7,
                                  offset: Offset(
                                    0,
                                    3,
                                  ), // changes position of shadow
                                ),
                              ],
                              color: Color(0xFFFFFFFF),
                            ),
                            padding: EdgeInsets.all(10.0),
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => EnfrancisePage(
                                          reference: '${model[index]['code']}',
                                        ),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.55,
                                    padding: EdgeInsets.only(left: 10.0),
                                    // color: Colors.red,
                                    child: Text(
                                      '${model[index]['title']}',
                                      style: TextStyle(
                                        // fontWeight: FontWeight.normal,
                                        fontSize: 15,
                                        fontFamily: 'Kanit',
                                        color: Color(0xFF6F0100),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    // color: Colors.yellow,
                                    child: Icon(
                                      Icons.keyboard_arrow_right,
                                      color: Color.fromRGBO(0, 0, 0, 0.5),
                                      size: 40.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
