//
//  IJKPlayerController.m
//  Pods-Runner
//
//  Created by uking on 2018/12/2.
//

#import "IJKPlayerController.h"

int64_t FLTCMTimeToMillis(CMTime time) { return time.value * 1000 / time.timescale; }

@implementation IJKPlayerController {
    //IJKFFMoviePlayerController* _player;
    UIView* _playerContainer;
    int64_t _viewId;
    FlutterMethodChannel* _channel;
    //NSObject<FlutterPluginRegistrar>* _registrar;
    bool _isLive;
    bool _isLoop;
}
- (instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    if ([super init]) {
        _viewId = viewId;
        _playerContainer=[[UIView alloc] initWithFrame:frame];
        NSString* channelName =[NSString stringWithFormat:@"plugin.ugle.cn/piliplayer/%lld", _viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        __weak __typeof__(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
            if (weakSelf) {
                [weakSelf onMethodCall:call result:result];
            }
        }];
        [weakSelf initPlayerWithOtions:args];
    }
    return self;
}
- (void)initPlayerWithOtions:(id _Nullable)args{
    //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    #ifdef DEBUG
        [IJKFFMoviePlayerController setLogReport:YES];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
    #else
        [IJKFFMoviePlayerController setLogReport:NO];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_SILENT];
    #endif
    NSDictionary* map = args;
    NSDictionary* playerOptions=map[@"options"];
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    for (NSString *key in playerOptions) {
        NSDictionary* opt=playerOptions[key];
        for (NSString* skey in opt) {
            int64_t val=[[NSNumber numberWithLong:(long)opt[skey]] integerValue];
            [options setOptionIntValue:val forKey:skey ofCategory:(int)key];
        }
    }
    //[options set]
    
    //bool isBackground=[[map objectForKey:@"backgroundPlay"] boolValue];
    bool isAuto=[[map objectForKey:@"auto"] boolValue];
    _isLive=[[map objectForKey:@"isLive"] boolValue];
    NSURL* url=[[NSURL alloc] initWithString:args[@"url"]];
    [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:options];
    //self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    //self.player.view.frame = self.view.bounds;
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.player.shouldAutoplay=isAuto;
    //[_player.p]
    
    [self setupPlayerUI];
    [self addMovieNotificationObservers];
    [self.player prepareToPlay];
//    if(isAuto){
//        [_player play];
//    }
}

- (void)dealloc {
    //[self ret];
    [self stop];
    [self.player shutdown];
    [self removeFromView];
    _player=nil;
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeMovieNotificationObservers];
}

