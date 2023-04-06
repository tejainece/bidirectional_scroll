import 'dart:math';

import 'package:bidirectional_scroll/bidirectional_scroll.dart';
import 'package:flutter/material.dart';

class HorizontalScrollbar extends StatelessWidget {
  final ScrollerController controller;
  final double height;
  final Decoration? trackDecoration;
  final double marginLeft;
  final double marginRight;
  final double? offsetTop;
  final double? offsetBottom;
  const HorizontalScrollbar(this.controller,
      {this.trackDecoration,
      this.height = 25,
      this.marginLeft = 0,
      this.marginRight = 0,
      this.offsetTop,
      this.offsetBottom = 0,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO hide scrollbar if not necessary
    return Positioned(
      top: offsetTop,
      bottom: offsetBottom,
      left: marginLeft,
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Container(
            width: trackLength,
            height: height,
            decoration: trackDecoration,
            child: Stack(
              children: [
                // TODO cursor
                Positioned(
                  left: _getThumbLeft(),
                  child: Container(
                    width: _getThumbWidth(),
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

  double get trackLength =>
      max(controller.viewportSize.height - marginLeft - marginRight, 0);

  double get trackProportion => trackLength / controller.viewportSize.width;

  double _getThumbWidth() {
    if (controller.contentSize.width == 0) return trackLength;
    // TODO minimum height
    return controller.viewportSize.width *
        controller.widthProportion *
        trackProportion;
  }

  double _getThumbLeft() {
    if (controller.contentSize.width == 0) return trackLength;
    return -controller.position.dx *
        controller.widthProportion *
        trackProportion;
  }
}
