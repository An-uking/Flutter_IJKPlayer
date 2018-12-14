#import "IJKPlayerPlugin.h"
#import "IJKPlayerFactory.h"
@implementation IJKPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    NSLog(@"viewId:1231323");
    IJKPlayerFactory* playerFactory = [[IJKPlayerFactory alloc] initWithMessenger:registrar.messenger];
    [registrar registerViewFactory:playerFactory withId:@"plugin.ugle.cn/piliplayer"];
    //[registrar publish:playerFactory];
}



@end
