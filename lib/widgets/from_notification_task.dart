import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_management/widgets/categories_data.dart';
import 'package:time_management/widgets/task_data.dart';

import '../components/notification_helper.dart';
import '../main.dart';

class FromTaskNotifyWidget extends StatefulWidget {
  const FromTaskNotifyWidget(
      this.payload, {
        Key? key,
      }) : super(key: key);

  static const String routeName = '/secondPage';

  final String? payload;

  @override
  State<StatefulWidget> createState() => FromTaskNotifyWidgetState();
}

class FromTaskNotifyWidgetState extends State<FromTaskNotifyWidget> {
  String? _payload;
  late Task task;
  late Color color;
  late IconData iconData;
  late int notifyId;
  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
    notifyId = int.parse(_payload!.split("_")[1]);
    String id = _payload!.split("_")[2];
    task = databaseTasks.where((element) => element.id == id).first;
    color = getColorByType(task.type);
    iconData = getIconDataByType(task.type);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: getColorByType(task.type),
      title: const Text('Task Notification Pane'),
      actions: [
        MaterialButton(
          onPressed: () {},
          color: Colors.white,
          textColor: color,
          child: Icon(
            iconData,
            size: 30,
          ),
          padding: const EdgeInsets.all(10),
          shape: const CircleBorder(),
        ),
      ],
    ),
    body: Center(
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
          Card(child: Padding(padding: const EdgeInsets.all(80), child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(task.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              const Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 15)),
              Text(task.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
            ],
          ),),),
          ElevatedButton(
            style: ElevatedButton.styleFrom(primary: color),
            onPressed: () async {
              await flutterLocalNotificationsPlugin.cancel(notifyId);
            },
            child: const Text("Remove notification"),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 60)),
          MaterialButton(
            onPressed: () {
              zonedScheduleNotification(task, DateTime.now().add(const Duration(hours: 14, minutes: 36)));
            },
            color: Colors.white,
            textColor: color,
            child: Icon(
              iconData,
              size: 60,
            ),
            padding: EdgeInsets.all(16),
            shape: CircleBorder(),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
          const Text("Recreate notification", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),)
        ],
      )
    ),
  );
}