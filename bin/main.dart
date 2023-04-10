import 'dart:math';

import 'package:bidirectional_scroll/bidirectional_scroll.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

const double scrollbarWidth = 8;
final controller = ScrollerController(
    marginBottom: scrollbarWidth, marginRight: scrollbarWidth);
final trackDecoration = BoxDecoration(
    color: const Color.fromRGBO(215, 215, 215, 1),
    border: Border.all(color: Colors.black54),
    borderRadius: BorderRadius.circular(scrollbarWidth / 2));
final vThumbMaker =
    (ScrollerController controller, double trackWidth, double thumbLength) {
  return Container(
    width: trackWidth * 0.5,
    height: thumbLength - 6,
    margin: EdgeInsets.symmetric(horizontal: trackWidth * 0.1, vertical: 2),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(trackWidth),
      color: Colors.black,
    ),
  );
};
final hThumbMaker =
    (ScrollerController controller, double trackWidth, double thumbLength) {
  print('${trackWidth * 0.5 - 4}');
  return Container(
    width: thumbLength - 6,
    height: trackWidth * 0.5,
    margin: EdgeInsets.symmetric(horizontal: 2, vertical: trackWidth * 0.1),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(trackWidth),
      color: Colors.black,
    ),
  );
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        body: ScrollViewport(
          const ContentWidget(),
          controller: controller,
          children: [
            ScrollerCanvas(controller: controller),
            VerticalScrollbar(controller,
                width: scrollbarWidth,
                trackDecoration: trackDecoration,
                thumb: vThumbMaker),
            HorizontalScrollbar(controller,
                height: scrollbarWidth,
                marginRight: scrollbarWidth,
                trackDecoration: trackDecoration,
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
          5,
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
