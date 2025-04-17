import 'package:flutter/material.dart';

blankListData(BuildContext context, {double height = 100}) {
  return Container(
    color: Colors.transparent,
    alignment: Alignment.center,
    padding: EdgeInsets.only(left: 10.0, right: 10.0),
    child: ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 5.0),
          child: BlankLoading(height: height),
        );
      },
    ),
  );
}

class BlankLoading extends StatefulWidget {
  BlankLoading({Key? key, this.width, this.height}) : super(key: key);

  final double? width;
  final double? height;

  @override
  _BlankLoading createState() => _BlankLoading();
}

class _BlankLoading extends State<BlankLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
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
        end: Colors.black.withAlpha(80),
      ),
    ),
    TweenSequenceItem(
      weight: 2.0,
      tween: ColorTween(
        begin: Colors.black.withAlpha(80),
        end: Colors.black.withAlpha(20),
      ),
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            alignment: Alignment.topCenter,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
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

blankGridData(BuildContext context, {double height = 100}) {
  return Container(
    color: Colors.transparent,
    alignment: Alignment.center,
    padding: EdgeInsets.only(left: 10.0, right: 10.0),
    child: GridView.count(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      crossAxisCount: 2,
      children: new List<Widget>.generate(
        10,
        (index) {
          return Container(
            margin: index%2 == 0 ? EdgeInsets.only(top: 5.0,bottom: 5.0,right: 5.0) :  EdgeInsets.only(top: 5.0,bottom: 5.0,left: 5.0),
            child: BlankLoading(height: height),
          );
        },
      ),
    ),
  );
}
