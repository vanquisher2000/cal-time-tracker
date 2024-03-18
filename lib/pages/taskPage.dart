import 'package:cal_time_tracker/appState.dart';
import 'package:cal_time_tracker/pages/counter_animation.dart';
import 'package:cal_time_tracker/pages/event_info.dart';
import 'package:cal_time_tracker/pages/task_buttons.dart';
import 'package:cal_time_tracker/pages/task_page_dialogs.dart';
import 'package:cal_time_tracker/pages/timer_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaskPage extends StatelessWidget {
  TaskPage({super.key});

  var canPop = true;
  var fontSize = 40.0;
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    //var theme = Theme.of(context);

    return Scaffold(
      body: PopScope(
        canPop: appState.canPop,
        onPopInvoked: (didPop) {
          if (didPop) {
            appState.heroMode = true;
            appState.notifyListeners();
            return;
          }

          debugPrint("$didPop , truth is ${appState.canPop} , $canPop");
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
        },
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              const Spacer(),
              Center(
                  child: Column(
                children: [
                  const TimerCard(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(appState.getStartTimeFormatted()),
                        ),
                        const Icon(Icons.arrow_right),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(appState.getEndTimeFormatted()),
                        ),
                      ],
                    ),
                  )
                ],
              )),
              const SizedBox(
                height: 32,
              ),
              const EventInfo(),
              /*  Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  (appState.currentEvent == null)
                      ? RoundButton(
                          label: "Stop",
                          onPressed: () {
                            appState.stopTimer(context);
                          },
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
                  const SizedBox(
                    width: 128,
                  ),
                  (!appState.isInitialized)
                      ? RoundButton(
                          label: "Start",
                          onPressed: () {
                            appState.startTimer();
                            canPop = false;
                          },
                          textColor: Colors.green,
                        )
                      : RoundButton(
                          label: "Reset",
                          onPressed: appState.reset,
                          textColor: Colors.redAccent,
                        ),
                ],
              ), */

              const Spacer(),
              Stack(
                children: [
                  TaskButton(canPop: canPop),
                  const CounterAnimation(),
                ],
              ),
              const SizedBox(
                height: 128,
              ),
            ]),
      ),
    );
  }
}
