package cn.ugle.plugin.ijkplayer;

import android.content.Context;
import android.graphics.Bitmap;
import android.support.annotation.AttrRes;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.view.Gravity;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.widget.FrameLayout;

import java.io.IOException;
import java.lang.reflect.Field;
import java.math.BigInteger;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import tv.danmaku.ijk.media.player.IMediaPlayer;
import tv.danmaku.ijk.media.player.IjkMediaPlayer;


public class IJKPlayerView extends FrameLayout {

    /**
     * 由ijkplayer提供，用于播放视频，需要给他传入一个surfaceView
     */
    private IMediaPlayer mMediaPlayer = null;

    /**
     * 视频文件地址
     */
    private String mPath = "";

    private SurfaceView surfaceView;

    private IJKPlayerListener listener;
    private Context mContext;

    private Map<String,Object> mOptons;

    public IJKPlayerView(@NonNull Context context, Map<String,Object> options) {
        super(context);

        initVideoView(context,options);
    }

    public IJKPlayerView(@NonNull Context context, Map<String,Object> options, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initVideoView(context,options);
    }

    public IJKPlayerView(@NonNull Context context, Map<String,Object> options, @Nullable AttributeSet attrs, @AttrRes int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initVideoView(context,options);
    }

    private void initVideoView(Context context,Map<String,Object> options) {
        mContext = context;
        mOptons=options;
        //获取焦点，不知道有没有必要~。~
        setFocusable(true);
    }

    /**
     * 设置视频地址。
     * 根据是否第一次播放视频，做不同的操作。
     *
     * @param path the path of the video.
     */
    public void setVideoPath(String path) {
        if (TextUtils.equals("", mPath)) {
            //如果是第一次播放视频，那就创建一个新的surfaceView
            mPath = path;
            createSurfaceView();
        } else {
            //否则就直接load
            mPath = path;
            load(surfaceView.getHolder());
        }
    }

    /**
     * 新建一个surfaceview
     */
    private void createSurfaceView() {
        //生成一个新的surface view
        surfaceView = new SurfaceView(mContext);
        surfaceView.getHolder().addCallback(new LmnSurfaceCallback());
        LayoutParams layoutParams = new LayoutParams(LayoutParams.MATCH_PARENT
                , LayoutParams.MATCH_PARENT, Gravity.CENTER);
        surfaceView.setLayoutParams(layoutParams);
        this.addView(surfaceView);

    }

    /**
     * surfaceView的监听器
     */
    private class LmnSurfaceCallback implements SurfaceHolder.Callback {
        @Override
        public void surfaceCreated(SurfaceHolder holder) {

        }

        @Override
        public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
            //surfaceview创建成功后，加载视频
            load(holder);
        }

