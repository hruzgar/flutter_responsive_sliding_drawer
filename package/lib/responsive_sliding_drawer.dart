import 'package:flutter/material.dart';

class SlidingDrawer extends StatefulWidget {
  final Widget drawer;
  final Widget body;
  final Duration animationDuration;

  /// Fraction of the screen width that the drawer covers when fully open on phones.
  final double openRatio;

  /// Fraction of the screen width that the drawer covers when fully open on desktops.
  final double desktopOpenRatio;

  /// Minimum drawer width on desktop (in pixels).
  final double desktopMinDrawerWidth;

  /// Maximum drawer width on desktop (in pixels).
  final double desktopMaxDrawerWidth;

  /// Swipe velocity threshold in pixels per second.
  final double swipeVelocityThreshold;

  /// Drag percentage threshold to complete open/close when swipe velocity is low.
  final double dragPercentageThreshold;

  /// Callback that gets triggered when the drawer animation finishes.
  /// [isOpen] is true when the drawer finishes opening and false when it finishes closing.
  final void Function(bool isOpen)? onAnimationComplete;

  const SlidingDrawer({
    Key? key,
    required this.drawer,
    required this.body,
    this.animationDuration = const Duration(milliseconds: 60),
    this.openRatio = 0.75,
    this.desktopOpenRatio = 0.3,
    this.desktopMinDrawerWidth = 150.0,
    this.desktopMaxDrawerWidth = 400.0,
    this.swipeVelocityThreshold = 500.0,
    this.dragPercentageThreshold = 0.5,
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  _SlidingDrawerState createState() => _SlidingDrawerState();
}

class _SlidingDrawerState extends State<SlidingDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double? _desktopDrawerWidth;

  /// Accumulates extra drag that exceeds the limits.
  double _resizeOvershoot = 0.0;

  /// Tracks whether the mouse is hovering over the divider.
  bool _isHoveringDivider = false;

  /// Indicates that the divider is being dragged.
  bool _isResizing = false;

  // Consider devices with width >= 600 as desktop.
  bool get isDesktop => MediaQuery.of(context).size.width >= 600;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _controller.addListener(() => setState(() {}));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call(true);
      } else if (status == AnimationStatus.dismissed) {
        widget.onAnimationComplete?.call(false);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isDesktop) {
      final screenWidth = MediaQuery.of(context).size.width;
      _desktopDrawerWidth ??= widget.desktopOpenRatio * screenWidth;
      _desktopDrawerWidth = _desktopDrawerWidth!.clamp(
        widget.desktopMinDrawerWidth,
        widget.desktopMaxDrawerWidth,
      );
    }
  }

  /// Toggles the drawer open/closed.
  void _toggleDrawer() {
    if (_controller.value >= 0.99) {
      _controller.animateTo(0.0, duration: widget.animationDuration);
    } else {
      _controller.animateTo(1.0, duration: widget.animationDuration);
    }
  }

  /// Returns the drawer width.
  double get _currentDrawerWidth {
    final screenWidth = MediaQuery.of(context).size.width;
    return isDesktop
        ? (_desktopDrawerWidth ?? (widget.desktopOpenRatio * screenWidth))
        : widget.openRatio * screenWidth;
  }

  /// Common drag update handler.
  void _handleDragUpdate(DragUpdateDetails details) {
    if (_isResizing) return;
    final effectiveWidth = _currentDrawerWidth;
    double delta = details.primaryDelta! / effectiveWidth;
    _controller.value += delta;
  }

  /// Common drag end handler.
  void _handleDragEnd(DragEndDetails details) {
    if (_isResizing) return;
    final velocity = details.velocity.pixelsPerSecond.dx;
    if (velocity.abs() >= widget.swipeVelocityThreshold) {
      if (velocity > 0) {
        _controller.animateTo(1.0, duration: widget.animationDuration);
      } else {
        _controller.animateTo(0.0, duration: widget.animationDuration);
      }
    } else {
      if (_controller.value >= widget.dragPercentageThreshold) {
        _controller.animateTo(1.0, duration: widget.animationDuration);
      } else {
        _controller.animateTo(0.0, duration: widget.animationDuration);
      }
    }
  }

  /// Handles divider drag for resizing.
  void _handleDividerPanUpdate(DragUpdateDetails details) {
    if (_controller.value < 0.99) return;
    double delta = details.delta.dx;
    double newWidth = _desktopDrawerWidth! + delta;
    if (_desktopDrawerWidth! >= widget.desktopMaxDrawerWidth && delta > 0) {
      _resizeOvershoot += delta;
    } else if (_desktopDrawerWidth! <= widget.desktopMinDrawerWidth &&
        delta < 0) {
      _resizeOvershoot += delta;
    } else {
      if (_resizeOvershoot != 0.0) {
        if ((_resizeOvershoot > 0 && delta < 0) ||
            (_resizeOvershoot < 0 && delta > 0)) {
          if (delta.abs() >= _resizeOvershoot.abs()) {
            double remaining = delta.abs() - _resizeOvershoot.abs();
            _resizeOvershoot = 0.0;
            _desktopDrawerWidth = (_desktopDrawerWidth! +
                    (delta > 0 ? remaining : -remaining))
                .clamp(
                  widget.desktopMinDrawerWidth,
                  widget.desktopMaxDrawerWidth,
                );
          } else {
            _resizeOvershoot += delta;
          }
        } else {
          _resizeOvershoot += delta;
        }
      } else {
        _desktopDrawerWidth = newWidth.clamp(
          widget.desktopMinDrawerWidth,
          widget.desktopMaxDrawerWidth,
        );
      }
    }
    _desktopDrawerWidth = _desktopDrawerWidth!.clamp(
      widget.desktopMinDrawerWidth,
      widget.desktopMaxDrawerWidth,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final drawerWidth = _currentDrawerWidth;
    // Consider the drawer open when _controller.value is nearly 1.
    final bool drawerOpen = _controller.value >= 0.99;

    if (isDesktop) {
      return Stack(
        children: [
          // The main body is positioned with a left offset that grows as the drawer opens.
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final leftOffset = drawerWidth * _controller.value;
              return Positioned(
                left: leftOffset,
                top: 0,
                right: 0,
                bottom: 0,
                child: widget.body,
              );
            },
          ),
          // The drawer slides in from the left.
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final dx = -drawerWidth * (1 - _controller.value);
              return Transform.translate(
                offset: Offset(dx, 0),
                child: Container(
                  width: drawerWidth,
                  height: MediaQuery.of(context).size.height,
                  child: widget.drawer,
                ),
              );
            },
          ),
          // Left-edge drag area (about 50 pixels wide).
          Positioned(
            left: _controller.value < 0.5 ? 0 : drawerWidth,
            top: 0,
            bottom: 0,
            width: 50,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: _handleDragUpdate,
              onHorizontalDragEnd: _handleDragEnd,
            ),
          ),
          // Draggable divider for resizing the drawer.
          if (drawerOpen)
            Positioned(
              top: 0,
              bottom: 0,
              left: drawerWidth - 10,
              width: 20,
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHoveringDivider = true),
                onExit: (_) => setState(() => _isHoveringDivider = false),
                cursor: SystemMouseCursors.resizeColumn,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity:
                      (_isHoveringDivider || _resizeOvershoot != 0.0)
                          ? 1.0
                          : 0.0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (_) {
                      setState(() {
                        _isResizing = true;
                        _resizeOvershoot = 0.0;
                      });
                    },
                    onPanUpdate: _handleDividerPanUpdate,
                    onPanEnd: (_) {
                      setState(() {
                        _isResizing = false;
                        _resizeOvershoot = 0.0;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: Container(
                        width: 4,
                        height: double.infinity,
                        color: const Color.fromARGB(255, 103, 103, 103),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    } else {
      // Mobile: Use the original sliding behavior.
      return Stack(
        children: [
          // Drawer layer.
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final dx = -drawerWidth * (1 - _controller.value);
              return Transform.translate(
                offset: Offset(dx, 0),
                child: GestureDetector(
                  onHorizontalDragUpdate: _handleDragUpdate,
                  onHorizontalDragEnd: _handleDragEnd,
                  child: Container(
                    width: drawerWidth,
                    height: MediaQuery.of(context).size.height,
                    child: widget.drawer,
                  ),
                ),
              );
            },
          ),
          // Body layer.
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final dx = drawerWidth * _controller.value;
              return Transform.translate(
                offset: Offset(dx, 0),
                child: GestureDetector(
                  onTap: () {
                    if (drawerOpen) _toggleDrawer();
                  },
                  onHorizontalDragUpdate: _handleDragUpdate,
                  onHorizontalDragEnd: _handleDragEnd,
                  child: widget.body,
                ),
              );
            },
          ),
          // Left-edge drag area for mobile.
          if (!isDesktop && _controller.value == 0.0)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 20,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: _handleDragUpdate,
                onHorizontalDragEnd: _handleDragEnd,
              ),
            ),
        ],
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
