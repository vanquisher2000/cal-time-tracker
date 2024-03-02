import 'package:cal_time_tracker/appState.dart';
import 'package:cal_time_tracker/data/EventData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:cal_time_tracker/main.dart';

class TaskPage extends StatelessWidget {
  TaskPage({super.key});

  var canPop = false;
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);
    var cardColor = theme.colorScheme.primaryContainer;
    var card = Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 200,
          child: Text(
            '${appState.lapsedHours.toFormatedString()}:${appState.lapsedMinutes.toFormatedString()}:${appState.lapsedSeconds.toFormatedString()}',
            textAlign: TextAlign.center,
            style: theme.textTheme.displayMedium!.copyWith(
                //color: theme.colorScheme.primaryContainer,
                ),
          ),
        ),
      ),
    );
    return Scaffold(
      body: PopScope(
        canPop: canPop,
        onPopInvoked: (didPop) {
          if (didPop) return;
          /* Navigator.of(context).pop();
          if (!appState.isInitialized) {
            //Navigator.of(context).pop();
          } */
          print("$didPop , truth is ${appState.canPop}");
          if (didPop) {
            print("trying to pop");
            Navigator.of(context).pop();
            Navigator.popUntil(context, ModalRoute.withName("/"));
            print("popped");
          } else {
            if (appState.isInitialized) {
              showDialog(
                  context: context,
                  builder: (context) => const timerIsOnDialog());
            }
          }
        },
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  card,
                  const SizedBox(
                    height: 24,
                  ),
                  Row(
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
                                      builder: (context) =>
                                          const noNameDialog());
                                } else {
                                  appState.pushEvent(context);
                                  appState.canPop = true;
                                  canPop = true;
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                      const SizedBox(
                        width: 48,
                      ),
                      (!appState.isInitialized)
                          ? RoundButton(
                              label: "Start",
                              onPressed: appState.startTimer,
                              textColor: Colors.green,
                            )
                          : RoundButton(
                              label: "Reset",
                              onPressed: appState.reset,
                              textColor: Colors.redAccent,
                            ),
                    ],
                  )
                ],
              ),
              //Records(record: appState.record)
              const EventInfo()
            ]),
      ),
    );
  }
}

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
    //var appState = context.watch<MyAppState>();
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: const CircleBorder(), padding: const EdgeInsets.all(24)),
        onPressed: () {
          onPressed();
        },
        child: Text(
          label,
          style: TextStyle(
              color: (textColor != Colors.white)
                  ? textColor
                  : theme.textTheme.displayMedium!.color),
        ));
  }
}

class EventInfo extends StatelessWidget {
  const EventInfo({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Card(
      child: Column(
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Event Name"),
              ),
              Expanded(
                child: Card(
                  surfaceTintColor: Colors.blueGrey,
                  child: AutoComplete(
                    events: appState.events,
                    initialValue: appState.currentEventName

                    /* appState.currentEventName.isNotEmpty
                        ? appState.currentEventName
                        : "event #${appState.events.length + 1}" */
                    ,
                  ),
                ),
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: Text(
                " Event started : ${appState.startTime.hour.toFormatedString()}:${appState.startTime.minute.toFormatedString()}:${appState.startTime.second.toFormatedString()}"),
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: Text(
                " Event Stopped : ${appState.stopTime.hour.toFormatedString()}:${appState.stopTime.minute.toFormatedString()}:${appState.stopTime.second.toFormatedString()}"),
          ),
          SizedBox(
            //width: 300,
            height: 120,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                surfaceTintColor: Colors.blueGrey,
                child: SingleChildScrollView(
                  child: TextField(
                    controller: appState.infoTextFeildController,
                    onChanged: (value) => appState.currentEventInfo = value,
                    maxLines: null,
                    decoration: const InputDecoration(
                        hintText: "Insert event Info...",
                        contentPadding: EdgeInsets.symmetric(horizontal: 24),
                        border: InputBorder.none),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AutoComplete extends StatelessWidget {
  const AutoComplete({
    super.key,
    required this.events,
    required this.initialValue,
  });

  final List<EventData> events;
  static String displayEventName(EventData event) => event.name;
  final String initialValue;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Autocomplete<EventData>(
      fieldViewBuilder: (BuildContext context,
          TextEditingController fieldTextEditingController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted) {
        return TextField(
          onChanged: (value) => appState.currentEventName = value,
          controller: fieldTextEditingController,
          textAlign: TextAlign.center,
          focusNode: fieldFocusNode,
          decoration: const InputDecoration(
            hintText: "Insert event name...",
            contentPadding: EdgeInsets.symmetric(horizontal: 24),
            border: InputBorder.none,
          ),
        );
      },
      displayStringForOption: displayEventName,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == "" || events.isEmpty) {
          return const Iterable<EventData>.empty();
        }
        return events.where((EventData event) {
          return event.name.contains(textEditingValue.text.toLowerCase());
          //event.toString().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (event) {
        appState.currentEventName = event.name;
        appState.textFiledController.text = event.name;
      },
      initialValue: TextEditingValue(text: initialValue),
    );
  }
}

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
              appStart.reset();
              appStart.canPop = true;
              //Navigator.of(context).pop();
              Navigator.popUntil(context, ModalRoute.withName("/"));
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
