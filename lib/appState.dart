import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cal_time_tracker/data/task.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cal_time_tracker/controller/calendarController.dart';
import 'package:cal_time_tracker/controller/notificationController.dart';
import 'package:cal_time_tracker/data/event_data.dart';

/* extension IntExtensions on int {
  String toFormattedString() {
    return toString().padLeft(2, "0");
  }
}

extension DoubleExtensions on double {
  String toFormattedString() {
    return toInt().toString().padLeft(2, "0");
  }
} */

class MyAppState extends ChangeNotifier with WidgetsBindingObserver {
  MyAppState() {
    initPref();
    setColors();
  }
  AppLifecycleState? _lastLifecycleState;

  AppLifecycleState? get lastLifecycleState => _lastLifecycleState;

  LifecycleNotifier() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  var onGoingTaskIndex = -1;
  var currentEventInfo = "";
  var currentEventName = "";
  Duration elapsedTime = Duration.zero;
  List<EventData> events = [];
  var infoTextFieldController = TextEditingController();
  bool isInitialized = false;
  var lapsedHours = 0;
  var lapsedMinutes = 0.0;
  var lapsedSeconds = 0.0;
  late SharedPreferences sharedPreferences;
  DateTime startTime = DateTime(0);
  EventData? currentEvent;
  var canPop = true;
  var currentTask = "";
  var pausedTime = Duration.zero;
  var taskStartTime = DateTime(0);

  //Map<String, List<DateTime>> subTasks = {};

  List<Task> tasks = [];

  var heroMode = false;

  EventData? currentParentEvent;

  var stopTime = DateTime(0);
  var textFiledController = TextEditingController();
  late Timer timer;

  var currentSortMode = 0;

  var lastColorIndex = 0;
  var secondsColor = Colors.transparent;
  var minutesColor = Colors.transparent;
  var hourColor = Colors.transparent;

