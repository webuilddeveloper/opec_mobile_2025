import 'package:flutter/material.dart';
import 'package:opec/pages/fund/fund_list_vertical.dart';
import 'package:opec/shared/api_provider.dart' as service;
import 'package:opec/widget/header.dart';
import 'package:opec/widget/key_search.dart';
import 'package:opec/widget/tab_category.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FundList extends StatefulWidget {
  FundList({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _FundList createState() => _FundList();
}

class _FundList extends State<FundList> {
  late FundListVertical fund;
  bool hideSearch = true;
  final txtDescription = TextEditingController();
  late String keySearch;
  late String category;
  int _limit = 10;

  final RefreshController _refreshController = RefreshController(
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
    // _controller.addListener(_scrollListener);
    super.initState();

    fund = FundListVertical(
      site: "OPEC",
      model: service.post('${service.fundApi}read', {
        'skip': 0,
        'limit': _limit,
      }),
      url: '${service.fundApi}read',
      urlGallery: service.fundGalleryApi,
      urlComment: service.fundCommentApi,
    );
  }

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;

      fund = FundListVertical(
        // fund = new FundListVertical(
        site: "OPEC",
        model: service.post('${service.fundApi}read', {
          'skip': 0,
          'limit': _limit,
          'category': category,
          "keySearch": keySearch,
        }),
        url: '${service.fundApi}read',
        urlComment: service.fundCommentApi,
        urlGallery: service.fundGalleryApi,
      );
    });

    await Future.delayed(Duration(milliseconds: 1000));

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
          child: Column(
            children: [
              SizedBox(height: 5),
              CategorySelector(
                model: service.postCategory('${service.fundCategoryApi}read', {
                  'skip': 0,
                  'limit': 100,
                }),
                onChange: (String val) {
                  setState(() {
                    category = val;
                    fund = FundListVertical(
                      site: 'OPEC',
                      model: service.post('${service.fundApi}read', {
                        'skip': 0,
                        'limit': _limit,
                        "category": category,
                        "keySearch": keySearch,
                      }),
                      url: '${service.fundApi}read',
                      urlGallery: service.fundGalleryApi,
                      urlComment: service.fundCommentApi,
                    );
                  });
                },
              ),
              SizedBox(height: 5),
              KeySearch(
                show: hideSearch,
                onKeySearchChange: (String val) {
                  setState(() {
                    keySearch = val;
                    fund = FundListVertical(
                      site: 'OPEC',
                      model: service.post('${service.fundApi}read', {
                        'skip': 0,
                        'limit': _limit,
                        "keySearch": keySearch,
                        'category': category,
                      }),
                      url: '${service.fundApi}read',
                      urlGallery: service.fundGalleryApi,
                      urlComment: service.fundCommentApi,
                    );
                  });
                },
              ),
              SizedBox(height: 10),
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
                  child: ListView(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    children: [fund],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
