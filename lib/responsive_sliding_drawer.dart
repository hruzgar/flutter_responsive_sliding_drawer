import 'package:flutter/material.dart';

class SlidingDrawerController {
  _SlidingDrawerState? _state;
  void open() => _state?._openDrawer();
  void close() => _state?._closeDrawer();
  void toggle() => _state?._toggleDrawer();
}

class SlidingDrawer extends StatefulWidget {
  final Widget drawer;
  final Widget body;
  final Duration animationDuration;
  final double openRatio;
  final double desktopOpenRatio;
  final double desktopMinDrawerWidth;
  final double desktopMaxDrawerWidth;
  final double swipeVelocityThreshold;
  final double dragPercentageThreshold;
  final void Function(bool isOpen)? onAnimationComplete;
  final double dividerWidth;
  final bool centerDivider;
  final SlidingDrawerController? controller;
  final double desktopDragAreaWidth;

  final Color scrimColor;

  final double scrimColorOpacity;

  final double scrimGradientStartOpacity;

  final double scrimGradientWidth;

  const SlidingDrawer({
    Key? key,
    required this.drawer,
    required this.body,
    this.animationDuration = const Duration(milliseconds: 60),
    this.openRatio = 0.80,
    this.desktopOpenRatio = 0.3,
    this.desktopMinDrawerWidth = 150.0,
    this.desktopMaxDrawerWidth = 400.0,
    this.swipeVelocityThreshold = 500.0,
    this.dragPercentageThreshold = 0.5,
    this.onAnimationComplete,
    this.dividerWidth = 5.0,
    this.centerDivider = true,
    this.controller,
    this.desktopDragAreaWidth = 10.0,
    this.scrimColor = Colors.black,
    this.scrimColorOpacity = 0.5, // (0.0 to 1.0)
    this.scrimGradientStartOpacity =
        0.10, // Opacity at the left edge of the gradient (0.0 to 1.0)
    this.scrimGradientWidth = 6.0, // Width of the left-edge gradient
  }) : super(key: key);

  @override
  _SlidingDrawerState createState() => _SlidingDrawerState();
}

class _SlidingDrawerState extends State<SlidingDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double? _desktopDrawerWidth;
  double _resizeOvershoot = 0.0;
  bool _isHoveringDivider = false;
  bool _isResizing = false;

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
    widget.controller?._state = this;
  }

  @override
  void didUpdateWidget(covariant SlidingDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
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

  void _toggleDrawer() {
    if (_controller.value >= 0.99) {
      _closeDrawer();
    } else {
      _openDrawer();
    }
  }

  void _openDrawer() {
    _controller.animateTo(1.0, duration: widget.animationDuration);
  }

  void _closeDrawer() {
    _controller.animateTo(0.0, duration: widget.animationDuration);
  }

  double get _currentDrawerWidth {
    final screenWidth = MediaQuery.of(context).size.width;
    return isDesktop
        ? (_desktopDrawerWidth ?? (widget.desktopOpenRatio * screenWidth))
        : widget.openRatio * screenWidth;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_isResizing) return;
    final effectiveWidth = _currentDrawerWidth;
    double delta = details.primaryDelta! / effectiveWidth;
    _controller.value += delta;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_isResizing) return;
    final velocity = details.velocity.pixelsPerSecond.dx;
    if (velocity.abs() >= widget.swipeVelocityThreshold) {
      velocity > 0 ? _openDrawer() : _closeDrawer();
    } else {
      _controller.value >= widget.dragPercentageThreshold
          ? _openDrawer()
          : _closeDrawer();
    }
  }

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
    final bool drawerOpen = _controller.value >= 0.99;

    if (isDesktop) {
      return Stack(
        children: [
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
          // Desktop drag area defined by parameter.
          Positioned(
            left: _controller.value < 0.5 ? 0 : drawerWidth,
            top: 0,
            bottom: 0,
            width: widget.desktopDragAreaWidth,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: _handleDragUpdate,
              onHorizontalDragEnd: _handleDragEnd,
            ),
          ),
          if (drawerOpen)
            Positioned(
              left:
                  widget.centerDivider
                      ? drawerWidth - widget.dividerWidth / 2
                      : drawerWidth,
              top: 0,
              bottom: 0,
              width: widget.dividerWidth,
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
      return Stack(
        children: [
          // Main window with swipe-open enabled.
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
          // Scrim overlay with uniform darkening and a left-edge gradient for the hovering effect.
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final dx = drawerWidth * _controller.value;
              return Transform.translate(
                offset: Offset(dx, 0),
                child: IgnorePointer(
                  ignoring: _controller.value == 0,
                  child: GestureDetector(
                    onTap: () {
                      if (drawerOpen) _toggleDrawer();
                    },
                    onHorizontalDragUpdate: _handleDragUpdate,
                    onHorizontalDragEnd: _handleDragEnd,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        color: widget.scrimColor.withOpacity(
                          widget.scrimColorOpacity * _controller.value,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Left-edge gradient for hovering effect.
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            width: widget.scrimGradientWidth,
                            child: IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      widget.scrimColor.withOpacity(
                                        widget.scrimGradientStartOpacity *
                                            _controller.value,
                                      ),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Drawer sliding in from the left.
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
        ],
      );
    }
  }

  @override
  void dispose() {
    widget.controller?._state = null;
    _controller.dispose();
    super.dispose();
  }
}
