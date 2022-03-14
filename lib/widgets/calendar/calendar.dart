import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:time_management/widgets/calendar/add_calendar_task.dart';
import 'package:time_management/widgets/calendar/calendar_components.dart';

import '../task_data.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  CalendarController controller = CalendarController();
  bool isEventSelected = false;
  Task? selectedTask;

  void onCalendarTap(CalendarTapDetails calendarTapDetails){
    setState(() {
      isEventSelected = calendarTapDetails.appointments?.isNotEmpty == true;
      selectedTask = calendarTapDetails.appointments?.first;
      controller.selectedDate = calendarTapDetails.date;
    });
  }

  void longPressed(CalendarLongPressDetails calendarLongPressDetails) {
    if(calendarLongPressDetails.targetElement != CalendarElement.appointment) {
      return;
    }
    setState(() {
      isEventSelected = false;
      selectedTask = null;
    });
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title:Text(calendarLongPressDetails.appointments?.first.name),
            content:const Text("Date cell "),
            actions: <Widget>[
              FlatButton(onPressed: (){
                Navigator.of(context).pop();
              }, child: const Text('close'))
            ],
          );
        });
  }
  void addEvent(){
    if(controller.selectedDate == null){
      showWarningOnAddTask(context);
    }else{
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => AddCalendarTaskWidget(controller.selectedDate!))).then((value) => { setState((){})});
    }
  }

  void editEvent(){
    print("Edit event:");
    print(selectedTask?.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isEventSelected ? floatingEditEventButton(editEvent): floatingAddEventButton(addEvent),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: Padding(padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: SfCalendar(onLongPress: longPressed,view: CalendarView.workWeek, dataSource: TaskDataSource(_getDataSource()), controller: controller, onTap: onCalendarTap,allowedViews: const <CalendarView>[
          CalendarView.day,
          CalendarView.week,
          CalendarView.workWeek,
          CalendarView.month,
          CalendarView.timelineDay,
          CalendarView.timelineWeek,
          CalendarView.timelineWorkWeek,
          CalendarView.timelineMonth,
          CalendarView.schedule
        ],),)
    );
  }

  List<Task> _getDataSource() {
    return databaseTasks;
  }
}