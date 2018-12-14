part of flutter_ijkplayer;

typedef void PlayerCallback(dynamic args);
typedef Function PlayerSeekCompletedCallback(bool isCompleted);
enum RotationMode {
  PLPlayerNoRotation, // 无旋转
  PLPlayerRotateLeft, // 向左旋
  PLPlayerRotateRight, // 向右旋
  PLPlayerFlipVertical, // 垂直翻转
  PLPlayerFlipHorizonal, // 水平翻转
  PLPlayerRotate180 // 旋转 180 度
}

class PiliPlayerController extends ValueNotifier<PiliPlayerValue> {
  PiliPlayerController._(
      this._id, this._url, Map<String, Object> options, MethodChannel channel,bool auto,bool live)
      : assert(_id != null),
        assert(options != null),
        assert(_url != null),
        assert(channel != null),
        _channel = channel,
        super(PiliPlayerValue(initialize: false)) {
    _channel.setMethodCallHandler(_handleMethodCall);
    _options = options;
    //autoPlay=options.auto;
    isLive=live;
    isAuto=auto;
    _lifeCycleObserver = _VideoAppLifeCycleObserver(this);
    _lifeCycleObserver.initialize();
    //value=value.copyWith(isLive: options.isLive,isLooping: options.loop);
  }

  static Future<PiliPlayerController> init(
      id, url, Map<String, Object> options,bool auto,bool live) async {
    assert(id != null);
    assert(options != null);
    assert(url != null);
    final MethodChannel channel =
        MethodChannel('plugin.ugle.cn/piliplayer/$id');
    return PiliPlayerController._(id, url, options, channel,auto,live);
  }

  final MethodChannel _channel;
  final String _url;
  final int _id;
  bool isAuto;
  bool isLive;
  Map<String, Object> get options => _options;
  Map<String, Object> _options;
  _VideoAppLifeCycleObserver _lifeCycleObserver;
  Function _callback;
  PlayerSeekCompletedCallback _seekCompletedCallback;
  bool get initialize => _initialize;
  int get id => _id;
  String get url => _url;
  bool _initialize = false;
  PLPlayerStatus _status = PLPlayerStatus.Unknow;
  PLPlayerStatus get playerStatus => _status;
  Timer _timer;
  int _seekToValue;
  // Duration position=Duration(milliseconds: 0);
  // Duration duration=Duration(milliseconds: 0);
  // Duration durationBuffered=Duration(milliseconds: 0);
  // bool hasError=false;
  // String errMessage="";
  //Stream get playerStateChange =>_eventChannel.receiveBroadcastStream();
  // void ss(){
  //   _eventChannel.receiveBroadcastStream()
  //   ..listen(eventListener,onError: errorListener);
  // }

  void dispose() {
    _options = null;
    _timer?.cancel();
    _lifeCycleObserver?.dispose();
  }

  void setSeekCompletedCallback(Function callback) {
    if (_seekCompletedCallback != null) {
      _seekCompletedCallback = callback;
    }
  }

  void setStateChangeCallback(Function callback) {
    _callback = callback;
  }

  PLPlayerStatus _getPlayerState(int state) {
    PLPlayerStatus _temp = PLPlayerStatus.values[state];
    if (_temp != null) {
      return _temp;
    }
    return PLPlayerStatus.Unknow;
  }

