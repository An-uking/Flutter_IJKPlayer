part of flutter_ijkplayer;

typedef void PiliPlayerCallback(PiliPlayerController controller);

class PiliPlayer extends StatefulWidget {
  PiliPlayer({
    Key key,
    @required this.url,
    //@required this.controller,
    @required this.onPlayerCreated,
    this.options,
    this.auto=false,
    this.isLive=false,
    this.gestureRecognizers,
  })  :  super(key: key);

  final PiliPlayerCallback onPlayerCreated;
  //final PiliPlayerController controller;
  final Map<String,Object> options;
  final String url;
  final bool auto;
  final bool isLive;
  /// Which gestures should be consumed by the map.
  ///
  /// It is possible for other gesture recognizers to be competing with the map on pointer
  /// events, e.g if the map is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The map will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the map will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  @override
  State createState() => _PiliPlayerState();
}

class _PiliPlayerState extends State<PiliPlayer> {
  //final sKey = GlobalKey<_PiliPlayerState>();
  PiliPlayerController _playerController;
  bool flag = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
  Widget _buildControls(
    BuildContext context,
    PiliPlayerController controller,
  ) {
    return new PiliPlayerControl(
                controller: controller,
                fullScreen: false,
                progressColors: PiliPlayerProgressColors( 
                  playedColor: Colors.green,
                  bufferedColor: Colors.pink
                ),
              );
  }
  Widget _buildVideoPlayer(){
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: "plugin.ugle.cn/piliplayer",
        onPlatformViewCreated: onPlatformViewCreated,
        gestureRecognizers: widget.gestureRecognizers,
        creationParams: <String,Object>{"url":widget.url,"options":widget.options,"auto":widget.auto},
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: "plugin.ugle.cn/piliplayer",
        onPlatformViewCreated: onPlatformViewCreated,
        gestureRecognizers: widget.gestureRecognizers,
        creationParams: <String,Object>{"url":widget.url,"options":widget.options,"auto":widget.auto},
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
  }
  @override
  Widget build(BuildContext context) {

    return new Container(
      child: new Stack(
        children: <Widget>[
          new Center(
            child: AspectRatio(
                aspectRatio: 1.75,
                child:_buildVideoPlayer(),
              ),
          ),
          _playerController!=null?
          _buildControls(context, _playerController):Container()
        ],
      ),
    );
  }

  Future<void> onPlatformViewCreated(int id) async {
    final PiliPlayerController playerController =
        await PiliPlayerController.init(id, widget.url, widget.options,widget.auto,widget.isLive);
        _playerController=playerController;
    widget.onPlayerCreated(playerController);
    setState(() {});
  }
}
