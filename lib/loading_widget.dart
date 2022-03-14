import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:time_management/navigator.dart';
import 'package:time_management/widgets/categories_data.dart';
import 'package:time_management/widgets/task_data.dart';

import 'components/push_notification_service.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  bool dCategories = false;
  bool dTasks = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await getUserTaskList(onUserTaskDownloaded);
      await getUserCategories(onUserCategoriesDownloaded);
      await PushNotificationService().initialise();
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

  void checkDownloads() {
    if(dTasks && dCategories){
      Navigator.of(context)
          .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const MainWidget()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(
        children: const [
          Padding(padding: EdgeInsets.fromLTRB(0, 200, 0, 0),),
          Image(image: AssetImage("assets/icons/calendar.png"), color: Colors.blue),
          Padding(padding: EdgeInsets.fromLTRB(0, 100, 0, 0),),
          SizedBox(
            width: 120,
            height: 120,
            child: AnimatedOpacity(
              duration: Duration(seconds: 1),
              opacity: 1.0,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              ),
            ),
          )
        ],
      ),)
    );
  }
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
      tasks.add(Task(doc.id, doc['name'], doc['description'], doc['type'], from, to, doc["repeating"]));
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
    tasks.add(Task(doc.id, doc['name'], doc['description'], doc['type'], nfrom, nfrom.add(between), doc["repeating"]));
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