
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNavigationItem extends BottomNavigationBarItem{
  static const String calendarIconPath = "assets/icons/calendar.png";

  static const String calendarLabel = "Calendar";
  static const String homeLabel = "Home";
  static const String tasksLabel = "Tasks";
  static const String chartLabel = "Charts";
  static const String dataLabel = "Data";
  static const String checkboxLabel = "ToDo";

  const BottomNavigationItem.calendar(): super(
    icon: const ImageIcon(AssetImage(calendarIconPath)),
    label: calendarLabel,
  );

  const BottomNavigationItem.todos(): super(
    icon: const Icon(Icons.task_alt),
    label: checkboxLabel,
  );

  const BottomNavigationItem.home(): super(
    icon: const Icon(Icons.home),
    label: homeLabel,
  );

  const BottomNavigationItem.tasks(): super(
    icon: const Icon(Icons.inventory_rounded),
    label: tasksLabel,
  );

  const BottomNavigationItem.chart(): super(
    icon: const Icon(Icons.insert_chart_outlined_rounded),
    label: chartLabel,
  );

  const BottomNavigationItem.data(): super(
    icon: const Icon(Icons.table_chart_outlined),
    label: dataLabel,
  );
}