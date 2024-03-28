import 'dart:async';

import 'package:flutter/material.dart';

class Task {
  String _name;
  String get name => _name;
  set name(String name) => _name = name;

  Timer? _timer;
  Timer? get timer => _timer;
  set timer(Timer? timer) => _timer = timer;

  int seconds = 0;
  Duration timeElapsed = Duration.zero;
  Duration pausedTime = Duration.zero;
  DateTime startTime = DateTime(0);
  DateTime stopTime = DateTime(0);

  bool isPaused = false;
  var lapsedHours = 0;
  var lapsedMinutes = 0.0;
  var lapsedSeconds = 0.0;
  bool finished = false;

  var fadeState = CrossFadeState.showFirst;
  var opacity = 1.0;

  TextDecoration? taskTextDecoration;

  Task({required String name, Timer? timer})
      : _name = name,
        _timer = timer;

  void start() {
    if (!finished) {
      startTime = DateTime.now();
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
    }
  }

  void resume() {
    if (isPaused && !finished) {
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
    seconds++;
  }

  void stop() {
    stopTime = DateTime.now();
    timer?.cancel();
    finished = true;
  }

  String getFormattedDuration() {
    var seconds = timeElapsed.inSeconds;
    var minutes = seconds ~/ 60;
    var remainingSeconds = seconds % 60;
    var hours = minutes ~/ 60;

    return "${hours.toFormattedString()}:${(minutes - hours * 60).toFormattedString()}:${remainingSeconds.toFormattedString()}";
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
