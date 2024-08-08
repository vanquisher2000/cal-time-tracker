import 'package:cal_time_tracker/appState.dart';
import 'package:cal_time_tracker/controller/notificationController.dart';
import 'package:cal_time_tracker/pages/project_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class noNameDialog extends StatelessWidget {
  const noNameDialog({super.key});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const Text("Please enter event name"),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"))
      ],
    );
  }
}

class timerIsOnDialog extends StatelessWidget {
  const timerIsOnDialog({super.key});
  @override
  Widget build(BuildContext context) {
    var appStart = context.watch<MyAppState>();
    return AlertDialog(
      content: const Text(
          "if you leave now the timer will be stopped and the event will be lost"),
      actions: [
        TextButton(
            onPressed: () {
              appStart.stopTimer(context);
              //appStart.reset();
              appStart.canPop = true;
              //Navigator.of(context).pop();
              LocalNotificationService.flutterLocalNotificationsPlugin
                  .cancelAll();
              // Navigator.popUntil(context, ModalRoute.withName("ProjectPage"));
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              //Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text("cancel Timer")),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("continue"))
      ],
    );
  }
}
