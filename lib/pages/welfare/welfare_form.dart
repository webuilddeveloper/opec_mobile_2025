import 'package:flutter/material.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/button.dart';
import 'package:opec/widget/comment.dart';
import 'package:opec/widget/content.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// ignore: must_be_immutable
class WelfareForm extends StatefulWidget {
  WelfareForm({
    Key? key,
    required this.code,
    this.model,
  }) : super(key: key);

  final String code;
  final dynamic model;

  @override
  _WelfareForm createState() => _WelfareForm();
}

class _WelfareForm extends State<WelfareForm> {
  late Comment comment;
  late int _limit;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;

      comment = Comment(
        code: widget.code,
        url: welfareCommentApi,
        model: post('${welfareCommentApi}read',
            {'skip': 0, 'limit': _limit, 'code': widget.code}),
        limit: _limit,
      );
    });

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  @override
  void initState() {
    setState(() {
      _limit = 10;
    });

    comment = Comment(
      code: widget.code,
      url: welfareCommentApi,
      model: post('${welfareCommentApi}read',
          {'skip': 0, 'limit': _limit, 'code': widget.code}),
      limit: _limit,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
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
                    Content(
                      pathShare: 'content/welfare/',
                      code: widget.code,
                      url: welfareApi + 'read',
                      model: widget.model,
                      urlGallery: welfareGalleryApi,
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
                comment,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
