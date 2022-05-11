import 'package:flutter/material.dart';
import 'package:getwidget/components/toggle/gf_toggle.dart';
import 'package:time_management/components/app_settings.dart';
import 'package:time_management/components/dialogs_components.dart';
import 'package:time_management/components/main_components.dart';
import 'package:time_management/widgets/checkboxes/checkbox_data.dart';
import '../../translate/translator.dart';
import '../calendar/calendar_components.dart';

class AddCheckboxFactoryWidget extends StatefulWidget {
  const AddCheckboxFactoryWidget({Key? key}) : super(key: key);

  @override
  State<AddCheckboxFactoryWidget> createState() => _AddCheckboxFactoryWidgetState();
}

class _AddCheckboxFactoryWidgetState extends State<AddCheckboxFactoryWidget> {
  String name = "";
  int numberOfTasks = 1;
  TextEditingController tec = TextEditingController();
  TaskObject mainObject = TaskObject("todo", []);
  bool isAlphabetic = false;
  @override
  void initState() {
    super.initState();
    cacheCheckboxesDataChild = null;
  }

  void onNameChanged(String newValue){
    setState(() {
      name = newValue;
      mainObject.name = newValue + "{index}";
    });
  }

  void onChangeIsAlphabetic(bool? value){
    setState(() {
      isAlphabetic = value == true;
    });
  }

  /// NOT is Number Of Tasks
  void onNOTChanged(String newValue){
    if(newValue.isEmpty) {
      return;
    }
    setState(() {
      numberOfTasks = int.parse(newValue);
    });
  }

  void tryConfirm(){
    if(name == ""){
      showWarningDialog(context, content: translate(Tran.taskHasNoName),);
    }else{
      save();
    }
  }

  void save(){
    CheckboxDataChild main = convertTaskObject(mainObject, 0);
    cacheCheckboxesDataChild = [];
    String nn = "";
    for(int i = 0; i<numberOfTasks;i++){
      if(isAlphabetic){
        nn = "$name ${String.fromCharCode(i+97)})";
      }else{
        nn = "$name ${i+1}";
      }
      cacheCheckboxesDataChild!.add(CheckboxDataChild(nn, false, main.subtasks, i));
    }
    showToast("$numberOfTasks tasks saved successfully :)");
    Navigator.of(context).pop();
  }

  Widget renderTaskObject(TaskObject object, TaskObject? parent){
    return Card(child: Padding(padding: const EdgeInsets.fromLTRB(10, 5, 10, 5), child: Row(children: [
      Text(object.name),
      (object == mainObject ? const SizedBox.shrink() :       TextButton.icon(onPressed: () => deleteTask(parent, object),
        icon: const Icon(Icons.delete, color: Colors.red,), label: Container(),)),
      Column(children: renderTaskList(object) + [
        TextButton.icon(onPressed: () => showDialogAddNewTask(object),
          icon: const Icon(Icons.add, color: Colors.blue,), label: Container(),),
      ],),
    ],),),);
  }

  void deleteTask(TaskObject? parent, TaskObject object){
    parent!.subtasks.remove(object);
    setState(() {});
  }

  Future<void> showDialogAddNewTask(TaskObject object) async {
    await showDialogWithTextField(
      context,
      title: translate(Tran.addTask),
      hint: translate(Tran.enterTask),
      tec: tec,
      button: DialogButton.add(onPressed: () => addNewTask(object, tec)),
    );
  }

  void addNewTask(TaskObject object, TextEditingController tec){
    Navigator.pop(context);
    object.subtasks.add(TaskObject(tec.text, []));
    tec.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mainAppColor,
          title: const Text("Add new Checkbox Factory"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(child: Column(
          children: <Widget>[
            const Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0)),
            enterTaskNameWidget(onNameChanged),
            enterNOTWidget(onNOTChanged),
            const Text("Preview: "),
            renderTaskObject(mainObject, null),
            //Flexible(child:ListView.builder(itemCount: (numberOfTasks > 0 ? numberOfTasks : 0), itemBuilder: previewListViewBuilder),),
            Row(children: [
              const Text("Is alphabetic? "),
              GFToggle(onChanged: onChangeIsAlphabetic, value: isAlphabetic),
            ],),
            ConfirmButton(tryConfirm: tryConfirm),
          ],
        )
    ));
  }

  Widget previewListViewBuilder(BuildContext context, int index) {
    return Padding(padding: const EdgeInsets.fromLTRB(20, 5, 20, 5), child: Card(child: Center(child: Text("$name ${index+1}"),)),);
  }

  List<Widget> renderTaskList(TaskObject object) {
    List<Widget> asd = [];
    for(TaskObject task in object.subtasks){
      asd.add(renderTaskObject(task, object));
    }
    return asd;
  }

  CheckboxDataChild convertTaskObject(TaskObject object, int index) {
    CheckboxDataChild child = CheckboxDataChild(object.name, false, [], index);
    for(int i = 0; i<object.subtasks.length; i++){
      child.subtasks.add(convertTaskObject(object.subtasks[i], i));
    }
    return child;
  }
}

class TaskObject{
  TaskObject(this.name, this.subtasks);
  String name;
  List<TaskObject> subtasks;
}