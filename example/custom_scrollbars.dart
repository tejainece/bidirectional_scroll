import 'dart:math';

import 'package:bidirectional_scroll/bidirectional_scroll.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

const double scrollbarWidth = 8;
final controller = ScrollerController(
    marginBottom: scrollbarWidth, marginRight: scrollbarWidth);
Widget trackDecoration(
        ScrollController controller, double width, double height) =>
    Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: const Color.fromRGBO(215, 215, 215, 1),
            border: Border.all(color: Colors.black54),
            borderRadius: BorderRadius.circular(scrollbarWidth / 2)));

Widget vThumbMaker(
        ScrollerController controller, double trackWidth, double thumbLength) =>
    Container(
      width: trackWidth * 0.5,
      height: thumbLength - 6,
      margin: EdgeInsets.symmetric(horizontal: trackWidth * 0.25, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(trackWidth),
        color: Colors.black,
      ),
    );
Widget hThumbMaker(
    ScrollerController controller, double trackWidth, double thumbLength) {
  return Container(
    width: thumbLength - 6,
    height: trackWidth * 0.5,
    margin: EdgeInsets.symmetric(horizontal: 2, vertical: trackWidth * 0.25),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(trackWidth),
      color: Colors.black,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scroller basic',
      home: Scaffold(
        body: ScrollViewport(
          child: const ContentWidget(),
          controller: controller,
          children: [
            (c) => ScrollerCanvas(controller: c),
            (c) => VerticalScrollbar(controller,
                width: scrollbarWidth,
                track: trackDecoration,
                thumb: vThumbMaker),
            (c) => HorizontalScrollbar(controller,
                height: scrollbarWidth,
                marginRight: scrollbarWidth,
                track: trackDecoration,
                thumb: hThumbMaker),
          ],
        ),
      ),
    );
  }
}

class ContentWidget extends StatelessWidget {
  const ContentWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final random = Random(4);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        ...List.generate(
          10,
          (r) => Row(
            mainAxisSize: MainAxisSize.max,
            children: List.generate(
              10,
              (c) => Container(
                  width: 200,
                  height: 100,
                  color: colors[random.nextInt(colors.length)]),
            ),
          ),
        ),
      ],
    );
  }
}

final colors = [
  Colors.red,
  Colors.green,
  Colors.grey,
  Colors.orange,
  Colors.brown,
  Colors.cyan,
  Colors.indigo
];
