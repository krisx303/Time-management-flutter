import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:time_management/widgets/calendar/time_picker.dart';

import '../categories_data.dart';

Padding floatingAddEventButton(VoidCallback _onPressed){
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
    child: FloatingActionButton(
      onPressed: _onPressed,
      backgroundColor: Colors.green,
      child: const Icon(Icons.add),
    ),
  );
}

Padding floatingEditEventButton(VoidCallback _onPressed){
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
    child: FloatingActionButton(
      onPressed: _onPressed,
      backgroundColor: Colors.green,
      child: const Icon(Icons.edit),
    ),
  );
}

Padding enterTaskNameWidget(Function(String newValue) onChanged){
  return Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 10), child: TextField(
    onChanged: onChanged,
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      labelText: 'Task Name',
      hintText: 'Enter Task Name',
    ),
  ),);
}

Padding enterTaskPriorityWidget(Function(String newValue) onChanged){
  return Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 10), child: TextField(
    onChanged: onChanged,
    keyboardType: TextInputType.number,
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      labelText: 'Task Priority',
      hintText: 'Enter Task Priority',
    ),
  ),);
}

Padding enterTaskDescriptionWidget(Function(String newValue) onChanged){
  return Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 0), child: TextField(
    onChanged: onChanged,
    decoration: const InputDecoration(
      hintText: 'Description',
      labelText: 'Description:',
    ),
    autofocus: false,
    maxLines: null,
    keyboardType: TextInputType.text,
  ),);
}

void showToast(String text) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
  );
}

Future<void> showWarningOnAddTask(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Warning'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('You must select Date on calendar to create new Task'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Widget hourMinute5IntervalWidget(DateTime date, Function(DateTime) onTimeChange, {Color? color}){
  return Padding(padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),child: TimePickerSpinner(
    time: date,
    isForce2Digits: true,
    normalTextStyle: const TextStyle(fontSize: 20, color: Colors.grey),
    highlightedTextStyle: TextStyle(fontSize: 32, color: color),
    alignment: Alignment.center,
    spacing: 20,
    minutesInterval: 1,
    onTimeChange: (time) => onTimeChange(time),
  ));
}


class DateTextContainer extends Container{
  DateTextContainer(String dateTextFrom, String dateTextTo, Color colorFrom, Color colorTo, {Key? key}) : super(key: key,
    margin: const EdgeInsets.symmetric(
      vertical: 40
    ),
    child: RichText(
        text: TextSpan(
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
            children: <TextSpan>[
              const TextSpan(text: "From: "),
              TextSpan(text: dateTextFrom, style: TextStyle(color: colorFrom, fontWeight: FontWeight.bold, fontSize: 20)),
              const TextSpan(text: " To: "),
              TextSpan(text: dateTextTo, style: TextStyle(color: colorTo, fontWeight: FontWeight.bold, fontSize: 20))
            ]
        )
    ),
  );
}

class DateTimeTextContainer extends Container{
  DateTimeTextContainer(DateTime deadline, Color colorFrom, Color colorTo, {Key? key}) : super(key: key,
    margin: const EdgeInsets.symmetric(
        vertical: 40
    ),
    child: RichText(
        text: TextSpan(
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
            children: <TextSpan>[
              const TextSpan(text: "Date: "),
              TextSpan(text: getTextDate(deadline), style: TextStyle(color: colorFrom, fontWeight: FontWeight.bold, fontSize: 20)),
              const TextSpan(text: " Time: "),
              TextSpan(text: getTextTime(deadline), style: TextStyle(color: colorTo, fontWeight: FontWeight.bold, fontSize: 20))
            ]
        )
    ),
  );
}

String getTextDate(DateTime time){
  return time.day.toString().padLeft(2, '0') + '/' +
      time.month.toString().padLeft(2, '0') + '/' +
      time.year.toString();
}

