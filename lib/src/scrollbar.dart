import 'dart:math';

import 'package:bidirectional_scroll/bidirectional_scroll.dart';
import 'package:flutter/material.dart';

class VerticalScrollbar extends StatefulWidget {
  final ScrollerController controller;
  final double width;
  final Decoration? trackDecoration;
  final double marginTop;
  final double marginBottom;
  final double? offsetRight;
  final double? offsetLeft;
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
  State<VerticalScrollbar> createState() => _VerticalScrollbarState();
}

class _VerticalScrollbarState extends State<VerticalScrollbar> {
  ScrollerController get controller => widget.controller;
  double get width => widget.width;
  Decoration? get trackDecoration => widget.trackDecoration;
  double get marginTop => widget.marginTop;
  double get marginBottom => widget.marginBottom;
  double? get offsetRight => widget.offsetRight;
  double? get offsetLeft => widget.offsetLeft;

  _PanTracker? _panTracker;
  int _pointer = -1;

  @override
  Widget build(BuildContext context) {
    // TODO hide scrollbar if not necessary
    return Positioned(
      top: marginTop,
      left: offsetLeft,
      right: offsetRight,
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Listener(
            behavior: HitTestBehavior.opaque,
            onPointerUp: (event) {
              if (_pointer == event.pointer) return;
              _jumpTo(event.localPosition.dy);
            },
            child: Container(
              width: width,
              height: trackLength,
              decoration: trackDecoration,
              child: Stack(
                children: [
                  // TODO cursor
                  Positioned(
                    top: _getThumbTop(),
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (event) {
                        _pointer = event.pointer;
                        if (event.buttons == 0) {
                          // TODO
                          return;
                        }
                        _panTracker = _PanTracker(
                            anchor: controller.position,
                            start: event.position.dy);
                      },
                      onPointerMove: (event) {
                        _pointer = event.pointer;
                        if (event.buttons == 0 || _panTracker == null) return;
                        controller.jumpTo(_panTracker!.anchor -
                            Offset(0, event.position.dy - _panTracker!.start));
                      },
                      onPointerCancel: (event) {
                        _pointer = event.pointer;
                        _panTracker = null;
                      },
                      onPointerUp: (event) {
                        _pointer = event.pointer;
                        _panTracker = null;
                      },
                      child: Container(
                        width: width,
                        height: _getThumbHeight(),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(width / 2),
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
        stream: controller.stream,
      ),
    );
  }

  void _jumpTo(double value) {
    if (value > _getThumbTop()) {
      value -= _getThumbHeight();
    }
    controller.animateTo(Offset(controller.position.dx,
        -value * controller.contentSize.height / trackLength));
  }

  double get trackLength =>
      max(controller.viewportSize.height - marginTop - marginBottom, 0);

  double get trackProportion => trackLength / controller.viewportSize.height;

  double _getThumbHeight() {
    if (controller.contentSize.height == 0) return trackLength;
    // TODO minimum height
    return controller.viewportSize.height *
        controller.heightProportion *
        trackProportion;
  }

  double _getThumbTop() {
    if (controller.contentSize.height == 0) return trackLength;
    return -controller.position.dy *
        controller.heightProportion *
        trackProportion;
  }
}

class HorizontalScrollbar extends StatefulWidget {
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
  State<HorizontalScrollbar> createState() => _HorizontalScrollbarState();
}

class _HorizontalScrollbarState extends State<HorizontalScrollbar> {
  ScrollerController get controller => widget.controller;
  double get height => widget.height;
  Decoration? get trackDecoration => widget.trackDecoration;
  double get marginLeft => widget.marginLeft;
  double get marginRight => widget.marginRight;
  double? get offsetTop => widget.offsetTop;
  double? get offsetBottom => widget.offsetBottom;

  _PanTracker? _panTracker;
  int _pointer = -1;

  @override
  Widget build(BuildContext context) {
    // TODO hide scrollbar if not necessary
    return Positioned(
      top: offsetTop,
      bottom: offsetBottom,
      left: marginLeft,
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Listener(
            behavior: HitTestBehavior.opaque,
            onPointerUp: (event) {
              if (_pointer == event.pointer) return;
              _jumpTo(event.localPosition.dx);
            },
            child: Container(
              width: trackLength,
              height: height,
              decoration: trackDecoration,
              child: Stack(
                children: [
                  // TODO cursor
                  Positioned(
                    left: _getThumbLeft(),
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (event) {
                        _pointer = event.pointer;
                        if (event.buttons == 0) {
                          // TODO
                          return;
                        }
                        _panTracker = _PanTracker(
                            anchor: controller.position,
                            start: event.position.dx);
                      },
                      onPointerMove: (event) {
                        _pointer = event.pointer;
                        if (event.buttons == 0 || _panTracker == null) return;
                        controller.jumpTo(_panTracker!.anchor -
                            Offset(event.position.dx - _panTracker!.start, 0));
                      },
                      onPointerCancel: (event) {
                        _pointer = event.pointer;
                        _panTracker = null;
                      },
                      onPointerUp: (event) {
                        _pointer = event.pointer;
                        _panTracker = null;
                      },
                      child: Container(
                        width: _getThumbWidth(),
                        height: height,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(height / 2),
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
        stream: controller.stream,
      ),
    );
  }

  void _jumpTo(double value) {
    if (value > _getThumbLeft()) {
      value -= _getThumbWidth();
    }
    controller.animateTo(Offset(
        -value * controller.contentSize.width / trackLength,
        controller.position.dy));
  }

  double get trackLength =>
      max(controller.viewportSize.width - marginLeft - marginRight, 0);

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

class _PanTracker {
  final Offset anchor;
  final double start;

  _PanTracker({required this.anchor, required this.start});
}
