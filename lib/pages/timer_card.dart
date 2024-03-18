import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:cal_time_tracker/appState.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimerCard extends StatelessWidget {
  const TimerCard({super.key});

  final fontSize = 64.0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    //var theme = Theme.of(context);
    //var cardColor = theme.colorScheme.primaryContainer;
    return Center(
      child: SizedBox(
        //width: 200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              color: appState.hourColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedText(
                  value: appState.lapsedHours,
                  fontSize: fontSize,
                ),
              ),
            ),
            Text(":", style: TextStyle(fontSize: fontSize)),
            Card(
              color: appState.minutesColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedText(
                  value: (appState.lapsedMinutes.toInt() -
                      appState.lapsedHours * 60),
                  fontSize: fontSize,
                ),
              ),
            ),
            Text(":", style: TextStyle(fontSize: fontSize)),
            Card(
              color: appState.secondsColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedText(
                  value: appState.lapsedSeconds.toInt(),
                  fontSize: fontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedText extends StatelessWidget {
  const AnimatedText({super.key, required this.value, required this.fontSize});
  final int value;
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    return AnimatedFlipCounter(
      wholeDigits: 2,
      value: value,
      textStyle: TextStyle(
        fontSize: fontSize,
        color: Colors.black,
      ),
    );
  }
}
