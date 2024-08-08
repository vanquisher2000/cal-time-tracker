import 'dart:convert';

import 'package:cal_time_tracker/data/task.dart';
import 'package:flutter/material.dart';

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
  List<Task> _tasks;

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

  List<Task> get tasks => _tasks;
  void addTask(Task task) => _tasks.add(task);
  set tasks(List<Task> tasks) => _tasks = tasks;

  var lastUsed = DateTime(0);

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

  EventData(
      {required String name,
      //required this.startTime,
      //required this.endTime,
      required int duration,
      String eventInfo = "",
      bool isExpanded = false,
      List<EventData>? children,
      List<Task>? tasks,
      String? strLastUsed})
      : _name = name,
        _duration = duration,
        _eventInfo = eventInfo,
        _isExpanded = isExpanded,
        lastUsed =
            strLastUsed == null ? DateTime(0) : DateTime.parse(strLastUsed),
        _children = children ?? [],
        _tasks = tasks ?? [];

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
        name: json["name"],
        //startTime: DateTime.parse(json["startTime"]),
        //endTime: DateTime.parse(json["endTime"]),
        duration: json["duration"],
        eventInfo: json["eventInfo"],
        isExpanded: json["isExpanded"],
        strLastUsed: json["lastUsed"],
        children: (json["children"] as List<dynamic>)
            .map((e) => EventData.fromJson(jsonDecode(e)))
            .toList(),
        tasks: (json["tasks"] as List<dynamic>)
            .map((e) => Task.fromJson(jsonDecode(e)))
            .toList());
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "duration": duration,
      "eventInfo": eventInfo,
      "isExpanded": isExpanded,
      "lastUsed": lastUsed.toString(),
      "children": _children.map((e) => jsonEncode(e.toJson())).toList(),
      "tasks": _tasks.map((e) => jsonEncode(e.toJson())).toList(),
    };
  }

  List<String> saveData() {
    return _children.map((e) => jsonEncode(e.toJson())).toList();
  }
}

List<Color> backgroundColors = [
  const Color(0xFFCCE5FF), //• light•blue
  const Color(0xFFCCE5FF), //• light•blue
  const Color(0xFFD7F9E9), // pale green
  const Color(0xFFFFF8E1), // pale yellow
  const Color(0xFFF5E6CC), //beige
  const Color(0xFFE5E5E5), // light grey
  const Color(0xFFFFF0F0), // pale pink
  const Color(0xFFE6F9FF), // pale blue
  const Color(0xFFD4EDDA), // mint green
  const Color(0xFFFFF3CD), // pale orange,
];
