import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:time_management/components/navigator_components.dart';
import 'package:time_management/widgets/calendar/calendar.dart';
import 'package:time_management/widgets/exercise/exercises.dart';
import 'package:time_management/widgets/from_notification_task.dart';
import 'package:time_management/widgets/home/home.dart';
import 'package:time_management/widgets/home/sth.dart';

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
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  int _selectedIndex = 1;
  static final List<Widget> _widgetOptions = <Widget>[
    const ExercisesWidget(),
    const HomeWidget(),
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
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        items: const <BottomNavigationBarItem>[
          BottomNavigationItem.tasks(),
          BottomNavigationItem.home(),
          BottomNavigationItem.calendar(),
          //BottomNavigationItem.chart(),
          //BottomNavigationItem.data(),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[400],
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}