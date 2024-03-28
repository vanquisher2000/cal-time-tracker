import 'package:cal_time_tracker/pages/new_task_page.dart';
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
      showResultSnackBar(context, "event: $name created", color: Colors.green);
      return;
    }

    if (!result.hasErrors) {
      //resultBool = Future.value(false);
      showResultSnackBar(context, "event: $name failed to create!!!");
      return;
    }

    throw Exception(result.errors.join());
  }

  static Future<void> showResultSnackBar(
    BuildContext context,
    String message, {
    Color color = Colors.red,
  }) async {
    var animatedSnackBar = SnackBar(
      backgroundColor: color, // Set background color to transparent
      elevation: 0, // Remove shadow
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Set border radius
      ),
      content: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 12.0,
        ),
        decoration: ShapeDecoration(
            //color: Colors.grey.shade500, // Background color of the SnackBar
            shape: CustomBorder() // Border width
            ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
      ),
    );
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(animatedSnackBar);
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
