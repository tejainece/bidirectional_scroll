import 'dart:math';

import 'package:bidirectional_scroll/bidirectional_scroll.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

final controller = ScrollerController(marginBottom: 25, marginRight: 25);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scroller basic',
      home: Scaffold(
        body: ScrollViewport.basic(
            controller: controller, child: const ContentWidget()),
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