  Future<void> _stateChange(int state) async {

    _status = _getPlayerState(state);
    if (_initialize) {
      value = value.copyWith(isPlaying: _status == PLPlayerStatus.Playing);
    }
    print(_status);
    switch (_status) {
      case PLPlayerStatus.Ready:
        _initialize = true;
        value = value.copyWith(initialize: true,hasError: false);
        _getTotalDuration();
        if (_lifeCycleObserver.backgroundPaused&&!isLive) {
          value=value.copyWith(position: Duration(milliseconds: _lifeCycleObserver.position));
          seekTo(_lifeCycleObserver.position);
          _lifeCycleObserver.backgroundPaused=false;
          _lifeCycleObserver.position=0;
          if (_lifeCycleObserver.backgroundStatus == PLPlayerStatus.Playing) {
            play();
          } else if (_lifeCycleObserver.backgroundStatus ==
              PLPlayerStatus.Paused) {
            pause();
          }
        }
        //print(duration.inMilliseconds);
        break;
      case PLPlayerStatus.Playing:
        value = value.copyWith(isBuffering: true);
        _getPosition();
        break;
      case PLPlayerStatus.Completed:
        value = value.copyWith(position: value.duration); //修复播放结束时间不一至
        break;
      default:
        break;
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    //print(call.method);
    switch (call.method) {
      case 'player#stateChange':
        _stateChange(call.arguments["state"]);
        break;
      case 'player#error':
        //hasError=true;
        value = value.copyWith(hasError: true);
        //print(call.arguments);
        break;
      case 'player#seekCompleted':
        //print(call.arguments);
        if (_status != PLPlayerStatus.Playing && _seekToValue != null) {
          value =
              value.copyWith(position: Duration(milliseconds: _seekToValue));
          _seekToValue = null;
        }
        break;
      case 'player#durationBuffered':
        //print(call.arguments);
        value =
            value.copyWith(bufferedPrecent: call.arguments["bufferedPrecent"]);
        break;
      case 'player#videoSizeChange':
        value = value.copyWith(
            size: Size(call.arguments["width"], call.arguments["height"]));
        break;
      default:
        throw MissingPluginException(); //durationBuffered
    }
  }

  Future<void> _getPosition() async {
    if (!_initialize) {
      return;
    }
    if (_status == PLPlayerStatus.Playing) {
      _timer = Timer.periodic(
        const Duration(milliseconds: 500),
        (Timer timer) async {
          if (_status != PLPlayerStatus.Playing) {
            return;
          }
          final Map<dynamic, dynamic> res = await _getRealData();
          if (_status != PLPlayerStatus.Playing) {
            return;
          }
          //print(res["currentTime"]);
          value = value.copyWith(
              position: Duration(milliseconds: int.parse(res["currentTime"])),
              // fpsDecode: res["fpsDecode"],
               //fpsOutput: res["fpsOutput"],
              // downloadSpeed: res["downloadSpeed"],
               bitrate: res["bitrate"].toString()
            );
        },
      );
    } else {
      _timer?.cancel();
      //await pause();
    }
  }

  ///播放
  Future<void> play() async {
    await _channel.invokeMethod("player#play");
  }

  ///暂停
  Future<void> pause() async {
    await _channel.invokeMethod("player#pause");
  }

  ///停止
  Future<void> stop() async {
    await _channel.invokeMethod("player#stop");
  }

  ///播放新的URL
  ///
  ///@params url
  ///
  ///@params sameSource  相同的格式的视频 更快播放
  Future<void> playNewURL(String url) async {
    await _channel
        .invokeMethod("player#playNewURL", <String, dynamic>{"url": url});
  }

  ///快速定位到指定播放时间点，
  ///
  ///该方法仅在回放时起作用，直播场景下该方法直接返回
  ///
  ///@params time 时间
  Future<void> seekTo(int time) async {
    _channel.invokeMethod("player#seekTo",
        <String, dynamic>{"time": time}).whenComplete(() {
      if (_status != PLPlayerStatus.Playing) {
        _seekToValue = time;
      }
    });
  }

  ///是否静音
  ///
  ///@params flag 时间
  Future<void> setMute(bool flag) async {
    await _channel
        .invokeMethod("player#setMute", <String, dynamic>{"flag": flag});
  }

  ///设置播放画面旋转模式
  ///
  ///@params mode 旋转模式
  // Future<void> setRotationMode(RotationMode mode) async {
  //   await _channel.invokeMethod(
  //       "player#setRotationMode", <String, dynamic>{"mode": mode.index});
  // }

  ///设置音亮
  ///
  ///@params volume 范围0〜3.0 默认为1.0
  Future<void> setVolume(double volume) async {
    await _channel
        .invokeMethod("player#setVolume", <String, dynamic>{"volume": volume});
  }

  ///设置循环播放
  ///
  ///@params flag
  Future<void> setLoop(bool flag) async {
    value = value.copyWith(isLooping: flag);
    await _channel
        .invokeMethod("player#setLoop", <String, dynamic>{"flag": flag});
  }

  ///变速播放
  ///
  ///@params speed  范围0.2〜32 默认为1.0
  Future<void> setPlaySpeed(double speed) async {
    await _channel
        .invokeMethod("player#setPlaySpeed", <String, dynamic>{"speed": speed});
  }

  ///设置是否缓冲
  ///
  ///@params flag 为false时会暂停播放 默认为true
  // Future<void> setBufferingEnabled(bool flag) async {
  //   value = value.copyWith(isBuffering: flag);
  //   await _channel.invokeMethod(
  //       "player#setBufferingEnabled", <String, dynamic>{"flag": flag});
  // }

  ///获取已缓冲大小(文件大小)
  // Future<int> get bufferSize async {
  //   var result = await _channel.invokeMethod("player#getHttpBufferSize");
  //   return int.parse(result["bufferSize"]);
  // }

  ///获取当前时间
  Future<Map<dynamic, dynamic>> _getRealData() async {
    Map<dynamic, dynamic> result =
        await _channel.invokeMethod("player#getRealData");
    return result;
  }

  ///获取总时间
  Future<void> _getTotalDuration() async {
    var result = await _channel.invokeMethod("player#totalDuration");
    value = value.copyWith(
        duration: Duration(milliseconds: int.parse(result["totalDuration"])));
  }
}
