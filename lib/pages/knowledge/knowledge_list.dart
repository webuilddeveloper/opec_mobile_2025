import 'package:flutter/material.dart';
import 'package:opec/pages/knowledge/knowledge_list_vertical.dart';
import 'package:opec/shared/api_provider.dart' as service;
import 'package:opec/widget/header.dart';
import 'package:opec/widget/key_search.dart';
import 'package:opec/widget/tab_category.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class KnowledgeList extends StatefulWidget {
  KnowledgeList({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _KnowledgeList createState() => _KnowledgeList();
}

class _KnowledgeList extends State<KnowledgeList> {
  late KnowledgeListVertical gridView;
  final txtDescription = TextEditingController();
  bool hideSearch = true;
  String keySearch = '';
  String category = '';
  int _limit = 10;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  // Future<dynamic> _futureKnowledge;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    gridView = KnowledgeListVertical(
      model: service
          .post('${service.knowledgeApi}read', {'skip': 0, 'limit': _limit}),
    );
  }

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;

      gridView = KnowledgeListVertical(
        model: service.post('${service.knowledgeApi}read', {
          'skip': 0,
          'limit': _limit,
          'category': category,
          "keySearch": keySearch
        }),
      );
    });

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
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
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            children: [
              SizedBox(height: 5),
              CategorySelector(
                model: service.postCategory(
                  '${service.knowledgeCategoryApi}read',
                  {'skip': 0, 'limit': 100},
                ),
                onChange: (String val) {
                  setState(
                    () {
                      category = val;
                      gridView = KnowledgeListVertical(
                        model: service.post('${service.knowledgeApi}read', {
                          'skip': 0,
                          'limit': _limit,
                          'category': category,
                          'keySearch': keySearch
                        }),
                      );
                    },
                  );
                },
              ),
              SizedBox(
                height: 5.0,
              ),
              KeySearch(
                show: hideSearch,
                onKeySearchChange: (String val) {
                  setState(
                    () {
                      keySearch = val;
                      gridView = KnowledgeListVertical(
                        model: service.post('${service.knowledgeApi}read', {
                          'skip': 0,
                          'limit': _limit,
                          'keySearch': keySearch,
                          'category': category
                        }),
                      );
                    },
                  );
                },
              ),
              SizedBox(
                height: 5.0,
              ),
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
                  child: gridView,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
