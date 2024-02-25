import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cal_time_tracker/taskPage.dart';
import "package:cal_time_tracker/loginPage.dart";
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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

void main() {
  runApp(const MainApp());
}

class EventData {
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final String eventInfo;

  EventData({
    required this.name,
    required this.startTime,
    required this.endTime,
    this.eventInfo = "",
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "startTime": startTime.toString(),
      "endTime": endTime.toIso8601String(),
      "eventInfo": eventInfo,
    };
  }

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
      name: json["name"],
      startTime: DateTime.parse(json["startTime"]),
      endTime: DateTime.parse(json["endTime"]),
      eventInfo: json["eventInfo"],
    );
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
        home: 
        //GoogleSignInScreen()
        const MyHomePage()
        ,
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  //DateTime currentTime = DateTime.now();
  DateTime startTime = DateTime(0);
  Duration elapsedTime = Duration.zero;
  var stopTime = DateTime(0);
  late Timer timer;
  bool isInitialized = false;
  List<Widget> record = [];
  List<EventData> events = [];
  var currentEventName = "";
  var currentEventInfo = "";
  var lapsedMinutes = 0;
  var lapsedSeconds = 0;
  var lapsedHours = 0;
  var textFiledController = TextEditingController();
  var infoTextFeildController = TextEditingController();
  late SharedPreferences sharedPreferences;

  MyAppState() {
    initPrefs();
  }

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

  void stopTimer() {
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
    record = [];
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

class _MyHomePageState extends State<MyHomePage> {
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
        title: const Text("title"),
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

class _MyHomePage extends State<MyHomePage> {
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
        title: const Text("title"),
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
