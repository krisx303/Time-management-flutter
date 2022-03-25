import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:time_management/components/app_settings.dart';
import 'package:time_management/components/main_components.dart';
import 'package:time_management/widgets/task_data.dart';
import '../../loading_widget.dart';
import '../categories_data.dart';
import 'calendar_components.dart';

class AddCalendarTaskWidget extends StatefulWidget {
  final DateTime selectedDate;
  const AddCalendarTaskWidget(this.selectedDate, {Key? key}) : super(key: key);

  @override
  State<AddCalendarTaskWidget> createState() => _AddCalendarTaskWidgetState();
}

class _AddCalendarTaskWidgetState extends State<AddCalendarTaskWidget> {
  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();
  Color colorFrom = Colors.blue;
  Color colorTo = Colors.green;
  late Category _categoryChoose;
  String name = "";
  String description = "";
  bool? refreshing = false;
  bool? obligatory = false;
  String repeating = databaseRepeatingOptions[0];

  @override
  void initState() {
    super.initState();
    dateFrom = widget.selectedDate;
    dateTo = widget.selectedDate.add(const Duration(minutes: 15));
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

  void refreshTimeTo(DateTime time){
    setState(() {
      dateTo = time;
    });
  }

  void refreshTimeFrom(DateTime time){
    setState(() {
      dateFrom = time;
    });
  }

  void onNameChanged(String newValue){
    setState(() {
      name = newValue;
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

  void onObligatoryChanged(bool? newValue){
    setState(() {
      obligatory = newValue;
    });
  }

  void onDescriptionChanged(String newValue){
    setState(() {
      description = newValue;
    });
  }

  void tryConfirm(){
    if(name == ""){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title:const Text("Warning!"),
              content:const Text("Your Task must have a name."),
              actions: <Widget>[
                FlatButton(onPressed: (){
                  Navigator.of(context).pop();
                }, child: const Text('OK'))
              ],
            );
          });
    }else{
      if(dateTo.isAtSameMomentAs(dateFrom)){
        showDialogWarningDatesSame(context);
      }
      else if(dateTo.isBefore(dateFrom)){
        showDialogWarningBefore(context, sendTheNextDay);
      }else{
        sendToFirestore();
      }
      }
    }

  void sendTheNextDay(){
      dateTo = dateTo.add(const Duration(days: 1));
      sendToFirestore();
  }

  void sendToFirestore(){
    CollectionReference ref = FirebaseFirestore.instance.collection('users-data').doc("krisuu").collection("schedule");
    ref.add({
      'name': name,
      'description': description,
      'type': _categoryChoose.name,
      'from': Timestamp.fromDate(dateFrom),
      'to': Timestamp.fromDate(dateTo),
      'repeating': repeating,
      'obligatory': obligatory,
      'refreshing': refreshing,
    }).then((value) => getUserTaskList(onSentAndUpdated))
        .catchError((error) => showToast(error));
  }

  void onSentAndUpdated(){
    setState(() {});
    showToast("Task sent successfully :)");
    Navigator.of(context).pop();
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
              Card(child: hourMinute5IntervalWidget(dateFrom, refreshTimeFrom, color: colorFrom), elevation: 5,),
              Card(child: hourMinute5IntervalWidget(dateTo, refreshTimeTo, color: colorTo), elevation: 5,),
            ],),
            DateTextContainer(getTextDate(dateFrom), getTextDate(dateTo), colorFrom, colorTo),
            enterTaskNameWidget(onNameChanged),
            enterTaskDescriptionWidget(onDescriptionChanged),
            categoryPicker(_categoryChoose, _onDropDownItemSelected),
            Row(mainAxisAlignment: MainAxisAlignment.center ,children: [
              const Text("Task is obligatory?"),
              Checkbox(value:obligatory, onChanged: onObligatoryChanged ),
            ],),
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