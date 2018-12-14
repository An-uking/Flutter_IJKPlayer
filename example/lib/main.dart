import 'package:flutter/material.dart';
import 'package:ijkplayer/flutter_ijkplayer.dart';
import 'package:after_layout/after_layout.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(new MaterialPageRoute(builder: (ctx) => VideoPage()));
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class VideoPage extends StatefulWidget {
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> with AfterLayoutMixin<VideoPage>{
  PiliPlayerController _playerController;
  bool _flag=false;
  @override
  void initState() {
    // TODO: implement initState

    //print(ss);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _playerController.dispose();
    super.dispose();
  }
  @override
  void afterFirstLayout(BuildContext context) {
    // TODO: implement afterFirstLayout
    setState(() {
          _flag=true;
        });
  }

  void _onPlayerCreated(PiliPlayerController controller) {
    _playerController = controller;
    //_playerController.setBufferingEnabled(flag)
  }

  // public static final int OPT_CATEGORY_FORMAT = 1;
  // public static final int OPT_CATEGORY_CODEC = 2;
  // public static final int OPT_CATEGORY_SWS = 3;
  // public static final int OPT_CATEGORY_PLAYER = 4;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 250,
              color: Color(0xFF000000),
              child: PiliPlayer(
                url: "http://img.ksbbs.com/asset/Mon_1703/05cacb4e02f9d9e.mp4",
                onPlayerCreated: _onPlayerCreated,
                auto: false,
                isLive: false,
                options: {
                    "4": {"start-on-prepared": "0","enable-accurate-seek":"1"},
                    "1": {"analyzemaxduration": "100"},
                  },
              ),
            ),
            RaisedButton(
              onPressed: () {
                _playerController.play();
              },
              child: Center(
                child: Text("play"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
