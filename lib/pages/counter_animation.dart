import 'dart:async';
import 'dart:math';

import 'package:cal_time_tracker/appState.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CounterAnimation extends StatefulWidget {
  const CounterAnimation({super.key});
  @override
  State<StatefulWidget> createState() => _CounterAnimation();
}

class _CounterAnimation extends State<CounterAnimation> {
  late Timer timer;
  var angle = 0.0;
  var minute = 0.0;
  var hour = 0.0;
  var watchSeconds = 0;
  var watchMinutes = 0;
  var watchHours = 0;
  final circum = 2 * pi;
  //_CounterAnimation({required this.cont});
  //final BuildContext cont;
  MyAppState? appState;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (appState?.isInitialized == true) {
        if (appState?.timer.isActive == true) {
          setState(() {
            angle += circum / 100.0;
            //minute = appState!.lapsedSeconds * ((2 * pi) / 60.0);
            minute += circum / (100.0 * 60.0);
            hour += (circum / 100.0) / (60.0 * 60.0);

            //if (angle % (2 * pi) == 0) angle = 0;
            if (appState!.lapsedSeconds.toInt() != watchSeconds) {
              debugPrint("${(angle / circum)} , ${appState?.lapsedSeconds}");
              angle = 0.0;
              watchSeconds = appState!.lapsedSeconds.toInt();
            }
            if (appState!.lapsedMinutes.toInt() != watchMinutes) {
              debugPrint("${(minute / circum)} , ${appState?.lapsedMinutes}");

              minute = 0.0;
              watchMinutes = appState!.lapsedMinutes.toInt();
            }
            if (appState!.lapsedHours != watchHours) {
              debugPrint("${(hour / circum)} , ${appState?.lapsedHours}");

              hour = 0.0;
              watchHours = appState!.lapsedHours;
            }
          });
        } else if (appState?.timer.isActive == false) {
          angle = 0;
          minute = 0;
          hour = 0;
          watchSeconds = 0;
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appState = context.watch<MyAppState>();
    //debugPrint("animation widget built");
    return IgnorePointer(
      ignoring: true,
      child: CustomPaint(
        painter: AnimationPainter(
            angle: angle, hour: hour, minute: minute, appState: appState!),
        child: Container(),
      ),
    );
  }
}

class AnimationPainter extends CustomPainter {
  AnimationPainter({
    required this.angle,
    required this.hour,
    required this.minute,
    required this.appState,
  });
  var angle = 0.0;
  var hour = 0.0;
  var minute = 0.0;
  final MyAppState appState;
  final strokeWidth = 20.0;
  @override
  void paint(Canvas canvas, Size size) {
    /* final width = size.width * 0.8;
    final midWidth = width - strokeWidth * 2;
    final innerWidth = width - strokeWidth * 4;

    final center = Offset(size.width / 2, size.height / 2 + 64);
    Rect rect = Rect.fromCenter(center: center, width: width, height: width);
    Rect middleRect =
        Rect.fromCenter(center: center, width: midWidth, height: midWidth);
    Rect innerRect =
        Rect.fromCenter(center: center, width: innerWidth, height: innerWidth);

    debugPrint("size : $size");

    final paint = Paint()
      ..color = Colors.red.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final circlePaint = Paint()
      ..color = Colors.grey.withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    //canvas.drawRect(rect, paint);
    canvas.drawCircle(center, rect.height / 2, circlePaint);
    canvas.drawCircle(center, middleRect.height / 2, circlePaint);
    canvas.drawCircle(center, innerRect.height / 2, circlePaint);
    canvas.drawArc(rect, 0, angle, false, paint);
    canvas.drawArc(middleRect, 0, angle, false, paint);
    canvas.drawArc(innerRect, 0, angle, false, paint); */

    //TODO: make an equation to solve the hidden variable : read about flutter canvas
    const secStroke = 3.0;
    const minStroke = secStroke * 2;
    const hourStroke = secStroke * 3;
    final center = Offset(size.width / 2, size.height / 2 + 90);

    final diameter = size.width * 0.4;
    final d_2 = diameter + secStroke * 3;
    final d_3 = d_2 + minStroke * 2;

    /* drawTimeTrack(
      canvas,
      center,
      hour,
      Colors.red.shade300,
      stroke: hourStroke,
      diameter: d_3,
    ); */

    drawTimeTrack(
      canvas,
      center,
      minute,
      appState.minutesColor,
      //Colors.blue.shade300,
      diameter: d_2,
      stroke: minStroke,
      //circleColor: Colors.greenAccent,
    );

    drawTimeTrack(
      canvas,
      center,
      angle,
      appState.secondsColor,
      // Colors.purple.shade200,
      stroke: secStroke,
      diameter: diameter,
      //circleColor: Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void drawTimeTrack(
    Canvas canvas,
    Offset center,
    //double strokeWidth,
    double progress,
    //double diameter,
    Color color, {
    double stroke = 20,
    required double diameter,
    Color circleColor = Colors.grey,
  }) {
    //final diameter = size.width * 0.8 - strokeWidth;

    Rect rect =
        Rect.fromCenter(center: center, width: diameter, height: diameter);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final circlePaint = Paint()
      ..color = circleColor.withAlpha(25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, diameter / 2, circlePaint);
    canvas.drawArc(rect, 0, progress, false, paint);
  }
}
