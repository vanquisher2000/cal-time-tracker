import 'package:cal_time_tracker/appState.dart';
import 'package:cal_time_tracker/data/task.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cal_time_tracker/Utils/Colors.dart';
import 'package:wakelock/wakelock.dart';

class TaskWidget extends StatefulWidget {
  final Task task;
  final int index;
  final VoidCallback showButton;
  const TaskWidget(
      {required this.task, required this.index, required this.showButton});
  @override
  State<TaskWidget> createState() => _TaskWidget();
}

SnackBar snackBar({required String message}) {
  return SnackBar(
    backgroundColor: Colors.transparent, // Set background color to transparent
    elevation: 0, // Remove shadow
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0), // Set border radius
    ),
    content: AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 12.0,
      ),
      decoration: const ShapeDecoration(
          color: Colors.white, // Background color of the SnackBar
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(30))) // Border width
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

class _TaskWidget extends State<TaskWidget> {
  bool _isExpandText = false;
  void toggleExpandedText() {
    setState(() {
      _isExpandText =
          !_isExpandText; // first click expand second click back to same position
    });
  }

  IconData checkIcon = Icons.check_box_outline_blank;
  var iconSize = 24;

  TextEditingController controller = TextEditingController();
  @override
  void initState() {
    controller.text = widget.task.note;
    super.initState();
  }

  bool _isHidden = true;
  void toggleExpanded() {
    setState(() {
      _isHidden =
          !_isHidden; // first click expand second click back to same position
    });
  }

  final animationDuration = const Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    var task = widget.task;
    if (task.finished) {
      checkIcon = Icons.check_box;
    }
    var appState = context.watch<MyAppState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                child: Icon(checkIcon),
                onTap: () {
                  if (!task.finished) {
                    if (task.timer != null) {
                      setState(() {
                        task.stop();
                      });
                      setState(() {
                        checkIcon = Icons.check_box;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(snackBar(
                        message: "task hasn't started yet",
                      ));
                    }
                  }
                },
              ),
            ),
            /* IconButton(
              padding: EdgeInsets.zero,
              iconSize: 24.0,
              constraints: BoxConstraints(),
              onPressed: () {
                if (!task.finished) {
                  if (task.timer != null) {
                    setState(() {
                      task.stop();
                    });
                    setState(() {
                      checkIcon = Icons.check_box;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar(
                      message: "task hasn't started yet",
                    ));
                  }
                }
              },
              icon: Icon(checkIcon),
            ),
  */
            SizedBox(
              width: 200,
              child: GestureDetector(
                onTap: toggleExpanded,
                child: Text(
                  task.name,
                  style: TextStyle(
                    fontSize: 25,
                    color: primaryTextColor,
                  ),
                ),
              ),
            ),
            const Spacer(),
            AnimatedOpacity(
              opacity: task.getOpacity(),
              duration: animationDuration,
              child: AnimatedCrossFade(
                firstChild: IconButton(
                  onPressed: () {
                    widget.showButton();
                    Wakelock.enable();
                    if (appState.stopTime == DateTime(0)) {
                      if (!appState.isInitialized) {
                        //startEvent(appState);
                        appState.startTimer();
                      }
                      if (task.startTime == DateTime(0) && task.seconds == 0) {
                        task.start();
                      } else {
                        task.isPaused = true;
                        task.resume();
                      }

                      setState(() {
                        task.fadeState = CrossFadeState.showSecond;
                      });
                      appState.canPop = false;
                    }
                    setState(() {
                      _isHidden = false;
                    });
                  },
                  icon: const Icon(
                    Icons.play_arrow,
                    //color: Colors.white,
                  ),
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
          ],
        ),
        AnimatedSize(
          duration: animationDuration,
          child: Offstage(
              offstage: _isHidden,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Start : ${task.taskBeginTime}",
                    style: TextStyle(
                      fontSize: 18,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Finish : ${task.stopTime}",
                    style: TextStyle(
                      fontSize: 18,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "duration : ${appState.taskTimeString(widget.index)}",
                    style: TextStyle(
                      fontSize: 18,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedSize(
                    duration: animationDuration,
                    child: /* Text(
                      "widget.planetInfo.descriptionllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllldsfsdfsdfasdfsadfsagsdfasdagasdfasgasdf",
                      maxLines: _isExpandText ? null : 1,
                      overflow: _isExpandText
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        color: contentTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ), */
                        TextField(
                      controller: controller,
                      //expands: _isExpandText,
                      maxLines: _isExpandText ? null : 1,
                      onChanged: (value) => widget.task.note = value,
                      style: TextStyle(
                        fontSize: 20,
                        color: contentTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        label: Text("notes..."),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: toggleExpandedText,
                      child: Text(
                        _isExpandText ? "Read less" : "Read more",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              )),
        ),
        const Divider(
            //color: Colors.white,
            ),
      ],
    );
  }
}
