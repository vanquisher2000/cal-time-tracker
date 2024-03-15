import 'dart:math';

import 'package:cal_time_tracker/appState.dart';
import 'package:cal_time_tracker/data/EventData.dart';
import 'package:cal_time_tracker/pages/project_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Tasks extends StatelessWidget {
  Tasks({super.key, required this.events});

  var lastColorIndex = 0;
  var events;

  Color getRandomColor() {
    Random random = Random();
    var index = random.nextInt(backgroundColors.length);
    while (index == lastColorIndex) {
      index = random.nextInt(backgroundColors.length);
    }
    lastColorIndex = index;
    return backgroundColors[index];
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    if (appState.events.isEmpty) {
      return const Center(
        child: Text("no Tasks yet"),
      );
    }
    return
        //listWidget(events: events);
        Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: ListView(
        children: [
          /* const Card(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ListTile(title: Text("Previous Tasks")),
            ),
          ), */
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListBody(
              children: [
                for (var event in events)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: getRandomColor(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ExpTile(
                      event: event,
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class listWidget extends StatelessWidget {
  listWidget({super.key, required this.events});

  final List<EventData> events;
  var lastColorIndex = 0;

  Color getRandomColor() {
    Random random = Random();
    var index = random.nextInt(backgroundColors.length);
    while (index == lastColorIndex) {
      index = random.nextInt(backgroundColors.length);
    }
    lastColorIndex = index;
    return backgroundColors[index];
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: getRandomColor(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpTile(
              key: Key(events[index].name),
              event: events[index],
            ),
          );
        });
  }
}
