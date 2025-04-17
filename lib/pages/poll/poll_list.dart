import 'package:flutter/material.dart';
import 'package:opec/pages/poll/poll_list_vertical.dart';
import 'package:opec/shared/api_provider.dart' as service;
import 'package:opec/user.dart';
import 'package:opec/widget/header.dart';
import 'package:opec/widget/key_search.dart';
import 'package:opec/widget/tab_category.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PollList extends StatefulWidget {
  PollList({Key? key, required this.userData, required this.title})
    : super(key: key);

  final User userData;
  final String title;

  @override
  _PollList createState() => _PollList();
}

class _PollList extends State<PollList> {
  late PollListVertical poll;
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

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;

      poll = PollListVertical(
        model: service.post('${service.pollApi}read', {
          'skip': 0,
          'limit': _limit,
          'username': widget.userData.username,
        }),
        titleHome: widget.title,
        url: '${service.pollApi}read',
        callBack: () {},
      );
    });

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  @override
  void initState() {
    // _controller.addListener(_scrollListener);
    super.initState();

    poll = PollListVertical(
      // poll = new PollListVertical(
      model: service.post('${service.pollApi}read', {
        'skip': 0,
        'limit': _limit,
        'username': widget.userData.username,
      }),
      url: '${service.pollApi}read',
      titleHome: widget.title,
      callBack: () => {_onLoading()},
    );
  }

  void goBack() async {
    Navigator.of(context).popUntil((route) => route.isFirst);
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
                model: service.postCategory('${service.pollCategoryApi}read', {
                  'skip': 0,
                  'limit': 100,
                }),
                onChange: (String val) {
                  setState(() {
                    category = val;
                    poll = PollListVertical(
                      model: service.post('${service.pollApi}read', {
                        'skip': 0,
                        'limit': _limit,
                        "category": category,
                        'username': widget.userData.username,
                      }),
                      url: '${service.pollApi}read',
                      title: widget.title,
                      titleHome: widget.title,
                      callBack: () => {_onLoading()},
                    );
                  });
                },
              ),
              SizedBox(height: 5),
              KeySearch(
                show: hideSearch,
                onKeySearchChange: (String val) {
                  // pollList(context, service.post('${service.pollApi}read', {'skip': 0, 'limit': 100,"keySearch": val}),'');
                  setState(() {
                    keySearch = val;
                    poll = PollListVertical(
                      model: service.post('${service.pollApi}read', {
                        'skip': 0,
                        'limit': _limit,
                        "keySearch": keySearch,
                        'category': category,
                        'username': widget.userData.username,
                      }),
                      url: '${service.pollApi}read',
                      callBack: () => {_onLoading()},
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
                    children: [poll],
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
