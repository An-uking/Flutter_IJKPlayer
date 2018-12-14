part of flutter_ijkplayer;

class MaterialControls extends StatefulWidget {
  final PiliPlayerController controller;
  final bool fullScreen;
  final Future<dynamic> Function() onExpandCollapse;
  final PiliPlayerProgressColors progressColors;
  final bool autoPlay;
  final bool isLive;

  MaterialControls({
    @required this.controller,
    @required this.fullScreen,
    @required this.onExpandCollapse,
    @required this.progressColors,
    @required this.autoPlay,
    @required this.isLive,
  });

  @override
  State<StatefulWidget> createState() {
    return new _MaterialControlsState();
  }
}

class _MaterialControlsState extends State<MaterialControls> {
  PiliPlayerValue _latestValue;
  double _latestVolume;
  bool _hideStuff = true;
  Timer _hideTimer;
  Timer _showTimer;
  Timer _showAfterExpandCollapseTimer;
  bool _dragging = false;

  final barHeight = 35.0;
  final marginSize = 5.0;

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        _buildBackButton(context),
        _latestValue != null &&
                    !_latestValue.isPlaying &&
                    _latestValue.duration == null ||
                _latestValue.isBuffering
            ? Expanded(
                child: Center(
                  child: Container(
                    width: 20.0,
                    height: 20.0,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFFF5A5F)),
                    ),
                  ),
                ),
              )
            : _buildHitArea(),
        _buildBottomBar(context, widget.controller),
        //_buildMiniBar(context, widget.controller)
      ],
    );
  }


  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    widget.controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _showTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
  }

  @override
  void initState() {
    _initialize();

    super.initState();
  }

  @override
  void didUpdateWidget(MaterialControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller.url != oldWidget.controller.url) {
      _dispose();
      _initialize();
    }
  }

  AnimatedOpacity _buildBottomBar(
    BuildContext context,
    PiliPlayerController controller,
  ) {
    final iconColor = Theme.of(context).textTheme.button.color;

    return new AnimatedOpacity(
      opacity: _hideStuff ? 0.0 : 1.0,
      duration: new Duration(milliseconds: 300),
      child: new Container(
        height: barHeight,
        //color: Theme.of(context).dialogBackgroundColor,
        color: Color(0xAAFFFFFF),
        child: new Row(
          children: <Widget>[
            _buildPlayPause(controller),
            widget.isLive
                ? Expanded(child: const Text('LIVE'))
                : _buildPosition(iconColor),
            widget.isLive ? const SizedBox() : _buildProgressBar(),
            _buildMuteButton(controller),
            _buildExpandButton(),
          ],
        ),
      ),
    );
  }
  Widget _buildBackButton(BuildContext context){
    final sWidth=MediaQuery.of(context).size.width;
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.0 ),
          width: sWidth,
          height: 30.0,
          //color: Color(0x99FFFFFF),
          child:Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.keyboard_arrow_left,size: 30.0,color: Color(0xFFFFFFFF),),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              )
              
            ],
          ) ,
        ),
    );
  }
  GestureDetector _buildExpandButton() {
    return new GestureDetector(
      onTap: _onExpandCollapse,
      child: new AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: new Duration(milliseconds: 300),
        child: new Container(
          height: barHeight,
          margin: new EdgeInsets.only(right: 12.0),
          padding: new EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          child: new Center(
            child: new Icon(
              widget.fullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
            ),
          ),
        ),
      ),
    );
  }

  Expanded _buildHitArea() {
    return new Expanded(
      child: new GestureDetector(
        onTap: _latestValue != null && _latestValue.isPlaying
            ? _cancelAndRestartTimer
            : () {
                _playPause();

                setState(() {
                  _hideStuff = true;
                });
              },
        child: new Container(
          color: Colors.transparent,
          child: new Center(
            child: new AnimatedOpacity(
              opacity:
                  _latestValue != null && !_latestValue.isPlaying && !_dragging
                      ? 1.0
                      : 0.0,
              duration: new Duration(milliseconds: 300),
              child: new GestureDetector(
                child: new Container(
                  decoration: new BoxDecoration(
                    color: Theme.of(context).dialogBackgroundColor,
                    borderRadius: new BorderRadius.circular(48.0),
                  ),
                  child: new Padding(
                    padding: new EdgeInsets.all(12.0),
                    child: new Icon(Icons.play_arrow, size: 32.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildMuteButton(
    PiliPlayerController controller,
  ) {
    return new GestureDetector(
      onTap: () {
        _cancelAndRestartTimer();

        if (_latestValue.volume == 0) {
          controller.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller.value.volume;
          controller.setVolume(0.0);
        }
      },
      child: new AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: new Duration(milliseconds: 300),
        child: new ClipRect(
          child: new Container(
            child: new Container(
              height: barHeight,
              padding: new EdgeInsets.only(
                left: 8.0,
                right: 8.0,
              ),
              child: new Icon(
                (_latestValue != null && _latestValue.volume > 0)
                    ? Icons.volume_up
                    : Icons.volume_off,
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildPlayPause(PiliPlayerController controller) {
    return new GestureDetector(
      onTap: _playPause,
      child: new Container(
        height: barHeight,
        color: Colors.transparent,
        margin: new EdgeInsets.only(left: 8.0, right: 4.0),
        padding: new EdgeInsets.only(
          left: 12.0,
          right: 12.0,
        ),
        child: new Icon(
          controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
String formatDuration(Duration position) {
  final ms = position.inMilliseconds;

  int seconds = ms ~/ 1000;
  final int hours = seconds ~/ 3600;
  seconds = seconds % 3600;
  var minutes = seconds ~/ 60;
  seconds = seconds % 60;

  final hoursString = hours >= 10 ? '$hours' : hours == 0 ? '00' : '0$hours';

  final minutesString =
      minutes >= 10 ? '$minutes' : minutes == 0 ? '00' : '0$minutes';

  final secondsString =
      seconds >= 10 ? '$seconds' : seconds == 0 ? '00' : '0$seconds';

  final formattedTime =
      '${hoursString == '00' ? '' : hoursString + ':'}$minutesString:$secondsString';

  return formattedTime;
}
  Widget _buildPosition(Color iconColor) {
    final position = _latestValue != null && _latestValue.position != null
        ? _latestValue.position
        : Duration.zero;
    final duration = _latestValue != null && _latestValue.duration != null
        ? _latestValue.duration
        : Duration.zero;

    return new Padding(
      padding: new EdgeInsets.only(right: 24.0),
      child: new Text(
        '${formatDuration(position)} / ${formatDuration(duration)}',
        style: new TextStyle(
          fontSize: 14.0,
        ),
      ),
    );
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    setState(() {
      _hideStuff = false;
    });
  }

  Future<Null> _initialize() async {
    widget.controller.addListener(_updateState);

    _updateState();

    if ((widget.controller.value != null &&
            widget.controller.value.isPlaying) ||
        widget.autoPlay) {
      _startHideTimer();
    }

    _showTimer = new Timer(new Duration(milliseconds: 200), () {
      setState(() {
        _hideStuff = false;
      });
    });
  }

  void _onExpandCollapse() {
    setState(() {
      _hideStuff = true;

      widget.onExpandCollapse().then((dynamic _) {
        _showAfterExpandCollapseTimer =
            new Timer(new Duration(milliseconds: 300), () {
          setState(() {
            _cancelAndRestartTimer();
          });
        });
      });
    });
  }

  void _playPause() {
    setState(() {
      if (widget.controller.value.isPlaying) {
        _hideStuff = false;
        _hideTimer?.cancel();
        widget.controller.pause();
      } else {
        _cancelAndRestartTimer();

        if (!widget.controller.value.initialize&&!widget.controller.isAuto) {
          widget.controller.play();
        } else {
          widget.controller.play();
        }
      }
    });
  }

  void _startHideTimer() {
    _hideTimer = new Timer(const Duration(seconds: 3), () {
      setState(() {
        _hideStuff = true;
      });
    });
  }

  void _updateState() {
    setState(() {
      _latestValue = widget.controller.value;
    });
  }

  Widget _buildProgressBar() {
    return new Expanded(
      child: new Padding(
        padding: new EdgeInsets.only(right: 10.0),
        child: new PiliPlayerProgressBar(
          widget.controller,
          onDragStart: () {
            setState(() {
              _dragging = true;
            });

            _hideTimer?.cancel();
          },
          onDragEnd: () {
            setState(() {
              _dragging = false;
            });

            _startHideTimer();
          },
          colors: widget.progressColors ??
              new PiliPlayerProgressColors(
                  playedColor: Theme.of(context).accentColor,
                  handleColor: Theme.of(context).accentColor,
                  bufferedColor: Theme.of(context).backgroundColor,
                  backgroundColor: Theme.of(context).disabledColor),
        ),
      ),
    );
  }
}
