import 'package:flutter/material.dart';
import 'package:time_management/translate/translator.dart';


final String checkboxLabel = translate(Tran.lists);
final String tasksLabel = translate(Tran.tasks);
final String homeLabel = translate(Tran.timeline);
final String calendarLabel = translate(Tran.calendar);

class BottomNavigationItem extends BottomNavigationBarItem{
  static const String calendarIconPath = "assets/icons/calendar.png";
  static const String chartLabel = "Charts";
  static const String dataLabel = "Data";

  BottomNavigationItem.calendar(): super(
    icon: const ImageIcon(AssetImage(calendarIconPath)),
    label: calendarLabel,
  );

  BottomNavigationItem.todos(): super(
    icon: const Icon(Icons.task_alt),
    label: checkboxLabel,
  );

  BottomNavigationItem.home(): super(
    icon: const Icon(Icons.home),
    label: homeLabel,
  );

  BottomNavigationItem.tasks(): super(
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