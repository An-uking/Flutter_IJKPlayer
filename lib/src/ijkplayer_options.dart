part of flutter_ijkplayer;

enum IJKOptionType{
  OPT_CATEGORY_UNKNOW,
  OPT_CATEGORY_FORMAT,
  OPT_CATEGORY_CODEC,
  OPT_CATEGORY_SWS,
  OPT_CATEGORY_PLAYER
}
class IJKPlayerOption{
  final Map<IJKOptionType,List<IJKeyValue>> kv;
  IJKPlayerOption({this.kv});
}
class IJKeyValue{
  String key;
  int value;
}