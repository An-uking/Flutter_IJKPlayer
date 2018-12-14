part of flutter_ijkplayer;

class PiliPlayerControl extends StatefulWidget {
  final PiliPlayerController controller;
  final bool fullScreen;
  final PiliPlayerProgressColors progressColors;

  PiliPlayerControl({
    @required this.controller,
    @required this.fullScreen,
    @required this.progressColors,
  });
  @override
  _PiliPlayerControlState createState() => _PiliPlayerControlState();
}

class _PiliPlayerControlState extends State<PiliPlayerControl> {
  PiliPlayerValue _latestValue;
  final barHeight = 35.0;
  final marginSize = 5.0;
  bool _dragging = false;
  @override void initState() {
    // TODO: implement initStat
    _initialize();
    super.initState();
    
  }
  @override void dispose(){
    widget.controller.removeListener(_updateState);
    super.dispose();
  }

  Future<Null> _initialize() async {
    widget.controller.addListener(_updateState);
    _updateState();
  }

  void _updateState() {
    setState(() {
      _latestValue = widget.controller.value;
      //print(_latestValue);
    });
  }

  void _playPause() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: barHeight,
      width: double.infinity,
      color: Color(0xFFFF6620),
      child: _buildControl(context),
    );
  }

  Widget _buildControl(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildPlayPause(widget.controller),
          _buildStartTime(),
          _buildProgressBar(),
          _buildEndTime(),
          _buildFullScreenBtn()
        ],
      ),
    );
  }

  GestureDetector _buildPlayPause(PiliPlayerController controller) {
    return new GestureDetector(
      onTap: _playPause,
      child: new Container(
        color: Colors.transparent,
        margin: new EdgeInsets.only(right: 10.0),
        child: new Icon(
          controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  Widget _buildStartTime() {
        final position = _latestValue != null && _latestValue.position != null
        ? _latestValue.position
        : Duration.zero;
    return Padding(
      padding: EdgeInsets.only(right: 10.0),
      child: Text("${formatDuration(position)}"),
    );
  }
  Widget _buildEndTime() {
        final duration = _latestValue != null && _latestValue.position != null
        ? _latestValue.duration
        : Duration.zero;
    return Padding(
      padding: EdgeInsets.only(right: 10.0),
      child: Text("${formatDuration(duration)}"),
    );
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

            //_hideTimer?.cancel();
          },
          onDragEnd: () {
            setState(() {
              _dragging = false;
            });

            //_startHideTimer();
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
    GestureDetector _buildFullScreenBtn() {
    return new GestureDetector(
      onTap: _playPause,
      child: new Container(
        color: Colors.transparent,
        child: new Icon(
          widget.fullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
        ),
      ),
    );
  }
}
