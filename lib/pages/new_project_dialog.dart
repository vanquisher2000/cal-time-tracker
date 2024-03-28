import 'package:cal_time_tracker/appState.dart';
import 'package:cal_time_tracker/data/Task.dart';
import 'package:cal_time_tracker/data/event_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewCategoryDialog extends StatelessWidget {
  NewCategoryDialog({super.key, this.isParent = true, this.isTask = false});

  var eventName = "";
  final bool isParent;
  final bool isTask;

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
                        var event = EventData(name: eventName, duration: 0);
                        if (isParent) {
                          appState.events.add(event);
                        } else if (!isParent && !isTask) {
                          appState.currentParentEvent?.children.add(event);
                        } else {
                          //appState.subTasks.add(eventName);
                          //appState.subTasks[eventName] = [];
                          appState.tasks.add(Task(name: eventName));
                        }
                        appState.notifyListeners();
                        Navigator.pop(context);
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
