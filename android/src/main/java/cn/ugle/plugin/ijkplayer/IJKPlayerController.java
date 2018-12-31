package cn.ugle.plugin.ijkplayer;

import android.content.Context;
import android.util.Log;
import android.view.SurfaceView;
import android.view.View;


import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

import tv.danmaku.ijk.media.player.IMediaPlayer;
import tv.danmaku.ijk.media.player.IjkMediaPlayer;
import tv.danmaku.ijk.media.player.IjkTimedText;

public class IJKPlayerController implements PlatformView, MethodChannel.MethodCallHandler {


    private SurfaceView surfaceView;
    private final MethodChannel methodChannel;
    private final IJKPlayerView mVideoView;
    private String mVideoPath;
    private Map<String,Object> mOptions;
    private final boolean isAutoPlay;
//    private boolean isMute = false;
//    private boolean isLive = false;

    private final String TAG="FLUTTER_IJKPLAYER";

    @SuppressWarnings("unchecked")
    IJKPlayerController(Context context, BinaryMessenger messenger, int id, Object args) {
        Map<String, Object> params = (Map<String, Object>) args;
        mVideoPath = (String) params.get("url");
        isAutoPlay=(boolean)params.get("auto");
        Object obj=params.get("options");
        if(obj!=null){
            mOptions=(Map<String,Object>)obj;
        }
        methodChannel = new MethodChannel(messenger, "plugin.ugle.cn/piliplayer/" + id);
        methodChannel.setMethodCallHandler(this);
        mVideoView = new IJKPlayerView(context,mOptions);
        setVideoInit();
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("player#play")) {
            play();
            result.success(null);
        } else if (call.method.equals("player#pause")) {
            pasue();
            result.success(null);
        } else if (call.method.equals("player#stop")) {
            stop();
            result.success(null);
        } else if (call.method.equals("player#setMute")) {
            boolean flag = (boolean) call.argument("flag");
            setMute(flag);
            result.success(null);
        } else if (call.method.equals("player#playNewNRL")) {
            //[self dispose];
            String url = call.argument("url");
            boolean flag = (boolean) call.argument("sameSource");
            playNewURL(url);
        } else if (call.method.equals("player#getRealData")) {
            Map<String, Object> map = new HashMap<>();
            map.put("currentTime", mVideoView.getCurrentPosition());
            map.put("bitrate",mVideoView.getBitRate());
            map.put("downloadSpeed",mVideoView.getTcpSeed());
            map.put("fpsOutput",mVideoView.getVideoOutputFramesPerSecond());
            map.put("fpsDecode",mVideoView.getVideoDecodeFramesPerSecond());
            result.success(map);
        } else if (call.method.equals("player#totalDuration")) {
            Map<String, Object> map = new HashMap<>();
            map.put("totalDuration", mVideoView.getDuration());
            result.success(map);
        } else if (call.method.equals("player#seekTo")) {
            //NSNumber* seekTime=call.arguments[@"time"];
            long seekTime = Long.parseLong((String) call.argument("time"));
            seekTo(seekTime);
            result.success(null);
        } else if (call.method.equals("player#setVolume")) {
            float volume = (float) call.argument("volume");
            setVolume(volume / 3);
            result.success(null);
        } else if (call.method.equals("player#setLoop")) {
            boolean flag = (boolean) call.argument("flag");
            mVideoView.setLooping(flag);
            result.success(null);
        } else if (call.method.equals("player#setPlaySpeed")) {
            int speed = (int) call.argument("seed");
            setPlaySeed(speed);
            result.success(null);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public View getView() {
        return mVideoView;
    }

    @Override
    public void dispose() {
        if (mVideoView != null) {
            mVideoView.release();
        }
    }

    private void setVideoInit() {

        //mVideoView.setSurface(surface);
        mVideoView.setListener(new IJKPlayerListener() {
            @Override
            public void onVideoSizeChanged(IMediaPlayer iMediaPlayer, int width, int height, int mVideoSarNum, int mVideoSarDen) {
                Map<String, Object> message = new HashMap<>();
                message.put("width", width);
                message.put("height", height);
                methodChannel.invokeMethod("player#videoSizeChange", message);
            }

            @Override
            public void onBufferingUpdate(IMediaPlayer iMediaPlayer, int precent) {
                Map<String, Object> message = new HashMap<>();
                message.put("bufferedPrecent", precent>98?100:precent);
                methodChannel.invokeMethod("player#durationBuffered", message);
            }

            @Override
            public void onCompletion(IMediaPlayer iMediaPlayer) {
                Map<String, Object> message = new HashMap<>();
                message.put("state", 5);
                methodChannel.invokeMethod("player#stateChange", message);
            }

            @Override
            public boolean onError(IMediaPlayer iMediaPlayer, int errorCode, int i1) {
                Map<String, Object> message = new HashMap<>();
                message.put("state", errorCode);
                methodChannel.invokeMethod("player#error", message);
                return false;
            }

            @Override
            public boolean onInfo(IMediaPlayer iMediaPlayer, int what, int extra) {
                Map<String, Object> message = new HashMap<>();
                message.put("state", "MEDIA_INFO_BUFFERING_END");
                methodChannel.invokeMethod("player#videoInfo", message);
                return false;
            }

            @Override
            public void onPrepared(IMediaPlayer iMediaPlayer) {
                Map<String, Object> message = new HashMap<>();
                message.put("state", 1);//ready
                methodChannel.invokeMethod("player#stateChange", message);
                if (isAutoPlay) {
                    play();
                }
            }

            @Override
            public void onSeekComplete(IMediaPlayer iMediaPlayer) {
                Map<String, Object> message = new HashMap<>();
                message.put("isCompleted", true);
                methodChannel.invokeMethod("player#seekCompleted", message);
            }
        });
        mVideoView.setVideoPath(mVideoPath);
    }

    //播放或暂停
    private void play() {
        mVideoView.start();
        Map<String, Object> message = new HashMap<>();
        message.put("state", 2);//playing
        methodChannel.invokeMethod("player#stateChange", message);
    }

    private void pasue() {
        if (mVideoView.isPlaying()) {
            mVideoView.pause();
            Map<String, Object> message = new HashMap<>();
            message.put("state", 3);//pause
            methodChannel.invokeMethod("player#stateChange", message);
        }

    }

    //停止播放
    private void stop() {
        Map<String, Object> message = new HashMap<>();
        message.put("state", 4);//stop
        methodChannel.invokeMethod("player#stateChange", message);
        mVideoView.stop();

    }

    private void playNewURL(String url) {
        stop();
        mVideoView.setVideoPath(url);
    }

    private void setMute(boolean flag) {
        if (flag) {
            setVolume(0.0f);
        } else {
            setVolume(0.8f);
        }
    }

    private void setVolume(float volume) {
        float val = (float) Math.max(0.0, Math.min(1.0, volume));
        mVideoView.setVolume(val, val);
    }

    private void seekTo(long location) {
        mVideoView.seekTo(location);
    }

    private void setPlaySeed(float seed){
        // mVideoView.setSpeed(seed);
    }

}
