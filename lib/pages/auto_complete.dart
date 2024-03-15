import 'package:cal_time_tracker/appState.dart';
import 'package:cal_time_tracker/data/EventData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AutoComplete extends StatelessWidget {
  const AutoComplete({
    super.key,
    required this.events,
    required this.initialValue,
  });

  final List<EventData> events;
  static String displayEventName(EventData event) => event.name;
  final String initialValue;

  Widget _flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return DefaultTextStyle(
      style: DefaultTextStyle.of(toHeroContext).style,
      child: toHeroContext.widget,
    );
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Autocomplete<EventData>(
      fieldViewBuilder: (BuildContext context,
          TextEditingController fieldTextEditingController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted) {
        return Hero(
          tag: appState.currentEventName,
          flightShuttleBuilder: _flightShuttleBuilder,
          child: TextField(
            onChanged: (value) => appState.currentEventName = value,
            controller: fieldTextEditingController,
            style: const TextStyle(fontSize: 16),
            //textAlign: TextAlign.center,
            focusNode: fieldFocusNode,
            decoration: const InputDecoration(
              hintText: "Insert event name...",
              hintStyle: TextStyle(color: Colors.grey),
              contentPadding: EdgeInsets.fromLTRB(0, 12, 0, 12),
              border: InputBorder.none,
              /* focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey)), */
            ),
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
