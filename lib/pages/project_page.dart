import 'package:cal_time_tracker/appState.dart';
import 'package:cal_time_tracker/data/event_data.dart';
import 'package:cal_time_tracker/data/task.dart';
import 'package:cal_time_tracker/pages/new_project_dialog.dart';
import 'package:cal_time_tracker/pages/new_task_page.dart';
import 'package:cal_time_tracker/pages/stackTaskUI.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cal_time_tracker/Utils/Colors.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<StatefulWidget> createState() => _ProjectPage();
}

class _ProjectPage extends State<ProjectPage> {
  _ProjectPage();

  Widget eventCard(EventData event, MyAppState appState) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        //color: Colors.blue[50], // Background color
        border: Border.all(
            color: Color.fromARGB(255, 36, 229, 243),
            width: 1.0), // Border color and width
        borderRadius: BorderRadius.circular(32.0), // Circular border radius
      ),
      child: GestureDetector(
        child: Column(
          children: [
            Text(
              event.name,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.amber,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              appState.getFormattedDuration(event.duration ?? 0),
              style: const TextStyle(
                fontSize: 12,
                color: Color.fromARGB(255, 178, 167, 135),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        onTap: () {
          event.lastUsed = DateTime.now();
          var eventName = event.name ?? "";
          var parentEvent = appState.currentParentEvent;
          appState.reset();
          appState.currentParentEvent = parentEvent;
          appState.heroMode = false;
          appState.currentEventName = eventName;
          appState.textFiledController.text = eventName;
          appState.currentTask = eventName;
          appState.tasks = event.tasks ?? [];

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskStack()),
          );
        },
      ),
    );
  }

  List<EventData> sortEvents(List<EventData>? events) {
    if (events == null) return [];
    List<EventData> ret = List.from(events);
    ret.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    List<Widget> children = [];
    var event = appState.currentParentEvent;
    var events = sortEvents(event?.children);
    var theme = Theme.of(context);
    for (int i = 0; i < (events?.length ?? 0); i++) {
      children.add(eventCard(events![i], appState));
    }
    return Scaffold(
      /*  appBar: AppBar(
        title: RichText(
          text: TextSpan(
              text: appState.currentParentEvent?.name,
              style: theme.textTheme.headlineSmall
              /* const TextStyle(
                //color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24), */
              ),
        ),
      ), */
      body: PopScope(
        onPopInvoked: (didPop) {
          appState.currentParentEvent = null;
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30, right: 30, left: 30),
                  child: Text(
                    appState.currentParentEvent?.name ?? "",
                    style: TextStyle(
                      fontSize: 60,
                      color: primaryTextColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Divider(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      child: const Icon(
                        Icons.add,
                        size: 42,
                      ),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) => NewCategoryDialog(
                                  isParent: false,
                                ));
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: children,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      /* body: ListView.builder(
        itemCount: appState.currentParentEvent?.children.length,
        itemBuilder: ((context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              elevation: 1,
              child: ListTile(
                title: RichText(
                  text: TextSpan(
                      text: events?[index].name,
                      style: theme.textTheme.titleMedium
                      /* const TextStyle(
                        color: theme.textTheme.,
                        fontWeight: FontWeight.bold,
                        fontSize: 18), */
                      ),
                ),
                subtitle: Text(
                  appState.getFormattedDuration(events?[index].duration ?? 0),
                ),
                onTap: () {
                  var eventName = events?[index].name ?? "";

                  appState.reset();
                  appState.currentParentEvent = event;
                  appState.heroMode = false;
                  appState.currentEventName = eventName;
                  appState.textFiledController.text = eventName;
                  appState.currentTask = eventName;
                  //appState.getTasks(events?[index].tasks);
                  appState.tasks = events?[index].tasks ?? [];
                  //appState.startTimer();
                  //appState.currentParentEvent = event;
                  Navigator.push(
                    context,
                    //MaterialPageRoute(builder: (context) => NewTaskPage()),
                    MaterialPageRoute(builder: (context) => TaskStack()),
                  );
                },
              ),
            ),
          );
        }),
      ), */
      /* floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => NewCategoryDialog(
                    isParent: false,
                  ));
        },
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ), // */
    );
  }
}
