import 'package:cal_time_tracker/appState.dart';
import 'package:cal_time_tracker/pages/new_project_dialog.dart';
import 'package:cal_time_tracker/pages/new_task_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<StatefulWidget> createState() => _ProjectPage();
}

class _ProjectPage extends State<ProjectPage> {
  _ProjectPage();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var event = appState.currentParentEvent;
    var events = event?.children;
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: appState.currentParentEvent?.name,
            style: const TextStyle(
                //color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24),
          ),
        ),
      ),
      body: ListView.builder(
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
                    style: const TextStyle(
                        //color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
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
                  //appState.startTimer();
                  //appState.currentParentEvent = event;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NewTaskPage()),
                  );
                },
              ),
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => NewCategoryDialog(
                    isParent: false,
                  ));
        },
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ), //
    );
  }
}
