//
//  IJKPlayerFactory.h
//  Pods-Runner
//
//  Created by uking on 2018/12/2.
//

#import <Flutter/Flutter.h>
NS_ASSUME_NONNULL_BEGIN

@interface IJKPlayerFactory : NSObject <FlutterPlatformViewFactory>
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
//- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;
@end

NS_ASSUME_NONNULL_END
