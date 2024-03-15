import 'package:cal_time_tracker/appState.dart';
import 'package:cal_time_tracker/pages/taskPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpTile extends StatefulWidget {
  const ExpTile({super.key, required this.event});

  final event;
  @override
  State<ExpTile> createState() {
    return _ExpTile(event: event);
  }
}

class _ExpTile extends State<ExpTile> {
  _ExpTile({this.event});

  final event;

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
    var theme = Theme.of(context);
    return ExpansionTile(
        tilePadding: const EdgeInsets.all(8),
        shape: Border.all(
          color: Colors.transparent,
          style: BorderStyle.none,
        ),
        //backgroundColor: theme.colorScheme.secondaryContainer,
        trailing: IconButton(
          icon: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade300.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.add,
              color: Color.fromARGB(255, 2, 45, 80),
            ),
          ),
          padding: const EdgeInsets.all(0),
          onPressed: () {
            appState.reset();
            appState.currentParentEvent = event;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaskPage()),
            );
          },
        ),
        title: RichText(
          text: TextSpan(
            text: "${event.name}",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.5,
            ),
            /* children: [
                TextSpan(
                  text: appState.getFormatedDuration(event.duration),
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    height: 1.5,
                  ),
                )
              ] */
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            appState.getFormatedDuration(event.duration),
            style: TextStyle(
              color: Colors.black.withOpacity(0.64),
              fontStyle: FontStyle.italic,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ),
        /* Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add),
                  ),
                  padding: const EdgeInsets.all(0),
                  onPressed: () {},
                )
                /* ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    //elevation: 0,
                    //backgroundColor: Colors.transparent,
                  ),
                  child: const Icon(Icons.add),
                  onPressed: () {
                    appState.reset();
                    appState.currentParentEvent = event;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TaskPage()),
                    );
                  },
                ) */
                ,
              ),
              const SizedBox(
                width: 4,
              ),
              Expanded(
                  child: Wrap(
                children: [
                  Text(
                    event.name,
                    overflow: TextOverflow.fade,
                    maxLines: 2,
                    softWrap: true,
                  ),
                  const Divider(
                    color: Colors.transparent,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      appState.getFormatedDuration(event.duration),
                    ),
                  )
                ],
              ))
            ]) */

        children: [
          for (var subEvent in event.children)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Card(
                color: theme.colorScheme.primaryContainer,
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HeroMode(
                        enabled: appState.heroMode,
                        child: Hero(
                            tag: subEvent.name,
                            flightShuttleBuilder: _flightShuttleBuilder,
                            transitionOnUserGestures: true,
                            child: Text(
                              subEvent.name,
                            )),
                      ),
                      Text(appState.getFormatedDuration(subEvent.duration)),
                    ],
                  ),
                  onTap: () {
                    appState.heroMode = false;
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
              ),
            ),
        ]);
  }
}
