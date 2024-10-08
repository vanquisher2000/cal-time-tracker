import 'package:cal_time_tracker/appState.dart';
import 'package:cal_time_tracker/controller/calendarController.dart';
import 'package:cal_time_tracker/controller/notificationController.dart';
import 'package:cal_time_tracker/controller/userController.dart';
import 'package:cal_time_tracker/pages/login_page.dart';
import 'package:cal_time_tracker/pages/new_project_dialog.dart';
import 'package:cal_time_tracker/pages/project_page.dart';
import 'package:cal_time_tracker/pages/project_tile.dart';
import 'package:cal_time_tracker/pages/stackTaskUI.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePage();
}

class _MyHomePage extends State<MyHomePage> with WidgetsBindingObserver {
  _MyHomePage() {
    CalendarController.init();
  }

  String? username;
  String? userImageUrl;
  String searchValue = "";
  late MyAppState appState;
  bool appStateInitialized = false;
  bool restored = false;

  Future<void> fetchUserInfo() async {
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
    WidgetsBinding.instance.addObserver(this);
    permissionCheck();
    fetchUserInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print("current state app is ${state}");
    switch (state) {
      case AppLifecycleState.inactive:
        print('App is inactive');
        break;
      case AppLifecycleState.paused:
        if (appStateInitialized) {
          appState.saveData();
          appState.saveTempData();
        } else {
          debugPrint("appState not initialized yet");
        }
        print('App is paused');
        break;
      case AppLifecycleState.resumed:
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Future.delayed(Duration(milliseconds: 200), () {
            restore();
          });
        });
        //if (appStateInitialized) {}
        print('App is resumed');
        break;
      case AppLifecycleState.detached:
        if (appStateInitialized) {
          appState.saveData();
          appState.saveTempData();
        } else {
          debugPrint("appState not initialized yet");
        }
        print('App is detached');
        break;
      case AppLifecycleState.hidden:
        print('App is hidden');
        break;
    }
  }

  void restore() {
    restored = true;
    appState.loadTempData();
    /* final ModalRoute? modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      print('Current route: ${modalRoute.settings.name}');
    } else {
      print('No current route found.');
    } */

    if (appState.currentParentEvent != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: ((context) => const MyHomePage())),
        (Route<dynamic> route) => false,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: ((context) => const ProjectPage())),
      );
    }
    if (appState.currentEventName.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TaskStack()),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(snackBar(
      message: "the app was restored",
    ));
  }

  @override
  Widget build(BuildContext context) {
    appState = context.watch<MyAppState>();
    appStateInitialized = true;
    //if (!restored) restore();
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            foregroundImage: NetworkImage(userImageUrl ?? ''),
          ),
        ),
        title: Text(
          UserController.user?.displayName ?? "...",
          overflow: TextOverflow.fade,
          maxLines: 1,
          softWrap: true,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        actions: [
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Projects", style: TextStyle(fontSize: 30)),
                IconButton(
                  onPressed: () {
                    setState(() {
                      appState.sortList();
                    });
                  },
                  padding: EdgeInsets.zero,
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: theme.colorScheme.inverseSurface.withAlpha(100),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.sort),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchValue = value;
                });
              },
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintText: "Search Projects...",
                prefixIcon: const Icon(Icons.search),
                hintStyle: const TextStyle(color: Colors.grey),
                fillColor: theme.colorScheme.inverseSurface.withAlpha(50),
                filled: true,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
              child: (appState.getEvents(searchValue).isEmpty)
                  ? const Center(
                      child: Text("no projects yet"),
                    )
                  : ListView.builder(
                      itemCount: appState.getEvents(searchValue).length,
                      itemBuilder: (context, index) {
                        return Card(
                          //surfaceTintColor: Colors.transparent,
                          //shadowColor: Colors.transparent,

                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          color: appState.getRandomColor(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            key: Key(
                                appState.getEvents(searchValue)[index].name),
                            title: RichText(
                              text: TextSpan(
                                text:
                                    appState.getEvents(searchValue)[index].name,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            subtitle: Text(appState.getFormattedDuration(
                                appState
                                    .getEvents(searchValue)[index]
                                    .duration)),
                            onTap: () {
                              appState.currentParentEvent =
                                  appState.getEvents(searchValue)[index];
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) => ProjectPage())));
                            },
                          )
                          /* ExpTile(
                            key: Key(
                                appState.getEvents(searchValue)[index].name),
                            event: appState.getEvents(searchValue)[index],
                          ) */
                          ,
                        );
                      })
              //Tasks(events: appState.getEvents(searchValue)),
              ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context, builder: (context) => NewCategoryDialog());
        },
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ), //
    );
  }
}

SnackBar snackBar({required String message}) {
  return SnackBar(
    backgroundColor: Colors.transparent, // Set background color to transparent
    elevation: 0, // Remove shadow
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0), // Set border radius
    ),
    content: AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 12.0,
      ),
      decoration: const ShapeDecoration(
          color: Colors.white, // Background color of the SnackBar
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(30))) // Border width
          ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        ),
      ),
    ),
  );
}
