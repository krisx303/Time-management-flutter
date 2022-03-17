import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../main.dart';
import '../widgets/task_data.dart';

Future<void> create10FutureNotifications() async {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;
  prefs.setInt("notifyId", 0);
  await flutterLocalNotificationsPlugin.cancelAll();
  for (var task in databaseTasks) {
    createScheduleNotification(task);
  }
}

Future<void> createScheduleNotification(Task task) async {
  if(task.from.isAfter(DateTime.now()) && task.from.isBefore(DateTime.now().add(const Duration(days: 7)))){
    await zonedScheduleNotification(task, task.from);
  }
  // if(task.repeating != ""){
  //   while(from.isBefore(DateTime.now())){
  //     from = from.add(const Duration(days: 7));
  //   }
  //   await zonedScheduleNotification(task, from);
  // }else if(task.from.isAfter(DateTime.now())){
  //   await zonedScheduleNotification(task, task.from);
  // }
}

Future<void> zonedScheduleNotification(Task task, DateTime when) async {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;
  int notifyId = prefs.getInt("notifyId") ?? 0;
  prefs.setInt("notifyId", notifyId+1);
  print(task.name);
  var iconData = getIconDataByType(task.type);
  var color = getColorByType(task.type);
  var payload = "task_${notifyId}_${task.id}";
  final pictureRecorder = PictureRecorder();
  final canvas = Canvas(pictureRecorder);
  final textPainter = TextPainter(textDirection: TextDirection.ltr);
  final iconStr = String.fromCharCode(iconData.codePoint);
  textPainter.text = TextSpan(
      text: iconStr,
      style: TextStyle(
          letterSpacing: 0.0,
          fontSize: 48.0,
          fontFamily: iconData.fontFamily,
          color: color
      )
  );
  textPainter.layout();
  textPainter.paint(canvas, const Offset(0.0, 0.0));
  final picture = pictureRecorder.endRecording();
  final image = await picture.toImage(48, 48);
  final bytes = await image.toByteData(format: ImageByteFormat.png);
  String base64Image = base64Encode(bytes!.buffer.asUint8List().toList(growable: false));
  await flutterLocalNotificationsPlugin.zonedSchedule(
      notifyId,
      task.name,
      task.description,
      tz.TZDateTime.from(when.subtract(const Duration(hours: 1, minutes: 0)), tz.local),
      NotificationDetails(
          android: AndroidNotificationDetails(
              'task_channel', 'Time Management Task',
              channelDescription: 'Channel for Task Notification from Time Management',
              ongoing: true,
              timeoutAfter: 60 * 60 * 1000,
              showWhen: true,
              icon: "ic_launcher",
              autoCancel: false,
              largeIcon: ByteArrayAndroidBitmap.fromBase64String(base64Image),
              when: when.millisecondsSinceEpoch
          )),
      androidAllowWhileIdle: true,
      payload: payload,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime);
}