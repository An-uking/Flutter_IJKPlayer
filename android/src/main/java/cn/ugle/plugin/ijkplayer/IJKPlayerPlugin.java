package cn.ugle.plugin.ijkplayer;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

/** IjkplayerPlugin */
public class IJKPlayerPlugin {
    /** Plugin registration. */
    public static void registerWith(PluginRegistry.Registrar registrar) {
        registrar.platformViewRegistry().registerViewFactory("plugin.ugle.cn/piliplayer", new IJKPlayerFactory(registrar.messenger()));
    }
}