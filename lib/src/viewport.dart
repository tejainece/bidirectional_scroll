import 'package:bidirectional_scroll/src/controller.dart';
import 'package:bidirectional_scroll/src/measure_size.dart';
import 'package:flutter/material.dart';

class ScrollViewport extends StatefulWidget {
  final List<Widget> children;

  final Widget child;

  final ScrollerController controller;

  const ScrollViewport(this.child,
      {Key? key, required this.controller, this.children = const []})
      : super(key: key);

  @override
  State<ScrollViewport> createState() => _ScrollViewportState();
}

class _ScrollViewportState extends State<ScrollViewport> {
  late final ScrollerController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    controller.stream.listen((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraint) {
      print('viewport resize');
      controller.viewportSize = Size(constraint.maxWidth, constraint.maxHeight);
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topLeft,
        children: [
          StreamBuilder(
            builder: (ctx, _) => Positioned(
              left: controller.position.dx,
              top: controller.position.dy,
              child: Transform.scale(
                scale: controller.scale,
                alignment: Alignment.topLeft,
                child: MeasureSize(
                    onChange: (value) {
                      controller.contentOriginalSize = value;
                    },
                    child: widget.child),
              ),
            ),
          ),
          ...widget.children,
        ],
      );
    });
  }
}
