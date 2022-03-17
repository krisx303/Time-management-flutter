import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:quiver/async.dart';
import 'package:time_management/widgets/add_category.dart';
import 'package:time_management/widgets/exercise/add_exercise.dart';
import 'package:time_management/widgets/exercise/triangle.dart';
import 'package:time_management/widgets/exercise_data.dart';
import 'package:time_management/widgets/settings.dart';
import 'package:time_management/widgets/task_data.dart';


class ExercisesWidget extends StatefulWidget {
  const ExercisesWidget({Key? key,}) : super(key: key);
  @override
  _ExercisesWidgetState createState() => _ExercisesWidgetState();
}

class _ExercisesWidgetState extends State<ExercisesWidget> {
  int id1 = 0;
  DateTime start = DateTime(0);
  CountdownTimer? countDownTimer;
  List<String> types = ["", "Sorted by deadline", "Sorted by priority", "Sorted by type"];
  List<Exercise> exercises = databaseExercises;
  String typeString = "";
  int type = 1;

  @override
  void initState() {
    super.initState();
    findFirstTwoTasks();
    startTimer();
    onItemSelected(1);
  }

  void findFirstTwoTasks(){
    start = databaseExercises[id1].deadline;
  }

  void handleClickOption(String option){
    switch(option){
      case "Add task draft":
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const AddExerciseTaskWidget())).then((value) => setState((){
              exercises = databaseExercises;
              onItemSelected(1);
        }));
        break;
      case "Manage task drafts":
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const AddCategoryWidget()));
        break;
    }
  }

  void startTimer() {
    var s = exercises.where((element) => element.deadline.isAfter(DateTime.now())).toList();
    s.sort((a, b) => a.deadline.isAfter(b.deadline) ? 1 : 0);
    print(s.first.deadline);
    countDownTimer = CountdownTimer(
      -DateTime.now().difference(s.first.deadline),
      const Duration(seconds: 1),
    );

    var sub = countDownTimer!.listen(null);
    sub.onData((duration) {
      setState(() {});
    });

    sub.onDone(() {
      exercises = exercises.where((element) => element.deadline.isAfter(DateTime.now())).toList();
      sub.cancel();
      startTimer();
    });
  }



  @override
  void dispose() {
    super.dispose();
    countDownTimer!.cancel();
  }

  @override
  void reassemble() {
    onItemSelected(1);
    super.reassemble();
  }

  void onItemSelected(int id){
    switch(id){
      case 1:
        setState(() {
          type = id;
          typeString = types[id];
          exercises = exercises.where((element) => element.deadline.isAfter(DateTime.now())).toList();
          exercises.sort((a, b) => a.deadline.isAfter(b.deadline) ? 1 : 0);
        });
        break;
      case 2:
        setState(() {
          type = id;
          typeString = types[id];
          exercises = exercises.where((element) => element.deadline.isAfter(DateTime.now())).toList();
          exercises.sort((a, b) => a.priority < b.priority ? 1 : 0);
        });
        break;
      case 3:
        print("Not implemented yet");
        break;
    }
  }

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

  Widget _offsetPopup() => Padding(padding: EdgeInsets.all(15),
    child: Align(alignment: const Alignment(1, 0),child: PopupMenuButton<int>(
      onSelected: onItemSelected,
      tooltip: "Change type",
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 1,
          child: Text(
            "Sort by deadline",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ),
        const PopupMenuItem(
          value: 2,
          child: Text(
            "Sort by priority",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ),
        const PopupMenuItem(
          value: 2,
          child: Text(
            "Sort by type",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ),
      ],
      iconSize: 50,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Exercises - " + typeString),

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
              return Card(
                  elevation: 5,
                  margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    children: [
                      // Container(
                      //   color: getColorByType(databaseExercises[index].type),
                      //   height: 10,
                      // ),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Padding(padding: const EdgeInsets.all(12),child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(exercises[index].name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20), textAlign: TextAlign.end,),
                                    Text("Priority: " + (exercises[index].priority).toString(), style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 18)),
                                    Text("Deadline: " + (-DateTime.now().difference(exercises[index].deadline)).toString().substring(0, 9), style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 22)),
                                  ],
                                )
                              ],
                            ),),
                        Row(children: [
                          Icon(getIconDataByType(exercises[index].type), color: getColorByType(exercises[index].type), size: 60,),
                          CustomPaint(
                            painter: TrianglePainter(
                              strokeColor: getColorByTypeAndData(exercises[index]),
                              strokeWidth: 10,
                              paintingStyle: PaintingStyle.fill,
                            ),child: Container(
                            height: 100,
                            width: 50,
                          ),),
                        ],),
                      ],)
                    ],
                  )
              );
            }
        ),),
      _offsetPopup(),
      ],
      ),
    );
  }
}

