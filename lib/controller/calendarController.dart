import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';

class CalendarController {
  static DeviceCalendarPlugin? _deviceCalendarPlugin;
  static List<Calendar> calendars = [];
  static Calendar? defaultCalendar;
  static Future<bool> resultBool = Future.value(false);

  static init() {
    print("initializing device calendar plugin");
    _deviceCalendarPlugin = DeviceCalendarPlugin();
  }

  static void retrieveCalendars() async {
    //Retrieve user's calendars from mobile device
    //Request permissions first if they haven't been granted
    if (_deviceCalendarPlugin != null) {
      try {
        var permissionsGranted = await _deviceCalendarPlugin!.hasPermissions();
        if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
          permissionsGranted =
              await _deviceCalendarPlugin!.requestPermissions();
          if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
            return;
          }
        }

        final calendarsResult =
            await _deviceCalendarPlugin!.retrieveCalendars();
        calendars = (calendarsResult.data != null)
            ? calendarsResult.data!.toList()
            : [];
        defaultCalendar =
            calendars.firstWhere((element) => element.isDefault ?? false);

        print(defaultCalendar!.name);
      } catch (e) {
        print(e);
      }
    } else {
      print("Device Calendar Plugin not initialized");
    }
  }

  static Future<void> addEvent(
      String name, String description, DateTime _startTime, DateTime _endTime,
      {required BuildContext context}) async {
    var start = TZDateTime.local(_startTime.year, _startTime.month,
        _startTime.day, _startTime.hour, _startTime.minute, _startTime.second);

    var end = TZDateTime.local(_endTime.year, _endTime.month, _endTime.day,
        _endTime.hour, _endTime.minute, _endTime.second);

    var offset = _startTime.timeZoneOffset;
    var lag = _startTime.compareTo(start.copyWith());
    var localStart = (lag < 1) ? start.subtract(offset) : start.add(offset);
    var localEnd = (lag < 1) ? end.subtract(offset) : end.add(offset);

    print(
        "making event at $start , $localStart , $end , $localEnd , lag : $lag , coming :$_startTime");

    final event = Event(
      defaultCalendar!.id,
      title: name,
      description: description,
      //start: TZDateTime.local(2024, 2, 27, 18, 0),
      start: localStart,
      end: localEnd,
    );

    final result = await DeviceCalendarPlugin().createOrUpdateEvent(event);
    if (result == null) {
      return;
    }
    if (result.isSuccess) {
      //resultBool = Future.value(true);
      print("Event created!!!!!!!!");
      showResultSnackBar(context, "event: $name created");
      return;
    }

    if (!result.hasErrors) {
      //resultBool = Future.value(false);
      return;
    }

    throw Exception(result.errors.join());
  }

  static Future<void> showResultSnackBar(
      BuildContext context, String message) async {
    final snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    /* var result = await resultBool;
    if (result) {
      final snackBar = SnackBar(
        content: Text(message),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      resultBool = Future.value(false);
    } else {
      const snackBar = SnackBar(
        content: Text("failed to push event"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } */
  }
}
