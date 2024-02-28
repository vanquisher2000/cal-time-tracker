import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cal_time_tracker/main.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

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
      body: Column(
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
                    RoundButton(
                      label: "Stop",
                      onPressed: () {
                        appState.stopTimer(context);
                      },
                    ),
                    const SizedBox(
                      width: 48,
                    ),
                    (!appState.isInitialized)
                        ? RoundButton(
                            label: !appState.isInitialized ? "Start" : "Reset",
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
                    initialValue: appState.currentEventName.isNotEmpty
                        ? appState.currentEventName
                        : "event #${appState.events.length + 1}",
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
            width: 300,
            height: 120,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                surfaceTintColor: Colors.blueGrey,
                child: ListView(children: [
                  TextField(
                    controller: appState.infoTextFeildController,
                    onChanged: (value) => appState.currentEventInfo = value,
                    maxLines: null,
                    decoration: const InputDecoration(
                        hintText: "Insert event Info...",
                        contentPadding: EdgeInsets.symmetric(horizontal: 24),
                        border: InputBorder.none),
                  ),
                ]),
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
