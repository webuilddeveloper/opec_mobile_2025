import 'package:flutter/material.dart';
import 'package:opec/pages/notification/content_notification.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/button.dart';
import 'package:opec/widget/comment.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// ignore: must_be_immutable
class MainPageForm extends StatefulWidget {
  MainPageForm({
    Key? key,
    required this.code,
    this.model,
  }) : super(key: key);

  final String code;
  final dynamic model;

  @override
  _MainPageForm createState() => _MainPageForm();
}

class _MainPageForm extends State<MainPageForm> {
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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
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
                children: [
                  ContentNotification(
                    code: widget.code,
                    url: notificationApi + 'detail',
                    model: widget.model,
                  ),
                  Positioned(
                    right: 0,
                    top: statusBarHeight + 5,
                    child: Container(
                      child: buttonCloseBack(context),
                    ),
                  ),
                ],
              ),
              // comment,
            ],
          ),
        ),
      ),
    );
  }
}
