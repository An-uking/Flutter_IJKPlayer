part of flutter_ijkplayer;

class PiliPlayerProgressBar extends StatefulWidget {
  final PiliPlayerController controller;
  final PiliPlayerProgressColors colors;
  final Function() onDragStart;
  final Function() onDragEnd;
  final Function() onDragUpdate;

  PiliPlayerProgressBar(
    this.controller, {
    PiliPlayerProgressColors colors,
    this.onDragEnd,
    this.onDragStart,
    this.onDragUpdate,
  }) : colors = colors ?? new PiliPlayerProgressColors();

  @override
  _VideoProgressBarState createState() {
    return new _VideoProgressBarState();
  }
}

class _VideoProgressBarState extends State<PiliPlayerProgressBar> {
  VoidCallback listener;

  bool _controllerWasPlaying = false;
  Offset _dragOffset;

  _VideoProgressBarState() {
    listener = () {
      setState(() {});
    };
  }

  PiliPlayerController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final RenderBox box = context.findRenderObject();
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = controller.value.duration * relative;
      print("position.inMilliseconds:"+position.inMilliseconds.toString());
      controller.seekTo(position.inMilliseconds);
    }

    return new GestureDetector(
      child: Center(
              child: new Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent,
                child: new CustomPaint(
                  painter: new _ProgressBarPainter(
                    controller.value,
                    widget.colors,
                  ),
                ),
              ),
            ),
      // onHorizontalDragStart: (DragStartDetails details) {
      //   if (!controller.value.initialize) {
      //     return;
      //   }
        
      //   _controllerWasPlaying = controller.value.isPlaying;
      //   if (_controllerWasPlaying) {
      //     controller.pause();
      //   }

      //   if (widget.onDragStart != null) {
      //     widget.onDragStart();
      //   }
      // },
      // onHorizontalDragUpdate: (DragUpdateDetails details) {
      //   if (!controller.value.initialize) {
      //     return;
      //   }

      //   _dragOffset=details.globalPosition;

      //   if (widget.onDragUpdate != null) {
      //     widget.onDragUpdate();
      //   }
      // },
      // onHorizontalDragEnd: (DragEndDetails details) {
      //   if(_dragOffset!=null){
      //     seekToRelativePosition(_dragOffset);
      //   }
        
      //   if (_controllerWasPlaying) {
      //     controller.play();
      //   }

      //   if (widget.onDragEnd != null) {

      //     widget.onDragEnd();
      //   }
      //   _dragOffset=null;
      // },
      onTapDown: (TapDownDetails details) {
        if (!controller.value.initialize) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  PiliPlayerValue value;
  PiliPlayerProgressColors colors;

  _ProgressBarPainter(this.value, this.colors);

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final height = 2.0;

    canvas.drawRRect(
      new RRect.fromRectAndRadius(
        new Rect.fromPoints(
          new Offset(0.0, size.height / 2),
          new Offset(size.width, size.height / 2 + height),
        ),
        new Radius.circular(4.0),
      ),
      colors.backgroundPaint,
    );
    if (!value.initialize||value.isLive||value.hasError) {
      return;
    }
    final double playedPart = value.position.inMilliseconds /value.duration.inMilliseconds * size.width;
    final double bufferdPart = value.bufferedPrecent/100 * size.width;
    canvas.drawRRect(
      new RRect.fromRectAndRadius(
        new Rect.fromPoints(
          new Offset(0.0, size.height / 2),
          new Offset(bufferdPart, size.height / 2 + height),
        ),
        new Radius.circular(4.0),
      ),
      colors.bufferedPaint,
    );
    canvas.drawRRect(
      new RRect.fromRectAndRadius(
        new Rect.fromPoints(
          new Offset(0.0, size.height / 2),
          new Offset(playedPart, size.height / 2 + height),
        ),
        new Radius.circular(4.0),
      ),
      colors.playedPaint,
    );
    canvas.drawCircle(
      new Offset(playedPart, size.height / 2 + height / 2),
      height * 3,
      colors.handlePaint,
    );
  }
}
