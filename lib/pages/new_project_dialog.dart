import 'package:cal_time_tracker/appState.dart';
import 'package:cal_time_tracker/data/task.dart';
import 'package:cal_time_tracker/data/event_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewCategoryDialog extends StatelessWidget {
  NewCategoryDialog({super.key, this.isParent = true, this.isTask = false});

  var eventName = "";
  final bool isParent;
  final bool isTask;

  SnackBar snackBar(String eventName) {
    return SnackBar(
      backgroundColor:
          Colors.transparent, // Set background color to transparent
      elevation: 0, // Remove shadow
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Set border radius
      ),
      content: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 12.0,
        ),
        decoration: ShapeDecoration(
            color: Colors.grey.shade500, // Background color of the SnackBar
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // Set border radius
            ) // Border width
            ),
        child: Text(
          "$eventName already exists",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Dialog(
      child: Container(
        width: 300,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) => eventName = value,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: "Insert Category name...",
                  contentPadding: EdgeInsets.symmetric(horizontal: 24),
                  border: InputBorder.none,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (eventName.isNotEmpty) {
                        var exists = false;
                        var event = EventData(name: eventName, duration: 0);
                        if (isParent) {
                          if (appState
                              .checkForDoubles(event.name, appState.events)
                              .isEmpty) {
                            appState.events.add(event);
                          } else {
                            exists = true;
                          }
                        } else if (!isParent && !isTask) {
                          if (appState
                              .checkForDoubles(event.name,
                                  appState.currentParentEvent?.children ?? [])
                              .isEmpty) {
                            appState.currentParentEvent?.children.add(event);
                          } else {
                            exists = true;
                          }
                        } else {
                          //appState.subTasks.add(eventName);
                          //appState.subTasks[eventName] = [];
                          if (appState.checkForDoubleTasks(eventName).isEmpty) {
                            appState.tasks.add(Task(name: eventName));
                          } else {
                            exists = true;
                          }
                        }
                        if (exists) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(snackBar(eventName));
                        } else {
                          appState.notifyListeners();
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Text(
                      "Confirm",
                      style: TextStyle(color: Color.fromARGB(255, 23, 144, 85)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
