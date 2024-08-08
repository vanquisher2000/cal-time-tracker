import 'dart:async';

import 'package:flutter/material.dart';

class Task {
  String _name;
  String get name => _name;
  set name(String name) => _name = name;

  Timer? _timer;
  Timer? get timer => _timer;
  set timer(Timer? timer) => _timer = timer;

  int _seconds;
  int get seconds => _seconds;
  set seconds(int seconds) => _seconds = seconds;

  Duration timeElapsed = Duration.zero;
  Duration pausedTime = Duration.zero;
  DateTime startTime = DateTime(0);
  DateTime stopTime = DateTime(0);
  DateTime taskBeginTime = DateTime(0);
  String note = "";
  Key key = UniqueKey();

  bool isPaused = false;
  var lapsedHours = 0;
  var lapsedMinutes = 0.0;
  var lapsedSeconds = 0.0;
  bool finished = false;

  var fadeState = CrossFadeState.showFirst;

  Task({
    required String name,
    Timer? timer,
    int? seconds,
    bool? finished,
    String? beginTime,
    String? note,
    String? timeFinished,
  })  : _name = name,
        _timer = timer,
        _seconds = seconds ?? 0,
        taskBeginTime =
            beginTime == null ? DateTime(0) : DateTime.parse(beginTime),
        note = note ?? "",
        stopTime =
            timeFinished == null ? DateTime(0) : DateTime.parse(timeFinished),
        finished = finished ?? false;

  void start() {
    if (!finished) {
      startTime = DateTime.now();
      taskBeginTime =
          taskBeginTime == DateTime(0) ? DateTime.now() : taskBeginTime;
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        timeElapsed = DateTime.now().difference(startTime);
        update();
      });
    }
  }

  void pause() {
    if (!isPaused && !finished) {
      pausedTime = timeElapsed;
      timer?.cancel();
      isPaused = true;
      fadeState = CrossFadeState.showSecond;
      stopTime = DateTime.now();
    }
  }

  void resume() {
    if (isPaused && !finished) {
      pausedTime = pausedTime == Duration.zero
          ? Duration(seconds: _seconds)
          : pausedTime;
      debugPrint("paused time : $pausedTime");
      isPaused = false;
      startTime = DateTime.now();
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        timeElapsed = DateTime.now().difference(startTime) + pausedTime;
        update();
      });
    }
  }

  void update() {
    lapsedMinutes = timeElapsed.inSeconds / 60.0;
    lapsedSeconds = timeElapsed.inSeconds % 60;
    lapsedHours = timeElapsed.inMinutes ~/ 60;
    _seconds = timeElapsed.inSeconds;
    //_seconds++;
  }

  void stop() {
    stopTime = DateTime.now();
    timer?.cancel();
    finished = true;
  }

  String getFormattedDuration() {
    //_seconds = timeElapsed != Duration.zero ? timeElapsed.inSeconds : _seconds;
    var minutes = _seconds ~/ 60;
    var remainingSeconds = _seconds % 60;
    var hours = minutes ~/ 60;

    return "${hours.toFormattedString()}:${(minutes - hours * 60).toFormattedString()}:${remainingSeconds.toFormattedString()}";
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
        name: json["name"],
        seconds: json["seconds"],
        beginTime: json["beginTime"],
        note: json['note'],
        timeFinished: json["timeFinished"],
        finished: json["finished"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "seconds": _seconds,
      "finished": finished,
      "note": note,
      "beginTime": taskBeginTime.toString(),
      "timeFinished": stopTime.toString(),
    };
  }

  TextDecoration? getTextDecoration() {
    return finished ? TextDecoration.lineThrough : null;
  }

  double getOpacity() {
    return finished ? 0.0 : 1.0;
  }
}

extension IntExtensions on int {
  String toFormattedString() {
    return toString().padLeft(2, "0");
  }
}

extension DoubleExtensions on double {
  String toFormattedString() {
    return toInt().toString().padLeft(2, "0");
  }
}
