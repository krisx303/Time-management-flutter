import 'package:flutter/material.dart';
import 'package:time_management/components/navigator_components.dart';
import 'package:time_management/widgets/calendar/calendar.dart';
import 'package:time_management/widgets/home/home.dart';
import 'package:time_management/widgets/home/sth.dart';

class MainWidget extends StatefulWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  int _selectedIndex = 1;
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeWidget(),
    const HomeWidget(),
    const CalendarWidget(),
  ];

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