String getTextTime(DateTime time){
  return time.hour.toString().padLeft(2, '0') + ':' +
      time.minute.toString().padLeft(2, '0') + ':' +
      time.second.toString().padLeft(2, '0');
}

List<String> databaseRepeatingOptions = <String>["every_week", "every_day", "every_month_that_day", "every_second_day"];


Container repeatingPicker(String _repeatingChoose, Function(String?) _onDropDownItemSelected, bool refreshing){
  return refreshing ? Container(
    margin: const EdgeInsets.only(left: 15, top: 20, right: 15, bottom: 15),
    child: InputDecorator(
          decoration: InputDecoration(
              contentPadding:
              const EdgeInsets.fromLTRB(12, 10, 20, 20),
              labelText: "Repeating:",
              border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(10.0))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: "verdana_regular",
              ),
              hint: const Text(
                "Select repeating",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontFamily: "verdana_regular",
                ),
              ),
              items: databaseRepeatingOptions
                  .map<DropdownMenuItem<String>>(
                      (String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(value),
                        ],
                      ),
                    );
                  }).toList(),

              isExpanded: true,
              isDense: true,
              onChanged: (newSelectedCategory) => {_onDropDownItemSelected(newSelectedCategory)},
              value: _repeatingChoose,
            ),
          ),
  )) : Container();
}

Container categoryPicker(Category _categoryChoose, Function(Category?) _onDropDownItemSelected){
  return Container(
    margin: const EdgeInsets.only(left: 15, top: 40, right: 15, bottom: 15),
    child: FormField<String>(
      builder: (FormFieldState<String> state) {
        return InputDecorator(
          decoration: InputDecoration(
              contentPadding:
              const EdgeInsets.fromLTRB(12, 10, 20, 20),
              labelText: "Category:",
              border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(10.0))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Category>(
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: "verdana_regular",
              ),
              hint: const Text(
                "Select category",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontFamily: "verdana_regular",
                ),
              ),
              items: databaseCategories
                  .map<DropdownMenuItem<Category>>(
                      (Category value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(IconData(value.iconCode, fontFamily: 'MaterialIcons'), color: Color(value.colorCode)),
                          const SizedBox(width: 15,),
                          Text(value.name),
                        ],
                      ),
                    );
                  }).toList(),

              isExpanded: true,
              isDense: true,
              onChanged: (newSelectedCategory) => {_onDropDownItemSelected(newSelectedCategory)},
              value: _categoryChoose,
            ),
          ),
        );
      },
    ),
  );
}


void showDialogWarningDatesSame(BuildContext context){
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:const Text("Warning!"),
          content:const Text("Time Start and Stop are the same! Change this!"),
          actions: <Widget>[
            FlatButton(onPressed: (){
              Navigator.of(context).pop();
            }, child: const Text('OK'))
          ],
        );
      });
}

void showDialogWarningBefore(BuildContext context, VoidCallback sendTheNextDay){
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:const Text("Warning!"),
          content:const Text("The time end is before start! Do you know want to end task on the next day?"),
          actions: <Widget>[
            FlatButton(onPressed: sendTheNextDay, child: const Text('Yes')),
            FlatButton(onPressed: (){
              Navigator.of(context).pop();
            }, child: const Text("It's mistake"))
          ],
        );
      });
}

void showDialogWarningNoNameCategory(BuildContext context){
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:const Text("Warning!"),
          content:const Text("Your Category must have a name."),
          actions: <Widget>[
            FlatButton(onPressed: (){
              Navigator.of(context).pop();
            }, child: const Text('OK'))
          ],
        );
      });
}

void showDialogWarningIconChange(BuildContext context, VoidCallback send){
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:const Text("Warning!"),
          content:const Text("Did you know that you can change icon by clicking on the actual icon? :)"),
          actions: <Widget>[
            FlatButton(onPressed: send, child: const Text('Yes, confirm')),
            FlatButton(onPressed: (){
              Navigator.of(context).pop();
            }, child: const Text("Wait, what?"))
          ],
        );
      });
}