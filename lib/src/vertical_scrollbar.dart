import 'package:bidirectional_scroll/bidirectional_scroll.dart';
import 'package:flutter/material.dart';

class VerticalScrollbar extends StatelessWidget {
  final ScrollerController controller;
  final double width;
  const VerticalScrollbar(this.controller, {this.width = 25, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO hide scrollbar if not necessary
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
                  top: _getTop(controller),
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
  if(controller.contentSize.height == 0) return controller.viewportSize.height;
  // TODO minimum height
  return (controller.viewportSize.height * controller.viewportSize.height) /
      controller.contentSize.height;
}

double _getTop(ScrollerController controller) {
  if(controller.contentSize.height == 0) return controller.viewportSize.height;
  return (-controller.position.dy * controller.viewportSize.height) /
      controller.contentSize.height;
}