        @Override
        public void surfaceDestroyed(SurfaceHolder holder) {
        }
    }

    /**
     * 加载视频
     */
    private void load(final SurfaceHolder holder) {
        //每次都要重新创建IMediaPlayer
        createPlayer();
        try {
            mMediaPlayer.setDataSource(mPath);
        } catch (IOException e) {
            e.printStackTrace();
        }
        //给mediaPlayer设置视图
        mMediaPlayer.setDisplay(holder);
        mMediaPlayer.prepareAsync();
    }

    /**
     * 创建一个新的player
     */
    private void createPlayer() {
        if (mMediaPlayer != null) {
            mMediaPlayer.stop();
            mMediaPlayer.setDisplay(null);
            mMediaPlayer.release();
        }
        IjkMediaPlayer ijkMediaPlayer = new IjkMediaPlayer();
        ijkMediaPlayer.native_setLogLevel(IjkMediaPlayer.IJK_LOG_SILENT);


        if(mOptons!=null){
            for (Map.Entry<String, Object> entry : mOptons.entrySet()) {
                Map<String,String> map=(Map<String,String>)entry.getValue();
                for(String key : map.keySet()){
                    int ca=Integer.parseInt(entry.getKey());
                    long val=Long.parseLong(map.get(key));
                    ijkMediaPlayer.setOption(ca,key,val);
                }
            }
        }
        //ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "start_on_prepared", 0);
        mMediaPlayer = ijkMediaPlayer;
        if (listener != null) {
            mMediaPlayer.setOnPreparedListener(listener);
            mMediaPlayer.setOnInfoListener(listener);
            mMediaPlayer.setOnSeekCompleteListener(listener);
            mMediaPlayer.setOnBufferingUpdateListener(listener);
            mMediaPlayer.setOnErrorListener(listener);
            mMediaPlayer.setOnCompletionListener(listener);
            mMediaPlayer.setOnVideoSizeChangedListener(listener);
        }
    }

    public void setListener(IJKPlayerListener listener) {
        this.listener = listener;
        if (mMediaPlayer != null) {
            mMediaPlayer.setOnPreparedListener(listener);
        }
    }

    public void start() {
        if (mMediaPlayer != null) {
            mMediaPlayer.start();
        }
    }

    public void release() {
        if (mMediaPlayer != null) {
            mMediaPlayer.reset();
            mMediaPlayer.release();
            mMediaPlayer = null;
        }
    }

    public void pause() {
        if (mMediaPlayer != null) {
            mMediaPlayer.pause();
        }
    }

    public void stop() {
        if (mMediaPlayer != null) {
            mMediaPlayer.stop();
        }
    }


    public void reset() {
        if (mMediaPlayer != null) {
            mMediaPlayer.reset();
        }
    }


    public long getDuration() {
        if (mMediaPlayer != null) {
            return mMediaPlayer.getDuration();
        } else {
            return 0;
        }
    }


    public long getCurrentPosition() {
        if (mMediaPlayer != null) {
            return mMediaPlayer.getCurrentPosition();
        } else {
            return 0;
        }
    }


    public void seekTo(long l) {
        if (mMediaPlayer != null) {
            mMediaPlayer.seekTo(l);
        }
    }

    public void setLooping(boolean flag){
        if(mMediaPlayer!=null){
            mMediaPlayer.setLooping(flag);
        }
    }

    public boolean isPlaying(){
        if(mMediaPlayer!=null){
            return mMediaPlayer.isPlaying();
        }else{
            return  false;
        }
    }

    public boolean isLooping(){
        if(mMediaPlayer!=null){
            return mMediaPlayer.isLooping();
        }else{
            return false;
        }
    }

    public void  setVolume(float left,float right){
        if(mMediaPlayer!=null){
            mMediaPlayer.setVolume(left,right);
        }
    }

    public void setPlaySpeed(float speed) {
        if(mMediaPlayer!=null) {
            ((IjkMediaPlayer) mMediaPlayer).setSpeed(speed);
        }
    }

    public float getPlaySpeed() {
        if(mMediaPlayer!=null) {
            return ((IjkMediaPlayer) mMediaPlayer).getSpeed(.0f);
        }else{
            return .0f;
        }
    }

    public void setWakeMode(int mode){
        if(mMediaPlayer!=null){
            mMediaPlayer.setWakeMode(mContext,mode);
        }
    }
    private static String formatedSpeed(long bytes,long elapsed_milli) {
        if (elapsed_milli <= 0) {
            return "0 B/s";
        }

        if (bytes <= 0) {
            return "0 B/s";
        }

        float bytes_per_sec = ((float)bytes) * 1000.f /  elapsed_milli;
        if (bytes_per_sec >= 1000 * 1000) {
            return String.format(Locale.US, "%.2f MB/s", ((float)bytes_per_sec) / 1000 / 1000);
        } else if (bytes_per_sec >= 1000) {
            return String.format(Locale.US, "%.1f KB/s", ((float)bytes_per_sec) / 1000);
        } else {
            return String.format(Locale.US, "%d B/s", (long)bytes_per_sec);
        }
    }

    public String getTcpSeed(){
        if(mMediaPlayer!=null) {

            return formatedSpeed(((IjkMediaPlayer) mMediaPlayer).getTcpSpeed(),1000);
        }
        return formatedSpeed(0,1000);
    }
    public String getBitRate(){
        if(mMediaPlayer!=null) {
            long bitRate=((IjkMediaPlayer) mMediaPlayer).getBitRate();

            return String.format(Locale.US, "%.2f kbs", bitRate/1000f);
        }
        return String.format(Locale.US, "%.2f kbs", .0f);
//        float fpsOutput = mp.getVideoOutputFramesPerSecond();
//        float fpsDecode = mp.getVideoDecodeFramesPerSecond();
//        setRowValue(R.string.fps, String.format(Locale.US, "%.2f / %.2f", fpsDecode, fpsOutput));
    }
    public float getVideoOutputFramesPerSecond(){
        if(mMediaPlayer!=null){
            return ((IjkMediaPlayer) mMediaPlayer).getVideoOutputFramesPerSecond();
        }
        return .0f;
    }

    public float getVideoDecodeFramesPerSecond(){
        if(mMediaPlayer!=null){
            return ((IjkMediaPlayer) mMediaPlayer).getVideoDecodeFramesPerSecond();
        }
        return .0f;
    }
}
