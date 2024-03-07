import 'dart:convert';

class DataClass {
  int _intValue;
  String _stringValue;

  int get intValue => _intValue;
  set intValue(int value) => _intValue = value;

  String get stringValue => _stringValue;
  set stringValue(String value) => _stringValue = value;

  DataClass({
    int intValue = 0,
    required String stringValue,
  })  : _intValue = intValue,
        _stringValue = stringValue;
}

class EventData {
//final DateTime endTime;
  String _name;
  String _eventInfo;
  bool _isExpanded;
  List<EventData> _children;

  //final DateTime startTime;
  int _duration;

  int get duration => _duration;
  set duration(int duration) => _duration = duration;

  String get name => _name;
  set name(String name) => _name = name;

  String get eventInfo => _eventInfo;
  set eventInfo(String eventInfo) => _eventInfo = eventInfo;

  bool get isExpanded => _isExpanded;
  set isExpanded(bool value) => _isExpanded = value;

  List<EventData> get children => _children;

  void addChild(EventData child) => _children.add(child);

  /* set eventInfo(String eventInfo) {
    this.eventInfo = eventInfo;
  }

  set name(String name) {
    this.name = name;
  }

  set startTime(DateTime startTime) {
    this.startTime = startTime;
  }

  set endTime(DateTime endTime) {
    this.endTime = endTime;
  }

  set duration(int duration) {
    this.duration = duration;
  } */

  EventData({
    required String name,
    //required this.startTime,
    //required this.endTime,
    required int duration,
    String eventInfo = "",
    bool isExpanded = false,
    List<EventData>? children,
  })  : _name = name,
        _duration = duration,
        _eventInfo = eventInfo,
        _isExpanded = isExpanded,
        _children = children ?? [];

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
        name: json["name"],
        //startTime: DateTime.parse(json["startTime"]),
        //endTime: DateTime.parse(json["endTime"]),
        duration: json["duration"],
        eventInfo: json["eventInfo"],
        isExpanded: json["isExpanded"],
        children: (json["children"] as List<dynamic>)
            .map((e) => EventData.fromJson(jsonDecode(e)))
            .toList());
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      //"startTime": startTime.toString(),
      //"endTime": endTime.toIso8601String(),
      "duration": duration,
      "eventInfo": eventInfo,
      "isExpanded": isExpanded,
      "children": _children.map((e) => jsonEncode(e.toJson())).toList(),
    };
  }

  List<String> saveData() {
    return _children.map((e) => jsonEncode(e.toJson())).toList();
  }
}