- (void) setupPlayerUI{
    [_playerContainer addSubview:_player.view];
    [_player.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:_player.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_playerContainer attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:_player.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_playerContainer attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_player.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_playerContainer attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_player.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_playerContainer attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    NSArray *constraints = [NSArray arrayWithObjects:centerX, centerY,width,height, nil];
    [_playerContainer addConstraints: constraints];
    
    
}
- (UIView *)view {
    return _playerContainer;
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary* args =  call.arguments;
    if([call.method isEqualToString:@"player#play"]) {
        [self play];
        result(nil);
    }else if ([call.method isEqualToString:@"player#pause"]) {
        [self pause];
        result(nil);
    }else if ([call.method isEqualToString:@"player#stop"]) {
        [self stop];
        result(nil);
    }else if ([call.method isEqualToString:@"player#setMute"]) {
        bool muteFlag=[[args objectForKey:@"flag"] boolValue];
        [self setMute:muteFlag];
        result(nil);
    }else if ([call.method isEqualToString:@"player#playNewURL"]) {
        //[self dispose];
        NSString* url=[[args objectForKey:@"url"] stringValue];
        //bool flag=[[args objectForKey:@"sameSource"] boolValue];
        [self playURL:url ];
        result(nil);
    }else if ([call.method isEqualToString:@"player#getRealData"]) {
        //int64_t currentTime=[[NSNumber numberWithDouble:round(_player.currentPlaybackTime)] integerValue];
        NSNumber* numStage =  [NSNumber numberWithDouble:_player.currentPlaybackTime*1000];
        
        NSString *strCurTime = [NSString stringWithFormat:@"%0.0lf",[numStage doubleValue]];
        result(@{@"currentTime":strCurTime,@"bitrate":@(_player.playbackRate)});
    }else if ([call.method isEqualToString:@"player#totalDuration"]) {
        if(_isLive){
            result(@{@"totalDuration":@("0")});
        }else{
            NSNumber* numStage =  [NSNumber numberWithDouble:_player.duration*1000];
            NSString *strDuration = [NSString stringWithFormat:@"%0.0lf",[numStage doubleValue]];
            //int64_t totalDuration=FLTCMTimeToMillis(_player.totalDuration);
            result(@{@"totalDuration":strDuration});
        }
    }
    else if ([call.method isEqualToString:@"player#seekTo"]) {
        //NSNumber* seekTime=call.arguments[@"time"];
        int64_t seekTime=[[args objectForKey:@"time"] integerValue];
        NSTimeInterval time=[[NSNumber numberWithDouble:seekTime/1000] doubleValue];
        [self seekTo:time];
        result(nil);
    }else if ([call.method isEqualToString:@"player#setVolume"]) {
        [self setVolume:[[args objectForKey:@"volume"] floatValue]];
        result(nil);
    }
    //    else if ([call.method isEqualToString:@"player#getVolume"]) {
    //        result(@{@"volume":@(_player.getVolume)});
    //    }
    else if ([call.method isEqualToString:@"player#setLoop"]) {
        bool loopFlag=[[args objectForKey:@"flag"] boolValue];
        [self setLooping:loopFlag];
        result(nil);//
    }else if ([call.method isEqualToString:@"player#setPlaySpeed"]) {
        //double speed=[[args objectForKey:@"speed"] doubleValue];
        //[_player setPlaySpeed:speed];
        result(nil);//
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}



- (void)removeFromView {
    [_player.view removeFromSuperview];
    [_playerContainer removeFromSuperview];
}

//
#pragma mark - FLTGoogleMapOptionsSink methods
- (void)play {
    [_player play];
}

-(void)pause{
    [_player pause];
}

-(void)stop{
    [_player stop];
}

- (void)setMute:(BOOL)enabled{
    
    _player.playbackVolume=0;
}

-(void)playURL:(NSString*)url {
    if(_player){
        if(_player.playbackState==IJKMPMoviePlaybackStatePlaying){
            [_player stop];
        }
        //[_player]
        //[_player playWithURL:[NSURL URLWithString:url] sameSource:flag];
    }
}
- (void)seekTo:(NSTimeInterval)time{
    //[_player seek:time];
    _player.currentPlaybackTime=time;
}
- (void)setVolume:(float)volume{
    //[_player setVolume:volume];
    _player.playbackVolume=volume;
}
-(void)setLooping:(BOOL) flag{
    _isLoop=flag;
}

- (void)willOpenUrl:(IJKMediaUrlOpenData *)urlOpenData {
    NSLog(@"willOpenUrl%@",urlOpenData.url);
}
- (int)invoke:(IJKMediaEvent)event attributes:(NSDictionary *)attributes{
    NSLog(@"ss");
    return 0;
}

- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
    
    IJKMPMovieLoadState loadState = _player.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            [_channel invokeMethod:@"player#stateChange" arguments:@{@"state":@(5)}];
            if(_isLoop){
                [self play];
            }
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            //[_channel invokeMethod:@"player#stateChange" arguments:@{@"state":@(5)}];
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            [_channel invokeMethod:@"player#error" arguments:@{@"error":@(1123)}];
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
    [_channel invokeMethod:@"player#stateChange" arguments:@{@"state":@(1)}];
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    //    MPMoviePlaybackStateStopped,
    //    MPMoviePlaybackStatePlaying,
    //    MPMoviePlaybackStatePaused,
    //    MPMoviePlaybackStateInterrupted,
    //    MPMoviePlaybackStateSeekingForward,
    //    MPMoviePlaybackStateSeekingBackward
    
    switch (_player.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            if(_player.duration>0){//防止正常播放完必后状态为stop
                NSNumber* numDuration =  [NSNumber numberWithDouble:_player.duration];
                NSString *strDuration = [NSString stringWithFormat:@"%0.0lf",[numDuration doubleValue]];
                NSNumber* numCurTime =  [NSNumber numberWithDouble:_player.currentPlaybackTime];
                NSString *strCurTime = [NSString stringWithFormat:@"%0.0lf",[numCurTime doubleValue]];
                int intDuration=(int)strDuration;
                int intCurTime=(int)strCurTime;
                if(intCurTime==intDuration||intDuration>=intCurTime+1) break;
            }
            if(_player.currentPlaybackTime!=_player.duration){
                [_channel invokeMethod:@"player#stateChange" arguments:@{@"state":@(4)}];
            }
            
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            [_channel invokeMethod:@"player#stateChange" arguments:@{@"state":@(2)}];
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            [_channel invokeMethod:@"player#stateChange" arguments:@{@"state":@(3)}];
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

#pragma mark Install Movie Notifications

/* Register observers for the various movie object notifications. */
-(void)addMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
}

@end
