import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quiver/async.dart';
import 'package:time_management/widgets/add_category.dart';
import 'package:time_management/widgets/settings.dart';
import 'package:time_management/widgets/task_data.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  bool hasFirst = false;
  bool hasSecond = false;
  int id1 = 0, id2 = 1;
  DateTime start = DateTime(0);
  DateTime start2 = DateTime(0);
  Task firstTask = databaseTasks.first;
  Task secondTask = databaseTasks[1];
  CountdownTimer? countDownTimer;
  @override
  void initState() {
    super.initState();
    findFirstTwoTasks();
    if(hasFirst){
      startTimer();
    }
  }

  void findFirstTwoTasks(){
    List<Task> list = databaseTasks.where((element) => element.from.isAfter(DateTime.now())).toList();
    hasFirst = list.isNotEmpty;
    hasSecond = list.length > 1;
    if(!hasSecond){
      return;
    }
    if(list[1].from.isBefore(list[0].from)){
      id1 = 1;
      id2 = 0;
    }
    for(int i = 2; i<list.length; i++){
      if(list[id2].from.isAfter(list[i].from)){
        if(list[id1].from.isAfter(list[i].from)){
          id2 = id1;
          id1 = i;
        }else{
          id2 = i;
        }
      }
    }
    start = list[id1].from;
    start2 = list[id2].from;
    firstTask = list[id1];
    secondTask = list[id2];
  }

  void handleClickOption(String option){
    print(option);
    switch(option){
      case "Settings":
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const SettingsWidget()));
        break;
      case "Add Category":
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const AddCategoryWidget()));
        break;
    }
  }

  void startTimer() {
    countDownTimer = CountdownTimer(
      -DateTime.now().difference(start),
      const Duration(seconds: 1),
    );

    var sub = countDownTimer!.listen(null);
    sub.onData((duration) {
      setState(() {});
    });

    sub.onDone(() {
      sub.cancel();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    countDownTimer!.cancel();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Welcome back krisuu'),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (e) => handleClickOption(e),
              itemBuilder: (BuildContext context) {
                return {'Add Category', 'Settings'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
      body: SingleChildScrollView(child: Column(
        children: [
          Card(
            elevation: 5,
            margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              children: [
                Container(
                  color: getColorByType(firstTask.type),
                  height: 10,
                ),
                Padding(padding: const EdgeInsets.all(12),child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(firstTask.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20), textAlign: TextAlign.end,),
                            Text(firstTask.description, style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 18)),
                            Text("Starts in: " + (-DateTime.now().difference(start)).toString().substring(0, 8), style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 22)),
                          ],
                        )
                      ],
                    ),
                    Icon(getIconDataByType(firstTask.type), color: getColorByType(firstTask.type), size: 80,),
                  ],
                ),)
              ],
            )
          ),
          Card(
              elevation: 5,
              margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                children: [
                  Container(
                    color: getColorByType(secondTask.type),
                    height: 10,
                  ),
                  Padding(padding: const EdgeInsets.all(12),child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(secondTask.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20), textAlign: TextAlign.end,),
                              Text(secondTask.description, style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 18)),
                              Text("Starts in: " + (-DateTime.now().difference(start2)).toString().substring(0, 8), style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 22)),
                            ],
                          )
                        ],
                      ),
                      Icon(getIconDataByType(secondTask.type), color: getColorByType(secondTask.type), size: 80,),
                    ],
                  ),)
                ],
              )
          ),
          TextButton(onPressed: _showNotificationHourly, child: Text('asjidbasijd'))
        ],
      ),)
    );
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

// hourly notification schedule config, set to either `hours: 1` or `minutes: 60`

  Future<void> _showNotificationHourly() async {
    tz.initializeTimeZones();
    var scheduledNotificationDateTime =
    DateTime.now().add(const Duration(minutes: 60));
    AndroidNotificationDetails androidPlatformChannelSpecifics =  const AndroidNotificationDetails('your other channel id', 'your other channel name', channelDescription: 'your other channel description',);
    IOSNotificationDetails iOSPlatformChannelSpecifics =
    const IOSNotificationDetails();
    MacOSNotificationDetails macOSPlatformChannelSpecifics =
    const MacOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
    macOS: macOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'scheduled title',
    'scheduled body',
      tz.TZDateTime.from(DateTime.now().add(Duration(hours: 3)), tz.local),
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
    UILocalNotificationDateInterpretation.absoluteTime,);
  }
}