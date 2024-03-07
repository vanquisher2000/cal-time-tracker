import 'dart:developer';
import 'dart:math';

import 'package:cal_time_tracker/appState.dart';
import 'package:cal_time_tracker/controller/calendarController.dart';
import 'package:cal_time_tracker/controller/notificationController.dart';
import 'package:cal_time_tracker/controller/userController.dart';
import 'package:cal_time_tracker/data/EventData.dart';
import 'package:cal_time_tracker/firebase_options.dart';
import 'package:cal_time_tracker/pages/login_page.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:cal_time_tracker/pages/taskPage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalNotificationService.init();
  //await NotificationController.initializeLocalNotifications();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );
  await SystemChrome.setSystemUIChangeCallback(
    (systemOverlaysAreVisible) async {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top],
      );
    },
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static final _defaultLightColorScheme =
      ColorScheme.fromSwatch(primarySwatch: Colors.blue);

  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.blue, brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
            title: 'Time Tracker',
            theme: ThemeData(
              colorScheme: lightColorScheme ?? _defaultLightColorScheme,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
              useMaterial3: true,
            ),
            //themeMode: ThemeMode.light,
            /* theme: ThemeData(
              useMaterial3: true,
              //primarySwatch: Colors.blue,
              colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),

              visualDensity: VisualDensity.adaptivePlatformDensity,

              //colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 142, 194, 219)),
            ),
            darkTheme: ThemeData.dark(), */
            home: UserController.user == null
                ? const LoginPage()
                : const MyHomePage()),
        //GoogleSignInScreen()
        //const MyHomePage(),
      );
    });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePage();
}

class _MyHomePage extends State<MyHomePage> {
  _MyHomePage() {
    CalendarController.init();
  }

  String? username;
  String? userImageUrl;

  Future<void> fetchUserInfo() async {
    //await UserController.getUser();
    var user = UserController.user ?? await UserController.loginWithGoogle();
    setState(() {
      username = user?.displayName;
      userImageUrl = user?.photoURL;
    });
  }

  Future<void> permissionCheck() async {
    await LocalNotificationService.checkAndroidPermissionGranted();
    //_retrieveCalendars();
    setState(() {
      CalendarController.retrieveCalendars();
    });
  }

  @override
  void initState() {
    super.initState();

    permissionCheck();
    fetchUserInfo();
    /* LocalNotificationService.checkAndroidPermissionGranted();
    //_retrieveCalendars();
    setState(() {
      CalendarController.retrieveCalendars();
    }); */
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        actions: [
          Align(
            alignment: Alignment.centerLeft,
            child: CircleAvatar(
              foregroundImage: NetworkImage(userImageUrl ?? ''),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Flexible(
            flex: 2,
            fit: FlexFit.loose,
            child: Text(
              "${UserController.user?.displayName ?? "..."} Tasks",
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: true,
              style: TextStyle(fontSize: 25),
            ),
          ),
          Spacer(),
          ElevatedButton(
            onPressed: () async {
              await UserController.signOutFromGoogle();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              }
            },
            child: const Text("Logout"),
          ),
          const SizedBox(
            width: 8,
          )
        ],
      ),
      //),
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: const Tasks(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //appState.startTimer();
          /* appState.reset();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskPage()),
          ); */
          showDialog(
              context: context, builder: (context) => NewCategoryDialog());
        },
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ), //
    );
  }
}

class Tasks extends StatelessWidget {
  const Tasks({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    if (appState.events.isEmpty) {
      return const Center(
        child: Text("no Tasks yet"),
      );
    }
    return Padding(
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
                for (var event in appState.events)
                  Card(
                    child: ExpTile(
                      event: event,
                      context: context,
                    ),
                  )
              ],
            )
            //ExpPanelList()
            /* ListBody(children: [
          for (var event in appState.events)
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(event.name),
                  Text(appState.getFormatedDuration(event.duration)),
                ],
              ),
              onTap: () {
                appState.reset();
                appState.currentEventName = event.name;
                appState.textFiledController.text = event.name;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskPage()),
                );
              },
            )
                      ]) */
            ,
          )
        ],
      ),
    );
  }
}

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
                title: Row(
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
                ),
                onTap: () {
                  event.isExpanded = !event.isExpanded;
                  appState.notifyListeners();
                },
              );
            },
            body: Card(
              child: Column(
                children: [
                  for (var subEvent in event.children)
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(subEvent.name),
                          Text(appState.getFormatedDuration(subEvent.duration)),
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
            ),
            isExpanded: event.isExpanded,
          );
        },
      ).toList(),
    );
  }
}

class ExpTile extends StatefulWidget {
  const ExpTile({super.key, required this.event, required this.context});

  final event;
  final context;
  @override
  State<ExpTile> createState() {
    return _ExpTile(event: event, context: context);
  }
}

class _ExpTile extends State<ExpTile> {
  _ExpTile({this.event, required this.context});

  final event;
  final context;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var appState = context.watch<MyAppState>();
    setState(() {
      appState.heroMode = false;
      appState.notifyListeners();
    });
  }

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
        shape: Border.all(color: Colors.transparent),
        backgroundColor: theme.colorScheme.secondaryContainer,
        title: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
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
                ),
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
            ]),
        children: [
          for (var subEvent in event.children)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Card(
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HeroMode(
                        enabled: true,
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
                    appState.reset();
                    appState.heroMode = true;
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

class NewCategoryDialog extends StatelessWidget {
  NewCategoryDialog({super.key});

  var eventName = "";

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Dialog(
      child: Container(
        width: 300,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) => eventName = value,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: "Insert Category name...",
                  contentPadding: EdgeInsets.symmetric(horizontal: 24),
                  border: InputBorder.none,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (eventName.isNotEmpty) {
                        var event = EventData(name: eventName, duration: 0);
                        appState.events.add(event);
                        appState.notifyListeners();
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Confirm",
                      style: TextStyle(color: Color.fromARGB(255, 23, 144, 85)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
