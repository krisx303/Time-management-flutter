import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:time_management/components/app_settings.dart';
import 'package:time_management/components/notification_helper.dart';
import 'package:time_management/navigator.dart';
import 'package:time_management/widgets/categories_data.dart';
import 'package:time_management/widgets/checkboxes/checkbox_data.dart';
import 'package:time_management/widgets/from_notification_task.dart';
import 'package:time_management/widgets/home/home.dart';
import 'package:time_management/widgets/task_data.dart';

import 'components/push_notification_service.dart';
import 'widgets/exercise_data.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget(
      this.payload,
      this.initialRoute,
      this.notificationAppLaunchDetails, {
        Key? key,
      }) : super(key: key);

  static const String routeName = '/';

  final NotificationAppLaunchDetails? notificationAppLaunchDetails;
  final String? initialRoute;
  final String? payload;

  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  @override
  _LoadingWidgetState createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  bool dCategories = false;
  bool dTasks = false;
  bool dExercises = false;
  bool dCheckboxes = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await PushNotificationService().initialise();
      await getUserTaskList(onUserTaskDownloaded);
      await getUserCategories(onUserCategoriesDownloaded);
      await getUserExercisesList(onUserExercisesDownloaded);
      await getUserCheckboxesList(onUserCheckboxesDownloaded);
    });
  }

  void onUserTaskDownloaded(){
    dTasks = true;
    checkDownloads();
  }

  void onUserCategoriesDownloaded(){
    dCategories = true;
    checkDownloads();
  }

  void onUserExercisesDownloaded(){
    dExercises = true;
    checkDownloads();
  }

  void onUserCheckboxesDownloaded(){
    dCheckboxes = true;
    checkDownloads();
  }

  void checkDownloads() {
    if(dTasks && dCategories && dExercises && dCheckboxes){
      create10FutureNotifications();
      if(widget.initialRoute == FromTaskNotifyWidget.routeName){
        Navigator.of(context)
            .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => FromTaskNotifyWidget(widget.payload)), (route) => false);
      }else{
        Navigator.of(context)
            .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MainWidget(widget.notificationAppLaunchDetails)), (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(
        children: [
          const Padding(padding: EdgeInsets.fromLTRB(0, 200, 0, 0),),
          Image(image: const AssetImage("assets/icons/calendar.png"), color: mainAppColor),
          const Padding(padding: EdgeInsets.fromLTRB(0, 100, 0, 0),),
          SizedBox(
            width: 120,
            height: 120,
            child: AnimatedOpacity(
              duration: const Duration(seconds: 1),
              opacity: 1.0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  color: mainAppColor,
                ),
              ),
            ),
          )
        ],
      ),)
    );
  }
}

Future<void> getUserCheckboxesList(VoidCallback onDownloaded) async {
  CollectionReference _collectionRef =
  FirebaseFirestore.instance.collection('users-data').doc('krisuu').collection('checkboxes');
  QuerySnapshot querySnapshot = await _collectionRef.get();
  List<CheckboxData> checkboxes = [];
  for(int i = 0; i<querySnapshot.size; i++){
    var doc = querySnapshot.docs[i];
    print(doc.data());
    checkboxes.add(CheckboxData.fromJson(doc.id, doc.data()));
  }
  databaseCheckboxes = checkboxes;
  onDownloaded();
}

Future<void> getUserExercisesList(VoidCallback onDownloaded) async {
  CollectionReference _collectionRef =
  FirebaseFirestore.instance.collection('users-data').doc('krisuu').collection('to-do');
  QuerySnapshot querySnapshot = await _collectionRef.get();
  List<Exercise> exercises = [];
  for(int i = 0; i<querySnapshot.size; i++){
    var doc = querySnapshot.docs[i];
    Timestamp deadline = doc["deadline"];
    DateTime d = deadline.toDate();
    exercises.add(Exercise(doc.id, doc["name"], doc["description"], doc["type"], d, doc["priority"]));
  }
  databaseExercises = exercises;
  onDownloaded();
}


Future<void> getUserTaskList(VoidCallback onDownloaded) async {
  CollectionReference _collectionRef =
  FirebaseFirestore.instance.collection('users-data').doc('krisuu').collection('schedule');
  QuerySnapshot querySnapshot = await _collectionRef.get();
  List<Task> tasks = [];
  for(int i = 0; i<querySnapshot.size; i++){
    var doc = querySnapshot.docs[i];
    Timestamp tsfrom = doc["from"];
    Timestamp tsto = doc["to"];
    DateTime from = tsfrom.toDate();
    DateTime to = tsto.toDate();
    Duration between = to.difference(from);
    bool refreshing = doc["refreshing"];
    if(refreshing){
      switch(doc["repeating"]){
        case "every_week":
          repeatingEveryWeek(from, doc, between, tasks);
          break;
      }
    }
    else{
      tasks.add(Task(doc.id, doc['name'], doc['description'], doc['type'], from, to, doc["repeating"], doc['obligatory']));
    }
  }
  databaseTasks = tasks;
  onDownloaded();
}

void repeatingEveryWeek(DateTime from, doc, Duration between, List<Task> tasks) {
  DateTime dt = DateTime.now().subtract(const Duration(days: 7));
  while(dt.isAfter(from)){
    from = from.add(const Duration(days: 7));
  }
  for(int i = 0; i<4;i++){
    DateTime nfrom = from.add(Duration(days: (i*7)));
    tasks.add(Task(doc.id, doc['name'], doc['description'], doc['type'], nfrom, nfrom.add(between), doc["repeating"], doc['obligatory']));
  }
}


Future<void> getUserCategories(VoidCallback onDownloaded) async {
  CollectionReference _collectionRef =
  FirebaseFirestore.instance.collection('users-data').doc('krisuu').collection('categories');
  QuerySnapshot querySnapshot = await _collectionRef.get();
  List<Category> categories = [];
  for(int i = 0; i<querySnapshot.size; i++){
    var doc = querySnapshot.docs[i];
    categories.add(Category(doc["name"], doc["color"], doc["icon"]));
  }
  databaseCategories = categories;
  onDownloaded();
}