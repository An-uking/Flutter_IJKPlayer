part of flutter_ijkplayer;

class _VideoAppLifeCycleObserver extends Object with WidgetsBindingObserver {
  _VideoAppLifeCycleObserver(this._controller);

  bool _wasPlayingBeforePause = false;
  final PiliPlayerController _controller;
  int position;
  bool backgroundPaused = false;
  PLPlayerStatus backgroundStatus;
  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        if (!_controller.isLive) {//只处理点播情况
          backgroundPaused = true;
          backgroundStatus = _controller._status;
          position = _controller.value.position.inMilliseconds;
        }
        _wasPlayingBeforePause =
            _controller.playerStatus == PLPlayerStatus.Playing;
        _controller.pause();
        break;
      case AppLifecycleState.resumed:
        if (_wasPlayingBeforePause) {
          _controller.play();
        }
        break;
      default:
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
