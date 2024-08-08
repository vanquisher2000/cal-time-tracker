import 'dart:ffi';

import 'package:cal_time_tracker/appState.dart';
import 'package:cal_time_tracker/data/task.dart';
import 'package:cal_time_tracker/pages/new_project_dialog.dart';
import 'package:cal_time_tracker/pages/task_page_dialogs.dart';
import 'package:cal_time_tracker/pages/task_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cal_time_tracker/Utils/Colors.dart';
import 'package:wakelock/wakelock.dart';
import 'package:screen_brightness/screen_brightness.dart';

class TaskStack extends StatefulWidget {
  @override
  State<TaskStack> createState() => _TaskStack();
}

class _TaskStack extends State<TaskStack> {
  String FormattedTimeString(DateTime time) {
    return "${time.hour}:${time.minute}:${time.second}";
  }

  bool _isExpandText = false;
  void toggleExpanded() {
    setState(() {
      _isExpandText =
          !_isExpandText; // first click expand second click back to same position
    });
  }

  var align = MainAxisAlignment.spaceEvenly;

  bool _moveButtonRight = false;

  double opacity = 0.0;
  var isPaused = false;
  final animationDuration = const Duration(milliseconds: 500);
  var icon = const Icon(Icons.play_arrow_outlined);

  void showPushButton() {
    setState(() {
      opacity = 1.0;
      align = MainAxisAlignment.spaceBetween;
      _moveButtonRight = true;
    });
  }

  @override
  void dispose() {
    Wakelock.disable();
    super.dispose();
  }

  Future<void> _setBrightness(double brightness) async {
    double brightness;
    try {
      brightness = await ScreenBrightness().current;
      debugPrint("bringhtness is ${brightness}");
    } catch (e) {
      brightness = 0.5;
    }
    try {
      await ScreenBrightness().setScreenBrightness(brightness);
    } catch (e) {
      print('Error setting brightness: $e');
    }
  }

  List<Task> sortList(List<Task> tasks) {
    List<Task> ret = List.from(tasks);
    ret.sort((a, b) => b.stopTime.compareTo(a.stopTime));
    ret.sort((a, b) => a.finished == b.finished ? 0 : (a.finished ? 1 : -1));
    return ret;
  }

  List<Key> keys = [];
  void generateKeys(int count) {
    for (int i = 0; i < count; i++) {
      keys.add(UniqueKey());
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var width = MediaQuery.of(context).size.width;
    //var tasks = sortList(appState.tasks);
    var tasks = appState.tasks;
    //if (keys.isEmpty) generateKeys(tasks.length);
    List<Widget> taskList = [];
    //sortList(tasks);
    //for (int i = 0; i < tasks.length; i++) {
    for (int i = tasks.length - 1; i >= 0; i--) {
      taskList.add(Container(
          key: tasks[i].key,
          child: TaskWidget(
              task: tasks[i], index: i, showButton: showPushButton)));
    }
    return Scaffold(
      body: PopScope(
        canPop: appState.canPop,
        onPopInvoked: (didPop) {
          if (didPop) {
            appState.heroMode = true;
            return;
          }
          if (didPop) {
            debugPrint("trying to pop");
            Navigator.of(context).pop();
            Navigator.popUntil(context, ModalRoute.withName("ProjectPage"));
            debugPrint("popped");
          } else {
            if (appState.isInitialized) {
              showDialog(
                  context: context,
                  builder: (context) => const timerIsOnDialog());
            } else {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.popUntil(context, ModalRoute.withName("/"));
            }
          }
        },
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //const SizedBox(height: 580),
                        Text(
                          appState.currentParentEvent?.name ?? "",
                          style: TextStyle(
                            fontSize: 60,
                            color: primaryTextColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        AnimatedSize(
                          duration: Duration(seconds: 1),
                          child: Row(
                            //crossAxisAlignment: CrossAxisAlignment.center,
                            //mainAxisSize: MainAxisSize.min,
                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: width / 2,
                                child: Text(
                                  appState.currentEventName,
                                  style: TextStyle(
                                    fontSize: 35,
                                    fontWeight: FontWeight.w500,
                                    color: primaryTextColor,
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(seconds: 1),
                                curve: Curves.bounceInOut,
                                margin: EdgeInsets.only(
                                    left: _moveButtonRight
                                        ? width -
                                            (width / 2 +
                                                //(width * 0.1) +
                                                60 +
                                                36 +
                                                16)
                                        : 0.0),
                                child: AnimatedOpacity(
                                  duration: animationDuration,
                                  opacity: opacity,
                                  child: IconButton(
                                    onPressed: () {
                                      appState.stopTimer(context);
                                      //pauseTasks(appState.tasks);
                                      setState(() {
                                        //icon = const Icon(Icons.backup_outlined);
                                        for (var task in appState.tasks) {
                                          if (!task.finished &&
                                              task.startTime != DateTime(0)) {
                                            task.pause();
                                            setState(() {
                                              task.fadeState =
                                                  CrossFadeState.showFirst;
                                            });
                                          }
                                        }
                                      });
                                      appState.pushEvent(context);
                                      appState.canPop = true;
                                      Navigator.of(context).pop();
                                    },
                                    icon: const Icon(Icons.backup_outlined),
                                    iconSize: 36,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //const SizedBox(height: 5),
                        const Divider(
                          color: Colors.white,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              child: const Icon(
                                Icons.dark_mode,
                                size: 42,
                              ),
                              onTap: () {
                                setState(() {
                                  //_setBrightness(0.01);
                                });
                                //ScreenBrightness.instance.setScreenBrightness(0.05);
                              },
                            ),
                            GestureDetector(
                              child: const Icon(
                                Icons.add,
                                size: 42,
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => NewCategoryDialog(
                                    isParent: false,
                                    isTask: true,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        ...taskList,
                        /* Expanded(
                          child: ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.all(8.0),
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.green,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                key: Key(tasks[index].name),
                                child: TaskWidget(
                                  index: index,
                                  task: tasks[index],
                                  showButton: showPushButton,
                                ),
                              );
                            },
                          ),
                        ) */
                      ],
                    ),
                  )
                ],
              ))
            ],
          ),
        ),
      ),
      /* floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => NewCategoryDialog(
              isParent: false,
              isTask: true,
            ),
          );
        },
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ), */
    );
  }
}
