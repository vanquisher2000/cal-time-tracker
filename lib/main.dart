import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cal_time_tracker/appState.dart';
import 'package:cal_time_tracker/controller/calendarController.dart';
import 'package:cal_time_tracker/controller/customNotificationController.dart';
import 'package:cal_time_tracker/controller/notificationController.dart';
import 'package:cal_time_tracker/controller/userController.dart';
import 'package:cal_time_tracker/data/EventData.dart';
import 'package:cal_time_tracker/firebase_options.dart';
import 'package:cal_time_tracker/pages/login_page.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cal_time_tracker/pages/taskPage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalNotificationService.init();
  //await NotificationController.initializeLocalNotifications();
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
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  foregroundImage:
                      NetworkImage(UserController.user?.photoURL ?? ''),
                ),
                const SizedBox(
                  width: 8,
                ),
                SizedBox(
                  width: 200,
                  child: Text(
                    "${UserController.user?.displayName ?? "..."} Tasks",
                    overflow: TextOverflow.fade,
                    maxLines: 2,
                    softWrap: true,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                await UserController.signOutFromGoogle();
                if (mounted) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const LoginPage()));
                }
              },
              child: const Text("Logout"),
            )
          ],
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: const Tasks(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //appState.startTimer();
          appState.reset();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskPage()),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), //
    );
  }
}

class Tasks extends StatelessWidget {
  const Tasks({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    if (appState.events.isEmpty) {
      return const Center(
        child: Text("no Tasks yet"),
      );
    }
    return ListView(
      children: [
        const Card(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: ListTile(title: Text("Previous Tasks")),
          ),
        ),
        Card(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListBody(children: [
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
          ]),
        ))
      ],
    );
  }
}
