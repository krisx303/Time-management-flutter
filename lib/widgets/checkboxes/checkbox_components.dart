import 'package:flutter/material.dart';
import 'package:time_management/components/app_settings.dart';
import '../../components/floating_buttons.dart';

/// Scaffold Section

class ChildViewScaffold extends Scaffold{
  ChildViewScaffold({
    required String appBarTitle,
    required Color appBarColor,
    required List<FloatingActionButton> floatingButtons,
    required Widget body,
    Key? key
  }) : super(
    appBar: AppBar(
      title: Text(appBarTitle),
      backgroundColor: appBarColor,
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    floatingActionButton: BottomFloatingButtons(buttons: floatingButtons),
    body: Column(
      children: [
        Flexible(child: body),
      ],
    ),
    key: key,
  );
}

class FirstViewScaffold extends Scaffold{
  FirstViewScaffold({
    required List<FloatingActionButton> floatingButtons,
    required Widget body,
    Key? key
  }) :super(
    appBar: AppBar(
      title: const Text("Checkboxes"),
      backgroundColor: mainAppColor,
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    floatingActionButton: BottomFloatingButtons(buttons: floatingButtons),
    body: Column(
      children: [
        Flexible(child: body),
      ],
    ),
    key: key,
  );
}