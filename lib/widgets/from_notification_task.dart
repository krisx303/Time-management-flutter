import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_management/widgets/task_data.dart';

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

  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
    print("qwuiey");
    print(databaseTasks.first.name);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Second Screen with payload: ${_payload ?? ''}'),
    ),
    body: Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(_payload ?? "asd"),
      ),
    ),
  );
}