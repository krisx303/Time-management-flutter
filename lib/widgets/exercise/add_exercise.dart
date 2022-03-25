import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:time_management/components/app_settings.dart';
import 'package:time_management/components/main_components.dart';
import '../../loading_widget.dart';
import '../calendar/calendar_components.dart';
import '../categories_data.dart';

class AddExerciseTaskWidget extends StatefulWidget {
  const AddExerciseTaskWidget({Key? key}) : super(key: key);

  @override
  State<AddExerciseTaskWidget> createState() => _AddExerciseTaskWidgetState();
}

class _AddExerciseTaskWidgetState extends State<AddExerciseTaskWidget> {
  DateTime deadline = DateTime.now();
  Color colorFrom = Colors.blue;
  Color colorTo = Colors.green;
  late Category _categoryChoose;
  String name = "";
  int priority = 0;
  String description = "";
  bool? refreshing = false;
  String repeating = databaseRepeatingOptions[0];

  @override
  void initState() {
    super.initState();

    _categoryChoose = databaseCategories[0];
  }

  void _onDropDownItemSelected(Category? newCategory) {
    setState(() {
      _categoryChoose = newCategory!;
    });
  }

  String getTextDate(DateTime time){
    return time.hour.toString().padLeft(2, '0') + ':' +
        time.minute.toString().padLeft(2, '0') + ':' +
        time.second.toString().padLeft(2, '0');
  }

  void refreshTime(DateTime time){
    setState(() {
      deadline = time;
    });
  }

  void onNameChanged(String newValue){
    setState(() {
      name = newValue;
    });
  }

  void onPriorityChanged(String newValue){
    if(newValue.isEmpty)
      return;
    setState(() {
      priority = int.parse(newValue);
    });
  }

  void onRepeatingChanged(String? newValue){
    setState(() {
      repeating = newValue!;
    });
  }

  void onRefreshingChanged(bool? newValue){
    setState(() {
      refreshing = newValue;
    });
  }

  void onDescriptionChanged(String newValue){
    setState(() {
      description = newValue;
    });
  }

  void tryConfirm(){
    if(name == "" || priority == 0){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title:const Text("Warning!"),
              content:const Text("Your Task must have a name and priority."),
              actions: <Widget>[
                FlatButton(onPressed: (){
                  Navigator.of(context).pop();
                }, child: const Text('OK'))
              ],
            );
          });
    }else if(refreshing == true){
      sendToFirestoreDraft();
    }else{
      sendToFirestore();
    }
  }

  void sendToFirestore(){
    CollectionReference ref = FirebaseFirestore.instance.collection('users-data').doc("krisuu").collection("to-do");
    ref.add({
      'name': name,
      'priority': priority,
      'description': description,
      'type': _categoryChoose.name,
      'deadline': Timestamp.fromDate(deadline),
    }).then((value) => getUserExercisesList(onSentAndUpdated))
        .catchError((error) => print("Failed to add todo: $error"));
  }

  void sendToFirestoreDraft(){
    CollectionReference ref = FirebaseFirestore.instance.collection('users-data').doc("krisuu").collection("to-do-draft");
    ref.add({
      'name': name,
      'priority': priority,
      'description': description,
      'type': _categoryChoose.name,
      'deadline': Timestamp.fromDate(deadline),
      'refresh': repeating,
      'refreshing': refreshing == true,
    }).then((value) => getUserExercisesList(onSentAndUpdated))
        .catchError((error) => print("Failed to add draft: $error"));
  }

  void onSentAndUpdated(){
    setState(() {

    });
    Navigator.of(context).pop();
  }

  Future<void> datePicker() async{
    var result = await showDatePicker(context: context, initialDate: DateTime.now(),
        firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 1000)));
    if(result != null) {
      setState(() {
        deadline = DateTime.utc(result.year, result.month, result.day, deadline.hour, deadline.minute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainAppColor,
        title: const Text("Add new Task"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
        body: SingleChildScrollView(child: Column(
          children: <Widget>[
            const Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Card(child: Padding(padding: const EdgeInsets.fromLTRB(10, 16, 10, 16), child: Column(
                children: [
                  Image.asset("assets/icons/calendar.png", color: Colors.blue,),
                  GFButton(text: "Pick date", onPressed: datePicker),
                ],
              ),),elevation: 5,),
              Card(child: hourMinute5IntervalWidget(deadline, refreshTime, color: colorTo), elevation: 5,),
            ],),
            DateTimeTextContainer(deadline, colorFrom, colorTo),
            enterTaskNameWidget(onNameChanged),
            enterTaskPriorityWidget(onPriorityChanged),
            enterTaskDescriptionWidget(onDescriptionChanged),
            categoryPicker(_categoryChoose, _onDropDownItemSelected),
            Row(mainAxisAlignment: MainAxisAlignment.center ,children: [
              const Text("Task is repeating?"),
              Checkbox(value:refreshing, onChanged: onRefreshingChanged ),
            ],),
            repeatingPicker(repeating, onRepeatingChanged, refreshing == true),
            ConfirmButton(tryConfirm: tryConfirm),
          ],
        ),)
    );
  }
}