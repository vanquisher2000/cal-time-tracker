import 'package:cal_time_tracker/appState.dart';
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

  var snackBar = SnackBar(
    backgroundColor: Colors.transparent, // Set background color to transparent
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
      child: const Text(
        "finish tasks first",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        ),
      ),
    ),
  );

  void startEvent(appState) {
    appState.startTimer();
    setState(() {
      icon = const Icon(Icons.stop_circle);
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: appState.currentTask,
            style: const TextStyle(
                //color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24),
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
            Navigator.popUntil(context, ModalRoute.withName("/"));
            debugPrint("popped");
          } else {
            if (appState.isInitialized) {
              showDialog(
                  context: context,
                  builder: (context) => const timerIsOnDialog());
            } else {
              Navigator.of(context).pop();
              Navigator.popUntil(context, ModalRoute.withName("/"));
            }
          }
        }),
        child: Column(
          children: [
            const TimerCard(),
            IconButton(
              onPressed: () {
                if (!appState.isInitialized) {
                  startEvent(appState);
                } else if (appState.isInitialized &&
                    appState.stopTime == DateTime(0)) {
                  if (appState.tasksFinished()) {
                    appState.stopTimer(context);
                    setState(() {
                      icon = const Icon(Icons.backup_outlined);
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: task.name,
                                style: TextStyle(
                                  decoration: task.taskTextDecoration,
                                  //color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              maxLines: 4,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            RichText(
                              text: TextSpan(
                                text: task.getFormattedDuration(),
                                style: const TextStyle(
                                  //color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              maxLines: 4,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            AnimatedOpacity(
                              opacity: task.opacity,
                              duration: animationDuration,
                              child: AnimatedCrossFade(
                                firstChild: IconButton(
                                  onPressed: () {
                                    //appState.startTimer();
                                    //appState.saveTimeForTask(key);
                                    if (task.timer == null) {
                                      if (!appState.isInitialized) {
                                        startEvent(appState);
                                      }
                                      task.start();
                                    } else {
                                      task.resume();
                                    }
                                    task.fadeState = CrossFadeState.showSecond;
                                    appState.canPop = false;
                                  },
                                  icon: const Icon(Icons.play_arrow),
                                ),
                                secondChild: IconButton(
                                  onPressed: () {
                                    //appState.pauseTimer(isPaused);
                                    //isPaused = !isPaused;
                                    task.pause();
                                    task.fadeState = CrossFadeState.showFirst;
                                  },
                                  icon: const Icon(Icons.pause),
                                ),
                                crossFadeState: task.fadeState,
                                duration: animationDuration,
                              ),
                            ),
                            AnimatedOpacity(
                              opacity: task.opacity,
                              duration: animationDuration,
                              child: IconButton(
                                onPressed: () {
                                  if (task.timer != null) {
                                    //appState.saveTimeForTask(key);
                                    //appState.timer.cancel();
                                    task.stop();
                                    setState(() {
                                      task.taskTextDecoration =
                                          TextDecoration.lineThrough;
                                      task.opacity = 0.0;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.stop),
                              ),
                            )
                          ],
                        ),
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
