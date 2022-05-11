import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:time_management/components/dialogs_components.dart';
import 'package:time_management/translate/translator.dart';
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
  bool isObligatoryOnly = false;

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
    Task task = calendarLongPressDetails.appointments?.first;
    showOptionsDialog(
      context,
      title: calendarLongPressDetails.appointments?.first.name,
      content: translateArgs(Tran.cellDescription, [
        timeToString(task.from),
        timeToString(task.to),
        task.description,
      ]),
      buttons: [
        DialogButton.delete(onPressed: () => {Navigator.pop(context)}),
        DialogButton.edit(onPressed: () => {Navigator.pop(context)}),
      ],
    );
  }

  String timeToString(DateTime time){
    return time.hour.toString().padLeft(2, "0") + ":" + time.minute.toString().padLeft(2, "0");
  }
  void addEvent(){
    if(controller.selectedDate == null){
      showWarningOnAddTask(context);
    }else{
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => AddCalendarTaskWidget(controller.selectedDate!))).then((value) => { setState((){})});
    }
  }

  void onObligatoryChanged(bool? newvalue){
    setState(() {
      isObligatoryOnly = newvalue == true;
    });
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
        child: SfCalendar(onObligatoryChanged, firstDayOfWeek: 1, onLongPress: longPressed,view: CalendarView.week, dataSource: TaskDataSource(_getDataSource()), controller: controller, onTap: onCalendarTap,allowedViews: const <CalendarView>[
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
    if(isObligatoryOnly){
      return databaseTasks.where((element) => element.obligatory).toList();
    }else{
      return databaseTasks;
    }
  }
}