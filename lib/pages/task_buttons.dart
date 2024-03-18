import 'dart:math';

import 'package:cal_time_tracker/appState.dart';
import 'package:cal_time_tracker/pages/task_page_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.textColor = Colors.white,
  });

  final String label;
  final VoidCallback onPressed;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
              colors: [
            appState.hourColor,
            appState.minutesColor,
            appState.secondsColor,
          ],
              //begin: Alignment.center,

              transform:
                  GradientRotation((2 * pi) * (appState.lapsedSeconds / 60.0)))
          .createShader(bounds),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 1,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(72),
          ),
          onPressed: () {
            onPressed();
          },
          child: Text(
            label,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: (textColor != Colors.white)
                    ? textColor
                    : theme.textTheme.displayMedium!.color),
          )),
    );
  }
}

class TaskButton extends StatelessWidget {
  TaskButton({super.key, required this.canPop});

  bool canPop;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Center(
      child: (!appState.isInitialized)
          ? RoundButton(
              label: "Start",
              onPressed: () {
                appState.startTimer();
                canPop = false;
                appState.canPop = false;
              },
              textColor: Colors.green,
            )
          : (appState.isInitialized && appState.stopTime == DateTime(0))
              ? RoundButton(
                  label: "Stop",
                  onPressed: () {
                    appState.stopTimer(context);
                  },
                  textColor: Colors.red,
                )
              : RoundButton(
                  label: "push",
                  onPressed: () {
                    appState.stopTimer(context);
                    if (appState.currentEventName.isEmpty) {
                      showDialog(
                          context: context,
                          builder: (context) => const noNameDialog());
                    } else {
                      appState.pushEvent(context);
                      appState.canPop = true;
                      canPop = true;
                      Navigator.of(context).pop();
                    }
                  },
                ),
    );
  }
}
