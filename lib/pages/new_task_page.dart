import 'package:cal_time_tracker/appState.dart';
import 'package:cal_time_tracker/data/task.dart';
import 'package:cal_time_tracker/pages/new_project_dialog.dart';
import 'package:cal_time_tracker/pages/task_page_dialogs.dart';
import 'package:cal_time_tracker/pages/timer_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewTaskPage extends StatefulWidget {
  const NewTaskPage({super.key});

  @override
  State<StatefulWidget> createState() => _NewTaskPage();
}

class _NewTaskPage extends State<NewTaskPage> {
  //_NewTaskPage();
  var isPaused = false;
  final animationDuration = const Duration(milliseconds: 500);
  var icon = const Icon(Icons.play_arrow_outlined);

  SnackBar snackBar({required String message}) {
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
  }

  void startEvent(appState) {
    appState.startTimer();
    setState(() {
      icon = const Icon(Icons.stop_circle);
    });
  }

  /* @override
  void initState() {
    super.initState();
    //var appState = context.watch<MyAppState>();
  } */

  /* void pauseTasks(List<Task> tasks) {
    setState(() {
      for (var task in tasks) {
        if (task.stopTime == DateTime(0) && task.startTime != DateTime(0)) {
          task.fadeState = CrossFadeState.showSecond;
        }
      }
    });
  } */

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: appState.currentTask,
            style: theme.textTheme.displaySmall,
          ),
        ),
      ),
      body: PopScope(
        canPop: appState.canPop,
        onPopInvoked: ((didPop) {
          if (didPop) {
            appState.heroMode = true;
            //appState.notifyListeners();
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
        }),
        child: Column(
          children: [
            //TimerCard(),
            IconButton(
              onPressed: () {
                if (!appState.isInitialized) {
                  startEvent(appState);
                } else if (appState.isInitialized &&
                    appState.stopTime == DateTime(0)) {
                  if (appState.tasksFinished()) {
                    appState.stopTimer(context);
                    //pauseTasks(appState.tasks);
                    setState(() {
                      icon = const Icon(Icons.backup_outlined);
                      for (var task in appState.tasks) {
                        if (!task.finished && task.startTime != DateTime(0)) {
                          task.pause();
                          setState(() {
                            task.fadeState = CrossFadeState.showFirst;
                          });
                        }
                      }
                    });
                  } else {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(snackBar(message: "finish Tasks first"));
                  }
                } else {
                  appState.pushEvent(context);
                  appState.canPop = true;
                  Navigator.of(context).pop();
                }
              },
              icon: icon,
              iconSize: 48,
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: appState.tasks.length,
                itemBuilder: (context, index) {
                  //var key = appState.subTasks.keys.elementAt(index);
                  //var taskTime = appState.subTasks[key];
                  var task = appState.tasks[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: task.name,
                              style: //theme.textTheme.headlineSmall
                                  TextStyle(
                                      decoration: task.getTextDecoration(),
                                      color:
                                          theme.brightness == Brightness.light
                                              ? Colors.black
                                              : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                            ),
                            maxLines: 4,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          RichText(
                            text: TextSpan(
                                text: task.getFormattedDuration(),
                                style: theme.textTheme.bodyMedium),
                            maxLines: 4,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          AnimatedOpacity(
                            opacity: task.getOpacity(),
                            duration: animationDuration,
                            child: AnimatedCrossFade(
                              firstChild: IconButton(
                                onPressed: () {
                                  if (appState.stopTime == DateTime(0)) {
                                    if (!appState.isInitialized) {
                                      startEvent(appState);
                                    }
                                    if (task.startTime == DateTime(0) &&
                                        task.seconds == 0) {
                                      task.start();
                                    } else {
                                      task.isPaused = true;
                                      task.resume();
                                    }

                                    setState(() {
                                      task.fadeState =
                                          CrossFadeState.showSecond;
                                    });
                                    appState.canPop = false;
                                  }
                                },
                                icon: const Icon(Icons.play_arrow),
                              ),
                              secondChild: IconButton(
                                onPressed: () {
                                  task.pause();
                                  setState(() {
                                    task.fadeState = CrossFadeState.showFirst;
                                  });
                                },
                                icon: const Icon(Icons.pause),
                              ),
                              crossFadeState: task.fadeState,
                              duration: animationDuration,
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: task.getOpacity(),
                            duration: animationDuration,
                            child: IconButton(
                              onPressed: () {
                                if (task.timer != null) {
                                  setState(() {
                                    task.stop();
                                  });
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar(
                                    message: "task hasn't started yet",
                                  ));
                                }
                              },
                              icon: const Icon(Icons.stop),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
      ),
    );
  }
}

class CustomBorder extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _createPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return this;
  }

  Path _createPath(Rect rect) {
    final path = Path();
    final width = rect.width;
    final height = rect.height;

    path.moveTo(0, height / 2);
    path.quadraticBezierTo(width * 0.2, height, width * 0.5, height);
    path.quadraticBezierTo(width * 0.8, height, width, height / 2);
    path.lineTo(width, 0);
    path.lineTo(0, 0);
    path.close();

    return path;
  }
}
