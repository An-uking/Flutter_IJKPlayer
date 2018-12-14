part of flutter_ijkplayer;
class PiliPlayerValue {
  PiliPlayerValue({
    @required this.initialize,
    this.duration=const Duration(milliseconds: 0),
    this.position = const Duration(milliseconds: 0),
    this.bufferedPrecent = 0,
    this.fpsDecode = 0.0,
    this.bitrate = '',
    this.fpsOutput  =0.0,
    this.downloadSpeed='',
    this.isPlaying = false,
    this.isLooping = false,
    this.isBuffering = false,
    this.isLive = false,
    this.volume = 1.0,
    this.hasError=false,
    this.errMsg,
  });

  PiliPlayerValue.uninitialized() : this(initialize: false);

  PiliPlayerValue.erroneous(String errMsg)
      : this(initialize: false, errMsg: errMsg);

  /// The total duration of the video.
  ///
  /// Is null when [initialized] is false.
  final Duration duration;

  /// The current playback position.
  final Duration position;

  /// The currently buffered precent.
  final int bufferedPrecent;

  final  String bitrate;
  final  String downloadSpeed;
  final  double fpsOutput;
  final  double fpsDecode;

  /// True if the video is playing. False if it's paused.
  final bool isPlaying;

  /// True if the video is looping.
  final bool isLooping;

  /// True if the video is currently buffering.
  final bool isBuffering;

  final bool isLive;

  final bool initialize;

  /// The current volume of the playback.
  final double volume;

  /// A description of the error if present.
  ///
  /// If [hasError] is false this is [null].
  final String errMsg;
  //bool get initialized => duration != null;
  bool  hasError;

  PiliPlayerValue copyWith({
    Duration duration,
    Size size,
    Duration position,
    int bufferedPrecent,
    String bitrate,
    String downloadSpeed,
    double fpsOutput,
    double fpsDecode,
    bool isPlaying,
    bool isLooping,
    bool isBuffering,
    bool isLive,
    double volume,
    bool initialize,
    bool hasError,
    String errMsg,
  }) {
    return PiliPlayerValue(
      duration: duration ?? this.duration,
      position: position ?? this.position,
      bufferedPrecent: bufferedPrecent ?? this.bufferedPrecent,
      isPlaying: isPlaying ?? this.isPlaying,
      isLooping: isLooping ?? this.isLooping,
      isBuffering: isBuffering ?? this.isBuffering,
      isLive: isLive ?? this.isLive,
      volume: volume ?? this.volume,
      errMsg: errMsg ?? this.errMsg,
      hasError: hasError ?? this.hasError,
      initialize: initialize ?? this.initialize,
      fpsDecode: fpsDecode ?? this.fpsDecode,
      fpsOutput: fpsOutput ?? this.fpsOutput,
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
      bitrate: bitrate ?? this.bitrate
    );
  }

  @override
  String toString() {
    return '$runtimeType('
        'duration: $duration, '
        'position: $position, '
        'buffered: $bufferedPrecent, '
        'isPlaying: $isPlaying, '
        'isLooping: $isLooping, '
        'isBuffering: $isBuffering'
        'volume: $volume, '
        'errorDescription: $errMsg)';
  }
}
