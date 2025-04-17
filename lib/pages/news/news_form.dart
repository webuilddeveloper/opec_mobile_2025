import 'package:flutter/material.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/button.dart';
import 'package:opec/widget/comment.dart';
import 'package:opec/widget/content.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// ignore: must_be_immutable
class NewsForm extends StatefulWidget {
  NewsForm({
    Key? key,
    required this.code,
    this.model,
  }) : super(key: key);

  final String code;
  final dynamic model;

  @override
  _NewsForm createState() => _NewsForm();
}

class _NewsForm extends State<NewsForm> {
  late Comment comment;
  late int _limit;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;

      comment = Comment(
        code: widget.code,
        url: newsCommentApi,
        model: post('${newsCommentApi}read',
            {'skip': 0, 'limit': _limit, 'code': widget.code}),
        limit: _limit,
      );
    });

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  @override
  void initState() {
    sendReportCategory(widget.model['category']);
    setState(() {
      _limit = 10;
    });

    comment = Comment(
      code: widget.code,
      url: newsCommentApi,
      model: post('${newsCommentApi}read',
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
        } else if (details.delta.dx < -0) {
          //Left Swipe
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    Color(0xFFEEBA33),
                    Color(0xFFEEBA33),
                  ],
                ),
              ),
            ),
          ),
        ),
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
                        pathShare: 'content/news/',
                        code: widget.code,
                        url: newsReadApi,
                        model: widget.model,
                        urlGallery: newsGalleryApi,
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
      ),
    );
  }

  sendReportCategory(String category) {
    postCategory(
      '${newsCategoryApi}read',
      {'skip': 0, 'limit': 1, 'code': category},
    );
  }
}
