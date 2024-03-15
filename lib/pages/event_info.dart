import 'package:cal_time_tracker/appState.dart';
import 'package:cal_time_tracker/pages/auto_complete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventInfo extends StatelessWidget {
  const EventInfo({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Card(
            elevation: 24,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              leading: const Icon(Icons.task_alt),
              title: AutoComplete(
                events: appState.currentParentEvent?.children ?? [],
                initialValue: appState.currentEventName,
              ),
            ),
          ),
          SizedBox(
            //width: 300,
            height: 120,
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
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.timer),
                  title: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Start :"),
                      const SizedBox(
                        width: 16,
                      ),
                      Text(
                          "${appState.startTime.hour.toFormatedString()}:${appState.startTime.minute.toFormatedString()}:${appState.startTime.second.toFormatedString()}"),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.timer),
                  title: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Stop :"),
                      const SizedBox(
                        width: 19,
                      ),
                      Text(
                          "${appState.stopTime.hour.toFormatedString()}:${appState.stopTime.minute.toFormatedString()}:${appState.stopTime.second.toFormatedString()}"),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
