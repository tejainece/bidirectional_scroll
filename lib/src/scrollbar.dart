import 'dart:async';
import 'dart:math';

import 'package:bidirectional_scroll/bidirectional_scroll.dart';
import 'package:flutter/material.dart';

typedef TrackMaker = Widget Function(
    ScrollerController controller, double width, double height);

typedef ThumbMaker = Widget Function(
    ScrollerController controller, double trackWidth, double thumbLength);

class VerticalScrollbar extends StatefulWidget {
  final ScrollerController controller;
  final double width;
  final double marginTop;
  final double marginBottom;
  final double? offsetRight;
  final double? offsetLeft;
  final dynamic /* Widget | TrackMaker */ track;
  final dynamic /* Widget | ThumbMaker */ thumb;
  final bool autoHide;
  const VerticalScrollbar(this.controller,
      {this.width = 25,
      this.marginTop = 0,
      this.marginBottom = 0,
      this.offsetLeft,
      this.offsetRight = 0,
      this.track = defaultTrackMaker,
      this.thumb,
      this.autoHide = false,
      Key? key})
      : super(key: key);

  @override
  State<VerticalScrollbar> createState() => _VerticalScrollbarState();
}

class _VerticalScrollbarState extends State<VerticalScrollbar> {
  ScrollerController get controller => widget.controller;
  double get width => widget.width;
  double get marginTop => widget.marginTop;
  double get marginBottom => widget.marginBottom;
  double? get offsetRight => widget.offsetRight;
  double? get offsetLeft => widget.offsetLeft;

  _PanTracker? _panTracker;
  int _pointer = -1;

  bool _show = true;
  Timer? _timer;
  late final StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _sub = controller.stream.listen((event) {
      _timer?.cancel();
      setState(() {
        _show = true;
      });
      if (widget.autoHide) {
        _timer = Timer(const Duration(seconds: 5), () {
          if (widget.autoHide) {
            setState(() {
              _show = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: marginTop,
      left: offsetLeft,
      right: offsetRight,
      child: StreamBuilder(
        builder: (context, snapshot) {
          if (!_show) return Container();
          return Stack(
            children: [
              Listener(
                behavior: HitTestBehavior.opaque,
                onPointerUp: (event) {
                  if (_pointer == event.pointer) return;
                  _jumpTo(event.localPosition.dy);
                },
                child: makeTrack(),
              ),
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
                        anchor: controller.position, start: event.position.dy);
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
                  child: makeThumb(),
                ),
              )
            ],
          );
        },
        stream: controller.stream,
      ),
    );
  }

  Widget makeTrack() => widget.track is TrackMaker
      ? widget.track(controller, width, trackLength)
      : SizedBox(width: width, height: trackLength, child: widget.track);

  Widget makeThumb() => widget.thumb == null
      ? Container(
          width: width,
          height: _getThumbHeight(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.black,
          ),
        )
      : widget.thumb is ThumbMaker
          ? widget.thumb(controller, width, _getThumbHeight())
          : widget.thumb;

  void _jumpTo(double value) {
    if (value > _getThumbTop()) {
      value -= _getThumbHeight();
    }
    controller.animateTo(Offset(controller.position.dx,
        -value * controller.contentSize.height / trackLength));
  }

  double get trackLength =>
      max(controller.viewportOriginalSize.height - marginTop - marginBottom, 0);

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
  final double marginLeft;
  final double marginRight;
  final double? offsetTop;
  final double? offsetBottom;
  final dynamic /* Widget | TrackMaker */ track;
  final dynamic /* Widget | ThumbMaker */ thumb;
  final bool autoHide;

  const HorizontalScrollbar(this.controller,
      {this.height = 25,
      this.marginLeft = 0,
      this.marginRight = 25,
      this.offsetTop,
      this.offsetBottom = 0,
      this.track = defaultTrackMaker,
      this.thumb,
      this.autoHide = false,
      Key? key})
      : super(key: key);

  @override
  State<HorizontalScrollbar> createState() => _HorizontalScrollbarState();
}

class _HorizontalScrollbarState extends State<HorizontalScrollbar> {
  ScrollerController get controller => widget.controller;
  double get height => widget.height;
  double get marginLeft => widget.marginLeft;
  double get marginRight => widget.marginRight;
  double? get offsetTop => widget.offsetTop;
  double? get offsetBottom => widget.offsetBottom;

  _PanTracker? _panTracker;
  int _pointer = -1;

  bool _show = true;
  Timer? _timer;
  late final StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _sub = controller.stream.listen((event) {
      _timer?.cancel();
      setState(() {
        _show = true;
      });
      if (widget.autoHide) {
        _timer = Timer(const Duration(seconds: 5), () {
          if (widget.autoHide) {
            setState(() {
              _show = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: offsetTop,
      bottom: offsetBottom,
      left: marginLeft,
      child: StreamBuilder(
        builder: (context, snapshot) {
          if (!_show) return Container();
          return Stack(
            children: [
              Listener(
                behavior: HitTestBehavior.opaque,
                onPointerUp: (event) {
                  if (_pointer == event.pointer) return;
                  _jumpTo(event.localPosition.dx);
                },
                child: makeTrack(),
              ),
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
                        anchor: controller.position, start: event.position.dx);
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
                  child: makeThumb(),
                ),
              )
            ],
          );
        },
        stream: controller.stream,
      ),
    );
  }

  Widget makeTrack() => widget.track is TrackMaker
      ? widget.track(controller, trackLength, height)
      : SizedBox(width: trackLength, height: height, child: widget.track);

  Widget makeThumb() => widget.thumb == null
      ? Container(
          width: _getThumbWidth(),
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.black,
          ),
        )
      : widget.thumb is ThumbMaker
          ? widget.thumb(controller, height, _getThumbWidth())
          : widget.thumb;

  void _jumpTo(double value) {
    if (value > _getThumbLeft()) {
      value -= _getThumbWidth();
    }
    controller.animateTo(Offset(
        -value * controller.contentSize.width / trackLength,
        controller.position.dy));
  }

  double get trackLength =>
      max(controller.viewportOriginalSize.width - marginLeft - marginRight, 0);

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

Container defaultTrackMaker(
        ScrollerController controller, double width, double height) =>
    Container(
        width: width,
        height: height,
        decoration:
            const BoxDecoration(color: Color.fromRGBO(220, 220, 220, 1)));
