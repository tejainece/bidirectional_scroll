import 'package:bidirectional_scroll/bidirectional_scroll.dart';
import 'package:flutter/material.dart';

class HorizontalScrollbar extends StatelessWidget {
  final ScrollerController controller;
  final double height;
  final Decoration? trackDecoration;
  const HorizontalScrollbar(this.controller,
      {this.trackDecoration, this.height = 25, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO hide scrollbar if not necessary
    return Positioned(
      bottom: 0,
      left: 0,
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Container(
            width: controller.viewportSize.width,
            height: height,
            decoration: trackDecoration,
            child: Stack(
              children: [
                // TODO cursor
                Positioned(
                  left: _getThumbLeft(controller),
                  child: Container(
                    width: _getThumbWidth(controller),
                    height: height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(height / 2),
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

double _getThumbWidth(ScrollerController controller) {
  if(controller.contentSize.width == 0) return controller.viewportSize.width;
  // TODO minimum width
  return (controller.viewportSize.width * controller.viewportSize.width) /
      controller.contentSize.width;
}

double _getThumbLeft(ScrollerController controller) {
  if(controller.contentSize.width == 0) return controller.viewportSize.width;
  return (-controller.position.dx * controller.viewportSize.width) /
      controller.contentSize.width;
}
