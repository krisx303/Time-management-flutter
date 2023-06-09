import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:time_management/widgets/categories_data.dart';

class TaskDataSource extends CalendarDataSource {
  TaskDataSource(this.source);

  List<Task> source;

  @override
  List<dynamic> get appointments => source;

  @override
  DateTime getStartTime(int index) {
    return source[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return source[index].to;
  }

  @override
  String getSubject(int index) {
    return source[index].name;
  }

  @override
  Color getColor(int index) {
    return getColorByType(source[index].type);
  }

  @override
  bool isAllDay(int index) {
    return false;
  }
}

class Task {
  Task(this.id, this.name, this.description, this.type, this.from, this.to, this.repeating, this.obligatory);
  String id;
  String name;
  String description;
  String type;
  DateTime from;
  DateTime to;
  String repeating;
  bool obligatory;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'from': Timestamp.fromDate(from),
      'to': Timestamp.fromDate(to),
      'repeating': repeating,
      'obligatory': obligatory,
      'refreshing': repeating != "",
    };
  }
}


List<Task> databaseTasks = [];


Color getColorByType(String type){
  Category? c = databaseCategories.firstWhere((element) => element.name == type, orElse: () => Category("null", 0, 0));
  return c.name != "null" ? Color(c.colorCode) : Colors.blue;
}

IconData getIconDataByType(String type){
  int c = databaseCategories.firstWhere((element) => element.name == type).iconCode;
  return IconData(c, fontFamily: 'MaterialIcons');
}