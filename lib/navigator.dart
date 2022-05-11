import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:time_management/components/app_settings.dart';
import 'package:time_management/components/navigator_components.dart';
import 'package:time_management/widgets/calendar/calendar.dart';
import 'package:time_management/widgets/checkboxes/checkboxes.dart';
import 'package:time_management/widgets/exercise/exercises.dart';
import 'package:time_management/widgets/from_notification_task.dart';
import 'package:time_management/widgets/home/home_widget.dart';

import 'main.dart';

class MainWidget extends StatefulWidget {
  const MainWidget(
      this.notificationAppLaunchDetails, {
        Key? key,
      }) : super(key: key);

  final NotificationAppLaunchDetails? notificationAppLaunchDetails;

  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  @override
  MainWidgetState createState() => MainWidgetState();
}

class MainWidgetState extends State<MainWidget> {
  static int selectedIndex = 2;
  static final List<Widget> _widgetOptions = <Widget>[
    const CheckboxesWidget(),
    const ExercisesWidget(),
    const NewHomeWidget(),
    const CalendarWidget(),
  ];


  @override
  void initState() {
    super.initState();
    _configureSelectNotificationSubject();
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String? payload) async {
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => FromTaskNotifyWidget(payload)));
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        items: <BottomNavigationBarItem>[
          BottomNavigationItem.todos(),
          BottomNavigationItem.tasks(),
          BottomNavigationItem.home(),
          BottomNavigationItem.calendar(),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: mainAppColor,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}