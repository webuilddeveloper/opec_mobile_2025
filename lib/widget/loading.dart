import 'package:flutter/material.dart';
import 'package:opec/widget/ColorLoader5.dart';

class CommentLoading extends StatefulWidget {
  // CardLoading({Key key, this.title}) : super(key: key);

  // final String title;

  @override
  _CommentLoading createState() => _CommentLoading();
}

class _CommentLoading extends State<CommentLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animatable<Color?> background = TweenSequence<Color?>([
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Colors.black.withAlpha(20),
        end: Colors.black.withAlpha(50),
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Colors.black.withAlpha(50),
        end: Colors.black.withAlpha(20),
      ),
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true, // 1st add
      physics: ClampingScrollPhysics(), // 2nd
      // scrollDirection: Axis.horizontal,
      itemCount: 3,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(5),
              alignment: Alignment.topLeft,
              height: 50,
              // decoration: BoxDecoration(
              //   borderRadius: new BorderRadius.circular(50),
              //   color: background.evaluate(
              //     AlwaysStoppedAnimation(_controller.value),
              //   ),
              // ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    // padding: EdgeInsets.only(
                    //     top: 5, bottom: 5, left: 15, right: 15),
                    width:
                        index == 0
                            ? 150
                            : index == 1
                            ? 250
                            : 200,
                    margin: EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(color: Colors.transparent),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Container(
                          // padding: EdgeInsets.all(5),
                          // alignment: Alignment.topLeft,
                          height: 40,
                          // decoration: BoxDecoration(
                          //   borderRadius: new BorderRadius.circular(20),
                          //   color: background.evaluate(
                          //     AlwaysStoppedAnimation(_controller.value),
                          //   ),
                          // ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class ListContentHorizontalLoading extends StatefulWidget {
  // CardLoading({Key key, this.title}) : super(key: key);

  // final String title;

  @override
  _ListContentHorizontalLoading createState() =>
      _ListContentHorizontalLoading();
}

class _ListContentHorizontalLoading extends State<ListContentHorizontalLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  dispose() {
    _controller.dispose(); // you need this
    super.dispose();
  }

  Animatable<Color?> background = TweenSequence<Color?>([
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Colors.black.withAlpha(20),
        end: Colors.black.withAlpha(50),
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Colors.black.withAlpha(50),
        end: Colors.black.withAlpha(20),
      ),
    ),
    // TweenSequenceItem(
    //   weight: 1.0,
    //   tween: ColorTween(
    //     begin: Colors.blue,
    //     end: Colors.pink,
    //   ),
    // ),
  ]);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      // decoration: BoxDecoration(
      // borderRadius: new BorderRadius.circular(5),
      // color: Color(0xFF9A1120),
      // color: Colors.transparent),
      width: 150,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.all(5),
            alignment: Alignment.topLeft,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.circular(5),
              color: background.evaluate(
                AlwaysStoppedAnimation(_controller.value),
              ),
            ),
          );
        },
      ),
    );
  }
}

loadingImageNetwork(
  String? url, {
  BoxFit? fit,
  double? height,
  double? width,
  Color? color,
  bool isProfile = false,
}) {
  url ??= '';
  if (url == '' && isProfile) {
    return Container(
      height: 30,
      width: 30,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.white),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Image.asset(
        'assets/images/user_not_found.png',
        color: Colors.white,
      ),
    );
  }
  return Image.network(
    url,
    fit: fit,
    height: height,
    width: width,
    color: color,
    loadingBuilder: (
      BuildContext context,
      Widget child,
      ImageChunkEvent? loadingProgress,
    ) {
      if (loadingProgress == null) return child;
      return Center(
        child:
            loadingProgress.expectedTotalBytes != null
                ? ColorLoader5(
                  dotOneColor: Color(0xFFED5643),
                  dotTwoColor: Colors.red,
                  dotThreeColor: Color(0xFFED5643),
                  // radius: 15,
                  // dotRadius: 6,
                )
                : Container(),
      );
    },
  );
}
