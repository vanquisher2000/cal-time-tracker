import 'dart:convert';
import 'package:cal_time_tracker/controller/calendarController.dart';
import 'package:cal_time_tracker/controller/userController.dart';
import 'package:cal_time_tracker/firebase_options.dart';
import 'package:cal_time_tracker/login_page.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cal_time_tracker/taskPage.dart';
import 'package:firebase_core/firebase_core.dart';

extension IntExtensions on int {
  String toFormatedString() {
    return toString().padLeft(2, "0");
  }
}

extension DoubleExtensions on double {
  String toFormatedString() {
    return toInt().toString().padLeft(2, "0");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class EventData {
  EventData({
    required this.name,
    required this.startTime,
    required this.endTime,
    this.eventInfo = "",
  });

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
      name: json["name"],
      startTime: DateTime.parse(json["startTime"]),
      endTime: DateTime.parse(json["endTime"]),
      eventInfo: json["eventInfo"],
    );
  }

  final DateTime endTime;
  final String eventInfo;
  final String name;
  final DateTime startTime;

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "startTime": startTime.toString(),
      "endTime": endTime.toIso8601String(),
      "eventInfo": eventInfo,
    };
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
          title: 'Time Tracker',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          ),
          home: UserController.user == null
              ? const LoginPage()
              : const MyHomePage()),
      //GoogleSignInScreen()
      //const MyHomePage(),
    );
  }
}

class MyAppState extends ChangeNotifier {
  MyAppState() {
    initPrefs();
  }

  var currentEventInfo = "";
  var currentEventName = "";
  Duration elapsedTime = Duration.zero;
  List<EventData> events = [];
  var infoTextFeildController = TextEditingController();
  bool isInitialized = false;
  var lapsedHours = 0;
  var lapsedMinutes = 0;
  var lapsedSeconds = 0;
  late SharedPreferences sharedPreferences;
  DateTime startTime = DateTime(0);

  var stopTime = DateTime(0);
  var textFiledController = TextEditingController();
  late Timer timer;

  void startTimer() {
    // setState(() {
    if (!isInitialized) {
      isInitialized = true;
      startTime = DateTime.now();
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        elapsedTime = DateTime.now().difference(startTime);
        lapsedMinutes = elapsedTime.inSeconds ~/ 60;
        lapsedSeconds = elapsedTime.inSeconds % 60;
        lapsedHours = elapsedTime.inMinutes ~/ 60;
        notifyListeners();
      });
    }
    notifyListeners();
    // });
  }

  void stopTimer(BuildContext context) {
    if (isInitialized) {
      timer.cancel();
      stopTime = DateTime.now();

      isInitialized = false;
      var result = EventData(
          name: currentEventName,
          startTime: startTime,
          endTime: stopTime,
          eventInfo: currentEventInfo);
      events.add(result);
      CalendarController.addEvent(
        currentEventName,
        currentEventInfo,
        startTime,
        stopTime,
        context: context,
      );
      saveData();
      notifyListeners();
    }
  }

  void reset() {
    startTime = DateTime(0);
    elapsedTime = Duration.zero;
    stopTime = DateTime(0);
    timer.cancel();
    isInitialized = false;
    //events = [];
    currentEventName = "";
    lapsedMinutes = 0;
    lapsedSeconds = 0;
    lapsedHours = 0;
    currentEventInfo = "";
    currentEventName = "";
    textFiledController.clear();
    infoTextFeildController.clear();
    notifyListeners();
  }

  Future<void> initPrefs() async {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
    } catch (e) {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
    }
    loadData();
  }

  void loadData() {
    List<String>? eventDataString =
        sharedPreferences.getStringList("eventList");
    if (eventDataString != null) {
      events = eventDataString
          .map(
            (e) => EventData.fromJson(jsonDecode(e)),
          )
          .toList();
      print("loaded events ${events.length}");
      notifyListeners();
    }
  }

  void saveData() {
    List<String> eventDataString =
        events.map((e) => jsonEncode(e.toJson())).toList();
    sharedPreferences.setStringList("eventList", eventDataString);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePage();
}

class Old_MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const TaskPage();
        break;
      case 1:
        page = const Tasks();
        break;
      default:
        throw UnimplementedError("no widget for $selectedIndex");
    }

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Row(
          children: [
            CircleAvatar(
              foregroundImage:
                  NetworkImage(UserController.user?.photoURL ?? ""),
            ),
            const SizedBox(
              width: 8,
            ),
            Text(UserController.user?.displayName ?? ""),
            const SizedBox(
              width: 8,
            ),
            const Text("Tasks"),
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
      body: Row(
        children: [
          SafeArea(
              child: NavigationRail(
            destinations: const [
              NavigationRailDestination(
                  icon: Icon(Icons.task), label: Text("task")),
              NavigationRailDestination(
                  icon: Icon(Icons.home), label: Text("home"))
            ],
            extended: false,
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) {
              setState(() {
                selectedIndex = value;
              });
            },
          )),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          appState.startTimer();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), //
    );
  }
}

/* class Records extends StatelessWidget {
  const Records({
    super.key,
    required this.record,
  });

  final List<Widget> record;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: double.infinity,
          height: 300,
          child: ListView(
            children: [
              const ListTile(title: Text("Records")),
              for (var item in record)
                //ListTile(title : item)
                ListBody(
                  children: [item],
                ),
            ],
          ),
        ),
      ),
    );
  }
} */

class _MyHomePage extends State<MyHomePage> {
  //late DeviceCalendarPlugin _deviceCalendarPlugin;
  //List<Calendar> _calendars = [];
  //Calendar? defaultCalendar;

  _MyHomePage() {
    //_deviceCalendarPlugin = DeviceCalendarPlugin();
    CalendarController.init();
  }

  @override
  void initState() {
    super.initState();
    //_retrieveCalendars();
    setState(() {
      CalendarController.retrieveCalendars();
    });
  }

  /* void _retrieveCalendars() async {
    //Retrieve user's calendars from mobile device
    //Request permissions first if they haven't been granted
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
          return;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      setState(() {
        _calendars = (calendarsResult.data != null)
            ? calendarsResult.data!.toList()
            : [];
        defaultCalendar =
            _calendars.firstWhere((element) => element.isDefault ?? false);

        //print(defaultCalender.)
      });
    } catch (e) {
      print(e);
    }
  } */

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
                Text(UserController.user?.displayName ?? "no name found"),
                const SizedBox(
                  width: 8,
                ),
                Text("calendar: ${CalendarController.calendars.length}"),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaskPage()),
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
                title: Text(event.name),
                onTap: () {
                  appState.currentEventName = event.name;
                  appState.textFiledController.text = event.name;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TaskPage()),
                  );
                },
              )
          ]),
        ))
      ],
    );
  }
}
