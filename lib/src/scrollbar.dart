import 'package:bidirectional_scroll/bidirectional_scroll.dart';
import 'package:flutter/material.dart';

class VerticalScrollbar extends StatelessWidget {
  final ScrollerController controller;
  final double width;
  const VerticalScrollbar(this.controller, {this.width = 25, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Container(
            width: width,
            height: controller.viewportSize.height,
            child: Stack(
              children: [
                // TODO cursor
                Positioned(
                  child: Container(
                    width: width,
                    height: _getHeight(controller),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width / 2),
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          );
        },
        stream: controller.stream,
      ),
    );
  }
}

double _getHeight(ScrollerController controller) {
  return (controller.viewportSize.height * controller.viewportSize.height) /
      controller.contentSize.height;
}
