import 'package:flutter/material.dart';
import 'package:getwidget/components/toggle/gf_toggle.dart';
import 'package:quiver/async.dart';
import 'package:time_management/components/app_settings.dart';
import 'package:time_management/components/dialogs_components.dart';
import 'package:time_management/navigator.dart';
import 'package:time_management/translate/translator.dart';
import 'package:time_management/widgets/add_category.dart';
import 'package:time_management/widgets/task_data.dart';

import '../settings.dart';


class NewHomeWidget extends StatefulWidget {
  const NewHomeWidget({Key? key,}) : super(key: key);
  @override
  _NewHomeWidgetState createState() => _NewHomeWidgetState();
}

class _NewHomeWidgetState extends State<NewHomeWidget> {
  DateTime start = DateTime(0);
  CountdownTimer? countDownTimer;
  List<String> types = ["", "Obligatory tasks", "All tasks"];
  List<Task> tasks = databaseTasks;
  String typeString = "";
  int type = 1;
  bool obligatoryOnly = false;
  final String addCategory = translate(Tran.addCategory);
  final String settings = translate(Tran.settings);
  final String timeline = translate(Tran.timeline);
  final String startsIn = translate(Tran.startsIn) + " ";
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void handleClickOption(int option){
    switch(option){
      case 1:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const SettingsWidget()));
        break;
      case 0:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const AddCategoryWidget()));
        break;
    }
  }

  void startTimer() {
    if(obligatoryOnly){
      tasks = databaseTasks.where(filterListObligatory).toList();
    } else{
      tasks = databaseTasks.where(filterList).toList();
    }
    tasks.sort((a, b) => a.from.millisecondsSinceEpoch.compareTo(b.from.millisecondsSinceEpoch));
    if(tasks.isEmpty){
      return;
    }
    start = tasks.first.from;
    countDownTimer = CountdownTimer(
      -DateTime.now().difference(start),
      const Duration(seconds: 1),
    );
    var sub = countDownTimer!.listen(null);
    sub.onData((duration) {
      if(MainWidgetState.selectedIndex == 2) {
        setState(() {});
      }
    });

    sub.onDone(() {
      sub.cancel();
      if(MainWidgetState.selectedIndex == 2) {
        startTimer();
      }
    });
  }

  bool filterList(Task element){
    return element.from.isAfter(DateTime.now())
        && element.from.difference(DateTime.now()).inHours < 48;
  }

  bool filterListObligatory(Task element){
    return element.from.isAfter(DateTime.now())
        && element.from.difference(DateTime.now()).inHours < 48
        && element.obligatory;
  }

  void onObligatoryChanged(bool? newvalue){
    setState(() {
      obligatoryOnly = newvalue == true;
      if(obligatoryOnly){
        tasks = databaseTasks.where(filterListObligatory).toList();
      } else{
        tasks = databaseTasks.where(filterList).toList();
      }
      tasks.sort((a, b) => a.from.millisecondsSinceEpoch.compareTo(b.from.millisecondsSinceEpoch));
    });
  }


  @override
  void dispose() {
    super.dispose();
    if(countDownTimer != null){
      countDownTimer!.cancel();
    }
  }

  @override
  void reassemble() {
    onObligatoryChanged(false);
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(timeline),
        backgroundColor: mainAppColor,
        actions: <Widget>[
          Center(child:
            GFToggle(enabledTrackColor: Colors.blue[800],onChanged: onObligatoryChanged, value: false),
         ),
          PopupMenuButton<int>(
            onSelected: (e) => handleClickOption(e),
            itemBuilder: (BuildContext context) {
              int i = 0;
              return {addCategory, settings}.map((String choice) {
                return PopupMenuItem<int>(
                  value: i++,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(children: [
        Flexible(child:
        ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onLongPress: () => longPressed(tasks[index]),
                child: Card(
                    elevation: 5,
                    margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      children: [
                        Container(
                          color: getColorByType(tasks[index].type),
                          height: 10,
                        ),
                        Padding(padding: const EdgeInsets.all(12),child:Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tasks[index].name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20), textAlign: TextAlign.end,),
                                    SizedBox(width: MediaQuery.of(context).size.width*0.6,child: Text(tasks[index].description, style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 18), overflow: TextOverflow.visible, maxLines: 2,),),
                                    Text(startsIn + (-DateTime.now().difference(tasks[index].from)).toString().substring(0, 8), style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 22)),
                                  ],
                                )
                              ],
                            ),
                            Icon(getIconDataByType(tasks[index].type), color: getColorByType(tasks[index].type), size: 80,),
                          ],
                        ),)
                      ],
                    )
                ),
              );
            }
        ),),
      ],
      ),
    );
  }

  void longPressed(Task task) {
    showOptionsDialog(
      context,
      title: task.name,
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
}

