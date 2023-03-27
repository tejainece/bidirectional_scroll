import 'package:bidirectional_scroll/bidirectional_scroll.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

final controller = ScrollerController();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        body: ScrollViewport(
          Column(
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
                        color: colors[(r + c) % colors.length]),
                  ),
                ),
              ),
            ],
          ),
          controller: controller,
          children: [
            DesktopScrollWatcher(controller: controller),
          ],
        ),
      ),
    );
  }
}

final colors = [
  Colors.red,
  Colors.green,
  Colors.grey,
  Colors.orange,
  Colors.brown,
  Colors.cyan
];
