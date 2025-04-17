import 'package:flutter/material.dart';
import 'package:opec/pages/privilege/privilege_list_vertical.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PrivilegeList extends StatefulWidget {
  PrivilegeList({Key? key, this.keySearch, this.category, this.isHighlight})
    : super(key: key);

  final String? keySearch;
  final String? category;
  final bool? isHighlight;

  @override
  _PrivilegeList createState() => _PrivilegeList();
}

class _PrivilegeList extends State<PrivilegeList> {
  late PrivilegeListVertical gridView;
  bool hideSearch = true;
  int _limit = 1;

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    gridView = PrivilegeListVertical(
      model: post('${privilegeApi}read', {
        'skip': 0,
        'limit': _limit,
        'keySearch': widget.keySearch != null ? widget.keySearch : '',
        'isHighlight': widget.isHighlight != null ? widget.isHighlight : false,
        'category': widget.category != null ? widget.category : '',
      }),
    );
    super.initState();
  }

  void _onLoading() async {
    setState(() {
      _limit = _limit + 1;

      gridView = PrivilegeListVertical(
        model: post('${privilegeApi}read', {
          'skip': 0,
          'limit': _limit,
          'keySearch': widget.keySearch ?? '',
          'isHighlight':
              widget.isHighlight ?? false,
          'category': widget.category ?? '',
        }),
      );
    });

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  void goBack() async {
    Navigator.pop(context);
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
          physics: ClampingScrollPhysics(), // 2nd
          children: [
            // SubHeader(th: widget.title, en: ''),
            SizedBox(height: 5.0),
            gridView,
          ],
        ),
      ),
    );
  }
}
