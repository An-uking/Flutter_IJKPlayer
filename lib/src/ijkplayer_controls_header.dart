part of flutter_ijkplayer;

class PiliPlayerControlHeader extends StatefulWidget {
  @override
  _PiliPlayerControlHeaderState createState() => _PiliPlayerControlHeaderState();
}

class _PiliPlayerControlHeaderState extends State<PiliPlayerControlHeader> {
  final barHeight = 35.0;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: barHeight,
      child: Row(
        children: <Widget>[

        ],
      ),
    );
  }
    GestureDetector _goBackButton(PiliPlayerController controller) {
    return new GestureDetector(
      onTap: (){
        Navigator.of(context).pop();
      },
      child: new Container(
        color: Colors.transparent,
        margin: new EdgeInsets.only(right: 10.0),
        child: Icon(Icons.keyboard_arrow_left,color: Color(0xFFFFFFFF),),
      ),
    );
  }
}