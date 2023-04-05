import 'dart:math';

import 'package:bidirectional_scroll/bidirectional_scroll.dart';
import 'package:flutter/material.dart';

class VerticalScrollbar extends StatelessWidget {
  final ScrollerController controller;
  final double width;
  final double marginTop;
  final double marginBottom;
  final double? offsetRight;
  final double? offsetLeft;
  final Decoration? trackDecoration;
  const VerticalScrollbar(this.controller,
      {this.width = 25,
      this.marginTop = 0,
      this.marginBottom = 0,
      this.offsetLeft,
      this.offsetRight = 0,
      this.trackDecoration,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO hide scrollbar if not necessary
    return Positioned(
      top: marginTop,
      left: offsetLeft,
      right: offsetRight,
      child: StreamBuilder(
        builder: (context, snapshot) {
          print('redrawing vertical scrollbar');
          return Container(
            width: width,
            height: trackLength,
            decoration: trackDecoration,
            child: Stack(
              children: [
                // TODO cursor
                Positioned(
                  top: _getThumbTop(),
                  child: Container(
                    width: width,
                    height: _getThumbHeight(),
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

  double get trackLength =>
      max(controller.viewportSize.height - marginTop - marginBottom, 0);

  double _getThumbHeight() {
    if (controller.contentSize.height == 0) return trackLength;
    // TODO minimum height
    return (trackLength * trackLength) / controller.contentSize.height;
  }

  double _getThumbTop() {
    if (controller.contentSize.height == 0) return trackLength;
    return (-controller.position.dy * controller.viewportSize.height) /
        controller.contentSize.height;
  }
}
