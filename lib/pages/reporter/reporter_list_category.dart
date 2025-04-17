import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opec/pages/contact/carousel_banner.dart';
import 'package:opec/pages/reporter/reporter_history_list.dart';
import 'package:opec/pages/reporter/reporter_list_category_vertical.dart';
import 'package:opec/widget/carousel.dart';
import 'package:opec/widget/header.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:opec/shared/api_provider.dart';

class ReporterListCategory extends StatefulWidget {
  ReporterListCategory({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _ReporterListCategory createState() => _ReporterListCategory();
}

class _ReporterListCategory extends State<ReporterListCategory> {
  final storage = new FlutterSecureStorage();

  late ReporterListCategoryVertical reporter;
  bool hideSearch = true;
  final txtDescription = TextEditingController();
  late String keySearch;
  late String category;

  Future<dynamic> _futureBanner = Future.value(null);
  Future<dynamic> _futureCategoryReporter = Future.value(null);
  // final ScrollController _controller = ScrollController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _futureCategoryReporter =
        post('${reporterCategoryApi}read', {'skip': 0, 'limit': 50});
    _futureBanner = post('${reporterBannerApi}read', {'skip': 0, 'limit': 50});

    // _controller.addListener(_scrollListener);
    super.initState();
    // reporter = new ReporterListCategoryVertical(
    //   site: "OPEC",
    //   model: service
    //       .post('${service.reporterCategoryApi}read', {'skip': 0, 'limit': 100}),
    //   title: "",
    //   url: '${service.reporterCategoryApi}read',
    // );
  }

  void goBack() async {
    Navigator.pop(context, false);
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => MenuV2()),
    // );
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(
    //     builder: (context) => MenuV2(),
    //   ),
    //   (Route<dynamic> route) => false,
    // );
  }

  void _handleClickMe() async {
    var value = await storage.read(key: 'dataUserLoginOPEC') ?? "";
    var user = json.decode(value);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReporterHistoryList(
          title: 'ประวัติ',
          username: user['username'],
        ),
      ),
    );
    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
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
        appBar: header(
          context,
          goBack,
          title: widget.title,
          isButtonRight: true,
          rightButton: () => _handleClickMe(),
          menu: 'reporter',
        ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            return false;
          },
          child: ListView(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            children: [
              Container(
                height: (height * 25) / 100,
                child: CarouselBanner(
                  model: _futureBanner,
                  nav: (String path, String action, dynamic model, String code,
                      String urlGallery) {
                    if (action == 'out') {
                      launch(path);
                    } else if (action == 'in') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarouselForm(
                            code: code,
                            model: model,
                            url: reporterBannerApi,
                            urlGallery: bannerGalleryApi,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 10),
              ReporterListCategoryVertical(
                model: _futureCategoryReporter,
                url: '${reporterCategoryApi}read',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
