import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiver/async.dart';
import 'package:time_management/components/app_settings.dart';
import 'package:time_management/components/dialogs_components.dart';
import 'package:time_management/components/dismissible_components.dart';
import 'package:time_management/components/main_components.dart';
import 'package:time_management/widgets/add_category.dart';
import 'package:time_management/widgets/exercise/add_exercise.dart';
import 'package:time_management/widgets/exercise_data.dart';
import 'package:time_management/widgets/task_data.dart';

import '../../navigator.dart';


class ExercisesWidget extends StatefulWidget {
  const ExercisesWidget({Key? key,}) : super(key: key);
  @override
  _ExercisesWidgetState createState() => _ExercisesWidgetState();
}

class _ExercisesWidgetState extends State<ExercisesWidget> {
  CountdownTimer? countDownTimer;
  List<String> types = ["", "Sorted by deadline", "Sorted by priority", "Sorted by type"];
  List<Exercise> exercises = databaseExercises;
  String typeString = "";
  int type = 1;

  @override
  void initState() {
    super.initState();
    startTimer();
    onSortingTypeSelected(type);
  }

  /// Handles popup menu item click
  void handleClickOption(String option){
    switch(option){
      case "Add task draft":
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const AddExerciseTaskWidget())).then((value) => setState((){
              exercises = databaseExercises;
              onSortingTypeSelected(type);
        }));
        break;
      case "Manage task drafts":
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const AddCategoryWidget()));
        break;
    }
  }

  /// Starts main timer
  void startTimer() {
    //var s = exercises.where((element) => element.deadline.isAfter(DateTime.now())).toList();
    var s = List.from(exercises);
    s.sort((a, b) => a.deadline.isAfter(b.deadline) ? 1 : 0);
    if(s.isEmpty){
      return;
    }
    countDownTimer = CountdownTimer(
      -DateTime.now().difference(s.first.deadline),
      const Duration(seconds: 1),
    );

    var sub = countDownTimer!.listen(null);
    sub.onData((duration) {
      setState(() {});
    });

    sub.onDone(() {
      //exercises = exercises.where((element) => element.deadline.isAfter(DateTime.now())).toList();
      sub.cancel();
      if(MainWidgetState.selectedIndex == 1) {
        startTimer();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if(countDownTimer != null){
      countDownTimer!.cancel();
    }
  }

  @override
  void reassemble() {
    onSortingTypeSelected(type);
    super.reassemble();
  }

  /// Handles sorting types popup menu item click
  void onSortingTypeSelected(int id){
    switch(id){
      case 1:
        setState(() {
          type = id;
          typeString = types[id];
          //exercises = exercises.where((element) => element.deadline.isAfter(DateTime.now())).toList();
          exercises.sort((a, b) => a.deadline.isAfter(b.deadline) ? 1 : 0);
        });
        break;
      case 2:
        setState(() {
          type = id;
          typeString = types[id];
          //exercises = exercises.where((element) => element.deadline.isAfter(DateTime.now())).toList();
          exercises.sort((a, b){
            if(a.deadline.isBefore(DateTime.now())){
              if(b.deadline.isBefore(DateTime.now())){
                return a.priority < b.priority ? 1 : 0;
              }else{
                return 0;
              }
            }else{
              if(b.deadline.isBefore(DateTime.now())){
                return 1;
              }else{
                return a.priority < b.priority ? 1 : 0;
              }
            }
          });
          //exercises.sort((a, b) => a.priority < b.priority ? 1 : 0);
        });
        break;
      case 3:
        print("Not implemented yet");
        break;
    }
  }

  /// Gets color by actual sorting and exercise data
  Color getColorByTypeAndData(Exercise exercise){
    switch(type){
      case 1:
        int hour = exercise.deadline.difference(DateTime.now()).inHours;
        if(hour < 24) {
          return Colors.red;
        }else if(hour < 72){
          return Colors.orangeAccent;
        }else{
          return Colors.lightGreen;
        }
      case 2:
        int pr = exercise.priority;
        if(pr >= 9) {
          return Colors.red;
        }else if(pr >= 5){
          return Colors.orangeAccent;
        }else{
          return Colors.lightGreen;
        }
      default:
        return Colors.blue;
    }
  }

  /// 'Floating button' with popup menu sorting types
  Widget _offsetPopup() => Padding(
    padding: const EdgeInsets.all(5),
    child: Align(alignment: const Alignment(1, 0),child: PopupMenuButton<int>(
      onSelected: onSortingTypeSelected,
      tooltip: "Change type",
      itemBuilder: (context) => [
        createPopupMenuItem(1, "Sort by deadline"),
        createPopupMenuItem(2, "Sort by priority"),
        createPopupMenuItem(3, "Sort by type"),
      ],
      iconSize: 56,
      icon: Container(
        height: double.infinity,
        width: double.infinity,
        child: const Icon(Icons.list, size: 30, color: Colors.white,),
        decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
        ),
        //child: Icon(Icons.menu, color: Colors.white), <-- You can give your icon here
      )
  ),),);

  /// Method shows dialog to ask if user want to delete exercise
  Future<bool?> onExerciseSwiped(DismissDirection direction, int index) async {
    if (direction == DismissDirection.endToStart) {
      final bool? res = await showDialogWantToDelete(context, "Are you sure you want to delete exercise ${exercises[index].name}?", "Deleting exercise", () => onWantDeleteExercise(index));
      return res == true;
    }else if (direction == DismissDirection.startToEnd){
      final bool? res = await showDialogConfirm(context, "Mark ${exercises[index].name} as completed task?", "Confirming", () => onConfirmed(index));
      return res == true;
    }
    return false;
  }

  /// Action when user want delete exercise
  void onWantDeleteExercise(int index) async {
     CollectionReference ref = FirebaseFirestore.instance.collection('users-data').doc(mainAppName).collection('to-do');
     ref.doc(exercises[index].id).delete();
     exercises.removeAt(index);
  }

  /// Action when user confirmed completed task
  void onConfirmed(int index) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('users-data').doc(mainAppName).collection('to-do');
    ref.doc(exercises[index].id).delete();
    ref = FirebaseFirestore.instance.collection('users-data').doc(mainAppName).collection('to-do-archive');
    ref.add({
      'name': exercises[index].name,
      'description': exercises[index].description,
      'type': exercises[index].type,
      'deadline': Timestamp.fromDate(exercises[index].deadline),
      'priority': exercises[index].priority,
      'confirmed': Timestamp.now(),
    });
    exercises.removeAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Exercises - " + typeString),
          backgroundColor: mainAppColor,
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (e) => handleClickOption(e),
              itemBuilder: (BuildContext context) {
                return {'Add task draft', 'Manage task drafts'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
      body: Column(children: [
        Flexible(child:
        ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: exercises.length,
            itemBuilder: (BuildContext context, int index) {
              String deadline = "";
              Duration das = (-DateTime.now().difference(exercises[index].deadline));
              deadline = "${das.inDays} days ${das.inHours%24} h ${das.inMinutes%60} m ${das.inSeconds%60} s";
              if(exercises[index].deadline.isBefore(DateTime.now())){
                return Dismissible(
                  background: slideRightDoneBackground(),
                  secondaryBackground: slideLeftDeleteBackground(),
                  confirmDismiss: (direction) => onExerciseSwiped(direction, index),
                  key: Key(exercises[index].name),
                  child: CardElement(
                      content: [
                        CardMainContent(
                            content: [
                              Text(exercises[index].name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
                              Text("Priority: " + (exercises[index].priority).toString(), style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 18)),
                              const Text("Overdue :(", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
                            ]
                        ),
                        Row(children: [
                          Icon(getIconDataByType(exercises[index].type), color: getColorByType(exercises[index].type), size: 60,),
                          TriangleRight(color: Colors.grey),
                        ],),
                      ]
                  ),
                );
              }else{
                return Dismissible(
                  background: slideRightDoneBackground(),
                  secondaryBackground: slideLeftDeleteBackground(),
                  confirmDismiss: (direction) => onExerciseSwiped(direction, index),
                  key: Key(exercises[index].name),
                  child: CardElement(
                      content: [
                        CardMainContent(
                            content: [
                              Text(exercises[index].name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
                              Text("Priority: " + (exercises[index].priority).toString(), style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 18)),
                              Text(deadline, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
                            ]
                        ),
                        Row(children: [
                          Icon(getIconDataByType(exercises[index].type), color: getColorByType(exercises[index].type), size: 60,),
                          TriangleRight(color: getColorByTypeAndData(exercises[index])),
                        ],),
                      ]
                  ),
                );
              }
            }
        ),),
      _offsetPopup(),
      ],
      ),
    );
  }
}