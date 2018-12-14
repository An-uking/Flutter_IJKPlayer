//
//  IJKPlayerFactory.m
//  Pods-Runner
//
//  Created by uking on 2018/12/2.
//

#import "IJKPlayerFactory.h"
#import "IJKPlayerController.h"
@implementation IJKPlayerFactory {
//    NSObject<FlutterPluginRegistrar>* _registrar;
    NSObject<FlutterBinaryMessenger>* _messenger;
    //NSObject<IJKPlayerController> * _controller;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    if (self) {
        _messenger = messenger;
    }
    return self;
}
- (NSObject<FlutterMessageCodec>*)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args {
    NSLog(@"viewId:%lld",viewId);
    return [[IJKPlayerController alloc] initWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:_messenger];
}


@end
