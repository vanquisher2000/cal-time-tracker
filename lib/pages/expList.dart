import 'package:cal_time_tracker/appState.dart';
import 'package:cal_time_tracker/data/EventData.dart';
import 'package:cal_time_tracker/pages/taskPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpPanelList extends StatelessWidget {
  const ExpPanelList({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);
    return ExpansionPanelList(
      //materialGapSize: 24,
      expansionCallback: (int index, bool isExpanded) {
        debugPrint("$index , $isExpanded");
      },
      elevation: 2, // Panel elevation
      //expandedHeaderPadding: EdgeInsets.all(8.0), // Padding for expanded header
      dividerColor: Colors.grey,
      children: appState.events.map<ExpansionPanel>(
        (EventData event) {
          return ExpansionPanel(
            backgroundColor: theme.colorScheme.secondaryContainer,
            headerBuilder: (context, isExpanded) {
              return ListTile(
                title: RichText(
                  text: TextSpan(
                      text: "${event.name}\n",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      )),
                )
                /* Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                      ),
                      /* style: ButtonStyle(
                          maximumSize:
                              MaterialStateProperty.all<Size>(Size(150, 50))), */
                      child: const Icon(Icons.add),
                      onPressed: () {
                        appState.reset();
                        appState.currentParentEvent = event;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TaskPage()),
                        );
                      },
                    ),
                    SizedBox(
                      width: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            event.name,
                            overflow: TextOverflow.fade,
                            maxLines: 2,
                            softWrap: true,
                          ),
                          Text(appState.getFormatedDuration(event.duration))
                        ],
                      ),
                    ),
                  ],
                ) */
                ,
                onTap: () {
                  event.isExpanded = !event.isExpanded;
                  appState.notifyListeners();
                },
              );
            },
            body: Column(
              children: [
                for (var subEvent in event.children)
                  ListTile(
                    style: ListTileStyle.list,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(subEvent.name),
                        Text(appState.getFormattedDuration(subEvent.duration)),
                      ],
                    ),
                    onTap: () {
                      appState.reset();
                      appState.currentEventName = subEvent.name;
                      appState.textFiledController.text = subEvent.name;
                      appState.currentParentEvent = event;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TaskPage()),
                      );
                    },
                  ),
              ],
            ),
            isExpanded: event.isExpanded,
          );
        },
      ).toList(),
    );
  }
}
