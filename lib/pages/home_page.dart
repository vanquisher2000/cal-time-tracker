import 'package:cal_time_tracker/appState.dart';
import 'package:cal_time_tracker/controller/calendarController.dart';
import 'package:cal_time_tracker/controller/notificationController.dart';
import 'package:cal_time_tracker/controller/userController.dart';
import 'package:cal_time_tracker/pages/login_page.dart';
import 'package:cal_time_tracker/pages/new_project_dialog.dart';
import 'package:cal_time_tracker/pages/project_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  String searchValue = "";

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

    permissionCheck();
    fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.

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
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          color: appState.getRandomColor(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ExpTile(
                            key: Key(
                                appState.getEvents(searchValue)[index].name),
                            event: appState.getEvents(searchValue)[index],
                          ),
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
