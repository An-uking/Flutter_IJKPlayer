//
//  IJKPlayerController.h
//  Pods-Runner
//
//  Created by uking on 2018/12/2.
//

#import <Flutter/Flutter.h>
#import <IJKMediaFramework/IJKFFMoviePlayerController.h>
#import <IJKMediaFramework/IJKMediaPlayback.h>
#import <IJKMediaFramework/IJKMediaPlayer.h>
NS_ASSUME_NONNULL_BEGIN

@interface IJKPlayerController
: NSObject <FlutterPlatformView,IJKMediaNativeInvokeDelegate,IJKMediaUrlOpenDelegate>
@property(atomic, retain) id<IJKMediaPlayback> player;
- (instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
- (int)invoke:(IJKMediaEvent)event attributes:(NSDictionary *)attributes;
- (UIView *)view;
@end

NS_ASSUME_NONNULL_END