  void startTimer() {
    if (!isInitialized) {
      isInitialized = true;
      setColors();
      canPop = false;
      startTime = DateTime.now();
      LocalNotificationService.showNotificationAndroid(
        "${currentParentEvent?.name} $currentEventName OnGoing",
        "",
      );
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        elapsedTime = DateTime.now().difference(startTime);
        lapsedMinutes = elapsedTime.inSeconds / 60.0;
        lapsedSeconds = elapsedTime.inSeconds % 60;
        lapsedHours = elapsedTime.inMinutes ~/ 60;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void stopTimer(BuildContext context) {
    if (isInitialized) {
      timer.cancel();
      stopTime = DateTime.now();
      currentEvent = EventData(
          name: currentEventName,
          //duration: stopTime.difference(startTime).inSeconds,
          duration: getEventDuration(),
          eventInfo: generateEventInfo(),
          tasks: tasks);
      notifyListeners();
    }
  }

  void pushEvent(context) {
    if (currentEvent == null) return;
    addEvent(currentEvent!);
    CalendarController.addEvent(
      "${currentParentEvent?.name} : $currentEventName",
      generateEventInfo(),
      startTime,
      stopTime,
      context: context,
    );
    saveData();
    canPop = true;
    LocalNotificationService.flutterLocalNotificationsPlugin.cancelAll();
    //reset();
    notifyListeners();
  }

  void reset() {
    //if (startTime != DateTime(0)) {
    tasks = [];
    onGoingTaskIndex = -1;
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
    infoTextFieldController.clear();
    notifyListeners();
    //}
  }

  String taskTimeString(int index) {
    var time = tasks[index].getFormattedDuration();
    //if (isInitialized) notifyListeners();
    return time;
  }

  bool tasksFinished() {
    for (var task in tasks) {
      if (task.stopTime == DateTime(0) && task.startTime != DateTime(0)) {
        //return false;
        task.pause();
      }
    }
    notifyListeners();
    return true;
  }

  CrossFadeState getFadeState(int index) {
    notifyListeners();
    return tasks[index].fadeState;
  }

  void addEvent(EventData _event) {
    debugPrint("adding event : ${_event.name}");
    EventData? event = currentParentEvent?.children.firstWhere(
      (element) => element.name == _event.name,
    );
    /* for (var e in events) {
      if (e.name == _event.name) {
        event = e;
        break;
      }
    } */

    if (event != null) {
      //event.startTime = _event.startTime;
      //event.endTime = _event.endTime;
      event.eventInfo = _event.eventInfo;
      //event.duration = event.duration + _event.duration;
      event.duration = _event.duration;
      event.tasks = _event.tasks;
      debugPrint(
          "updating event : ${_event.name} , new duration : ${event?.duration}");
      //saveData();
    } else {
      debugPrint("adding new event : ${_event.name}");
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

  static void continueLastTask() {}
  String getFormattedDuration(int seconds) {
    var minutes = seconds ~/ 60;
    var remainingSeconds = seconds % 60;
    var hours = minutes ~/ 60;

    return "${hours.toFormattedString()}:${(minutes - hours * 60).toFormattedString()}:${remainingSeconds.toFormattedString()}";
  }

  String generateEventInfo() {
    var ret = "";
    tasks?.forEach((element) {
      if (element.startTime.isAfter(startTime) ||
          element.startTime.isAtSameMomentAs(startTime)) {
        ret +=
            "${element.name} : ${element.getFormattedDuration()} , ${getTimeFormatted(element.startTime)} -> ${getTimeFormatted(element.stopTime)}\n";
      }
    });
    return ret;
  }

  int getEventDuration() {
    var sum =
        tasks.map((t) => t.seconds).reduce((value, element) => element + value);
    debugPrint("current sum is ${sum}");
    return sum;
  }

  void getTasks(List<Task>? list) {
    tasks = [];
    list?.forEach((element) => tasks?.add(element));
  }

  Future<void> initPref() async {
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
      debugPrint("loaded events ${events.length}");
      notifyListeners();
    }
  }

  void saveData() {
    List<String> eventDataString =
        events.map((e) => jsonEncode(e.toJson())).toList();
    sharedPreferences.setStringList("eventList", eventDataString);
    debugPrint("data saved");
  }

  void loadTempData() {
    List<String>? tempData = sharedPreferences.getStringList("tempData");
    if (tempData != null) {
      if (tempData[0].isNotEmpty) {
        EventData? tempParentEvent = events.firstWhere(
          (element) => element.name == tempData[0],
        );
        currentParentEvent = tempParentEvent;
      }
      if (tempData[1].isNotEmpty) {
        currentEvent = currentParentEvent!.children
            .firstWhere((element) => element.name == tempData[1]);
      }
      if (tempData[2] != "-1") {
        onGoingTaskIndex = int.parse(tempData[2]);
        startTime = DateTime.parse(tempData[3]);
      }
    }
    debugPrint("temp data loaded ${tempData} , ${currentEvent?.name}  ");
  }

  void saveTempData() {
    List<String> tempData = [
      currentParentEvent?.name ?? "",
      currentEventName,
      onGoingTaskIndex.toString(),
      startTime.toString()
    ];
    sharedPreferences.setStringList("tempData", tempData);
    debugPrint("temp data saved");
  }

  List<EventData> getEvents(String searchValue) {
    if (searchValue.isEmpty) {
      return events;
    } else {
      return events.where((element) {
        if (element.name.toLowerCase().contains(searchValue.toLowerCase())) {
          return true;
        } else if (element.children
            .where((child) =>
                child.name.toLowerCase().contains(searchValue.toLowerCase()))
            .isNotEmpty) {
          return true;
        } else {
          return false;
        }
      }).toList();
    }
  }

  List<EventData> checkForDoubles(String name, List<EventData> list) {
    return list.where((element) {
      if (element.name == name) {
        return true;
      } else {
        return false;
      }
    }).toList();
  }

  List<Task> checkForDoubleTasks(String name) {
    return tasks.where((element) {
      if (element.name == name) {
        return true;
      } else {
        return false;
      }
    }).toList();
  }

  void sortList() {
    if (currentSortMode > 3) currentSortMode = 0;
    switch (currentSortMode) {
      case 0:
        events.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 1:
        events.sort(
            (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case 2:
        events.sort((a, b) => a.duration.compareTo(b.duration));
        break;
      case 3:
        events.sort((a, b) => b.duration.compareTo(a.duration));
        break;
    }
    debugPrint("sort mode : $currentSortMode");
    currentSortMode++;
  }

  Color getRandomColor() {
    Random random = Random();
    var index = random.nextInt(backgroundColors.length);
    while (index == lastColorIndex) {
      index = random.nextInt(backgroundColors.length);
    }
    lastColorIndex = index;
    return backgroundColors[index];
  }

  void setColors() {
    secondsColor = getRandomColor();
    minutesColor = getRandomColor();
    hourColor = getRandomColor();
    while (minutesColor == secondsColor) {
      minutesColor = getRandomColor();
    }
    while (hourColor == secondsColor || hourColor == minutesColor) {
      hourColor = getRandomColor();
    }
  }

  String getStartTimeFormatted() {
    //if (startTime == DateTime(0)) return "";
    return "${startTime.hour.toFormattedString()}:${startTime.minute.toFormattedString()}:${startTime.second.toFormattedString()}";
  }

  String getEndTimeFormatted() {
    //if (stopTime == DateTime(0)) return "";
    return "${stopTime.hour.toFormattedString()}:${stopTime.minute.toFormattedString()}:${stopTime.second.toFormattedString()}";
  }

  String getTimeFormatted(DateTime time) {
    //if (stopTime == DateTime(0)) return "";
    return "${time.hour.toFormattedString()}:${time.minute.toFormattedString()}:${time.second.toFormattedString()}";
  }

  String getDateFormatted(DateTime time) {
    //if (stopTime == DateTime(0)) return "";
    return "${time.year}/${time.month.toFormattedString()}/${time.day.toFormattedString()}";
  }
}
