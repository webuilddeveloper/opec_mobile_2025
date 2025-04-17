import 'package:flutter/material.dart';
import 'package:opec/pages/contact/carousel_banner.dart';
import 'package:opec/widget/carousel.dart';
import 'package:opec/widget/header.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/pages/contact/contact_list_category_vertical.dart';

class ContactListCategory extends StatefulWidget {
  ContactListCategory({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _ContactListCategory createState() => _ContactListCategory();
}

class _ContactListCategory extends State<ContactListCategory> {
  late ContactListCategoryVertical contact;
  bool hideSearch = true;
  final txtDescription = TextEditingController();
  late String keySearch;
  late String category;

  Future<dynamic> _futureBanner = Future.value(null);
  Future<dynamic> _futureCategoryContact = Future.value(null);
  // final ScrollController _controller = ScrollController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _futureCategoryContact = post('${contactCategoryApi}read', {
      'skip': 0,
      'limit': 999,
    });
    _futureBanner = postDio(rotationReadApi + "contact/read", {
      'skip': 0,
      'limit': 50,
    });

    super.initState();
  }

  void goBack() async {
    Navigator.pop(context, false);
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
        appBar: header(context, goBack, title: widget.title),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            return false;
          },
          child: ListView(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            // controller: _controller,
            children: [
              Container(
                height: (height * 25) / 100,
                // color: Colors.red,
                child: CarouselBanner(
                  model: _futureBanner,
                  nav: (
                    String path,
                    String action,
                    dynamic model,
                    String code,
                    String urlGallery,
                  ) {
                    if (action == 'out') {
                      launchUrl(Uri.parse(path));
                      // launch(path);
                    } else if (action == 'in') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CarouselForm(
                                code: code,
                                model: model,
                                url: rotationApi,
                                urlGallery: rotationGalleryApi,
                              ),
                        ),
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 10),
              ContactListCategoryVertical(
                model: _futureCategoryContact,
                url: '${contactCategoryApi}read',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
