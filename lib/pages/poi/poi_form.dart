import 'package:flutter/material.dart';
import 'package:opec/pages/poi/contentPoi.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/button.dart';
import 'package:opec/widget/comment.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// ignore: must_be_immutable
class PoiForm extends StatefulWidget {
  PoiForm({
    Key? key,
    required this.url,
    required this.code,
    this.model,
    this.urlComment = '',
    required this.urlGallery,
  }) : super(key: key);

  final String url;
  final String code;
  final dynamic model;
  final String urlComment;
  final String urlGallery;

  @override
  _PoiForm createState() => _PoiForm();
}

class _PoiForm extends State<PoiForm> {
  late Comment comment;
  late int _limit;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;

      comment = Comment(
        code: widget.code,
        url: poiCommentApi,
        model: post('${poiCommentApi}read',
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
      url: poiCommentApi,
      model: post('${poiCommentApi}read',
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
                // Expanded(
                //   child:
                Stack(
                  // fit: StackFit.expand,
                  // alignment: AlignmentDirectional.bottomCenter,
                  // shrinkWrap: true,
                  // physics: ClampingScrollPhysics(),
                  children: [
                    ContentPoi(
                      pathShare: 'content/news/',
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
                ),

                widget.urlComment != '' ? comment : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
