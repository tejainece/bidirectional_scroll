import 'package:bidirectional_scroll/src/controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScrollerCanvas extends StatefulWidget {
  final ScrollerController controller;

  const ScrollerCanvas({required this.controller, Key? key}) : super(key: key);

  @override
  State<ScrollerCanvas> createState() => _ScrollerCanvasState();
}

class _ScrollerCanvasState extends State<ScrollerCanvas> {
  final _focusNode = FocusNode();

  bool _isShiftKeyPressed = false;
  bool _isControlKeyPressed = false;

  ScrollerController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (value) {
          _isShiftKeyPressed = value.isShiftPressed;
          _isControlKeyPressed = value.isControlPressed;

          if (value is RawKeyUpEvent) {
            return;
          }

          if (value.logicalKey == LogicalKeyboardKey.arrowUp) {
            controller.scrollUp();
          } else if (value.logicalKey == LogicalKeyboardKey.arrowDown) {
            controller.scrollDown();
          } else if (value.logicalKey == LogicalKeyboardKey.arrowLeft) {
            controller.scrollLeft();
          } else if (value.logicalKey == LogicalKeyboardKey.arrowRight) {
            controller.scrollRight();
          } else if (value.logicalKey == LogicalKeyboardKey.pageUp) {
            if (_isShiftKeyPressed) {
              controller.pageLeft();
            } else {
              controller.pageUp();
            }
          } else if (value.logicalKey == LogicalKeyboardKey.pageDown) {
            if (_isShiftKeyPressed) {
              controller.pageRight();
            } else {
              controller.pageDown();
            }
          } else if (value.logicalKey == LogicalKeyboardKey.home) {
            if (_isShiftKeyPressed) {
              controller.scrollBegin();
            } else {
              controller.scrollTop();
            }
          } else if (value.logicalKey == LogicalKeyboardKey.end) {
            if (_isShiftKeyPressed) {
              controller.scrollEnd();
            } else {
              controller.scrollBottom();
            }
          }
        },
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerPanZoomStart: (event) {
            _panTracker =
                _PanTracker(anchor: controller.position, start: event.position);
          },
          onPointerPanZoomUpdate: (event) {
            if (_panTracker != null) {
              controller.jumpTo(_panTracker!.anchor + event.localPan);
            }
          },
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              if (event.scrollDelta.dy.isNegative) {
                if (_isShiftKeyPressed) {
                  controller.scrollLeft();
                } else if (_isControlKeyPressed) {
                  controller.zoomIn();
                } else {
                  controller.scrollUp();
                }
              } else {
                if (_isShiftKeyPressed) {
                  controller.scrollRight();
                } else if (_isControlKeyPressed) {
                  controller.zoomOut();
                } else {
                  controller.scrollDown();
                }
              }
            }
          },
          onPointerDown: (event) {
            _focusNode.requestFocus();
            _panTracker =
                _PanTracker(anchor: controller.position, start: event.position);
          },
          onPointerMove: (event) {
            if (event.down && _panTracker != null) {
              controller.jumpTo(
                  _panTracker!.anchor + (event.position - _panTracker!.start));
            }
          },
          onPointerUp: (event) {
            _panTracker = null;
          },
        ),
      ),
    );
  }

  _PanTracker? _panTracker;
}

class _PanTracker {
  final Offset anchor;
  final Offset start;
  _PanTracker({required this.anchor, required this.start});
}
