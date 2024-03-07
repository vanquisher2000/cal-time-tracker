import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cal_time_tracker/controller/calendarController.dart';
import 'package:cal_time_tracker/controller/notificationController.dart';
import 'package:cal_time_tracker/data/EventData.dart';

extension IntExtensions on int {
  String toFormatedString() {
    return toString().padLeft(2, "0");
  }
}

extension DoubleExtensions on double {
  String toFormatedString() {
    return toInt().toString().padLeft(2, "0");
  }
}

class MyAppState extends ChangeNotifier {
  MyAppState() {
    initPrefs();
  }

  var currentEventInfo = "";
  var currentEventName = "";
  Duration elapsedTime = Duration.zero;
  List<EventData> events = [];
  var infoTextFeildController = TextEditingController();
  bool isInitialized = false;
  var lapsedHours = 0;
  var lapsedMinutes = 0;
  var lapsedSeconds = 0;
  late SharedPreferences sharedPreferences;
  DateTime startTime = DateTime(0);
  EventData? currentEvent;
  var canPop = true;

  var heroMode = false;

  EventData? currentParentEvent;

  var stopTime = DateTime(0);
  var textFiledController = TextEditingController();
  late Timer timer;

  void startTimer() {
    // setState(() {
    if (!isInitialized) {
      //LocalNotificationService.showNotificationAndroid("timer", lapsedSeconds.toFormatedString());

      isInitialized = true;
      canPop = false;
      startTime = DateTime.now();
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        elapsedTime = DateTime.now().difference(startTime);
        lapsedMinutes = elapsedTime.inSeconds ~/ 60;
        lapsedSeconds = elapsedTime.inSeconds % 60;
        lapsedHours = elapsedTime.inMinutes ~/ 60;
        LocalNotificationService.showNotificationAndroid(
          "$currentEventName : ${getFormatedDuration(elapsedTime.inSeconds)}",
          "elapsed Time: ${getFormatedDuration(elapsedTime.inSeconds)}",
        );

        // showNotification();
        notifyListeners();
      });
    }
    notifyListeners();
    // });
  }

  void stopTimer(BuildContext context) {
    if (isInitialized) {
      timer.cancel();
      stopTime = DateTime.now();

      //isInitialized = false;
      currentEvent = EventData(
          name: currentEventName,
          //startTime: startTime,
          //endTime: stopTime,
          duration: stopTime.difference(startTime).inSeconds,
          eventInfo: currentEventInfo);
      //events.add(result);
      /* addEvent(currentEvent!);
      CalendarController.addEvent(
        currentEventName,
        currentEventInfo,
        startTime,
        stopTime,
        context: context,
      );
      saveData(); */
      notifyListeners();
    }
  }

  void pushEvent(context) {
    if (currentEvent == null) return;
    addEvent(currentEvent!);
    CalendarController.addEvent(
      "${currentParentEvent?.name} : $currentEventName",
      currentEventInfo,
      startTime,
      stopTime,
      context: context,
    );
    saveData();
    canPop = true;
    LocalNotificationService.flutterLocalNotificationsPlugin.cancelAll();
    notifyListeners();
  }

  void reset() {
    //if (startTime != DateTime(0)) {
    currentEvent = null;
    currentParentEvent = null;
    canPop = true;
    startTime = DateTime(0);
    elapsedTime = Duration.zero;
    stopTime = DateTime(0);
    if (isInitialized) timer.cancel();
    isInitialized = false;
    //events = [];
    currentEventName = "";
    lapsedMinutes = 0;
    lapsedSeconds = 0;
    lapsedHours = 0;
    currentEventInfo = "";
    currentEventName = "";
    textFiledController.clear();
    infoTextFeildController.clear();
    notifyListeners();
    //}
  }

  void addEvent(EventData _event) {
    print("adding event : ${_event.name}");
    EventData? event = currentParentEvent?.children.firstWhere(
      (element) => element.name == _event.name,
      orElse: () => EventData(
        name: "",
        //startTime: DateTime(0),
        //endTime: DateTime(0),
        duration: 0,
      ),
    );
    /* for (var e in events) {
      if (e.name == _event.name) {
        event = e;
        break;
      }
    } */

    if (event?.duration != 0) {
      //event.startTime = _event.startTime;
      //event.endTime = _event.endTime;
      event?.eventInfo = _event.eventInfo;
      event?.duration = event.duration + _event.duration;
      print(
          "updating event : ${_event.name} , new duration : ${event?.duration}");
      //saveData();
    } else {
      print("adding new event : ${_event.name}");
      currentParentEvent?.children.add(_event);
      //saveData();
    }
    debugPrint("old total duration ${currentParentEvent?.duration}");
    if (currentParentEvent != null) {
      currentParentEvent!.duration =
          currentParentEvent!.duration + _event.duration;
    }
    debugPrint("new total duration ${currentParentEvent?.duration}");
  }

  String getFormatedDuration(int seconds) {
    var minutes = seconds ~/ 60;
    var remainingSeconds = seconds % 60;
    var hours = minutes ~/ 60;

    return "${hours.toFormatedString()}:${(minutes - hours * 60).toFormatedString()}:${remainingSeconds.toFormatedString()}";
  }

  /* void showNotification() {
    NotificationController.showNotification(
        title:
            "$currentEventName : ${getFormatedDuration(elapsedTime.inSeconds)}",
        body: "running Timer: ${getFormatedDuration(elapsedTime.inSeconds)}",
        payload: {
          "notificationId": "1",
        },
        actionButtons: [
          NotificationActionButton(
            key: "DISMISS",
            label: "Dismiss",
            actionType: ActionType.SilentAction,
            color: Colors.red,
          ),
          NotificationActionButton(
              key: "SNOOZE",
              label: "Snooze",
              actionType: ActionType.SilentAction),
        ]);
  } */

  Future<void> initPrefs() async {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
    } catch (e) {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
    }
    loadData();
  }

  void loadData() {
    List<String>? eventDataString =
        sharedPreferences.getStringList("eventList");
    if (eventDataString != null) {
      events = eventDataString
          .map(
            (e) => EventData.fromJson(jsonDecode(e)),
          )
          .toList();
      print("loaded events ${events.length}");
      notifyListeners();
    }
  }

  void saveData() {
    List<String> eventDataString =
        events.map((e) => jsonEncode(e.toJson())).toList();
    sharedPreferences.setStringList("eventList", eventDataString);
  }
}
