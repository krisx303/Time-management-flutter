import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/checkbox/gf_checkbox.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:time_management/components/app_settings.dart';
import 'package:time_management/widgets/calendar/calendar_components.dart';
import 'package:time_management/widgets/checkboxes/checkbox_data.dart';
import 'package:time_management/widgets/exercise/triangle.dart';
import 'package:time_management/widgets/task_data.dart';


class CheckboxesWidget extends StatefulWidget {
  const CheckboxesWidget({Key? key,}) : super(key: key);
  @override
  _CheckboxesWidgetState createState() => _CheckboxesWidgetState();
}

class _CheckboxesWidgetState extends State<CheckboxesWidget> {
  List<CheckboxData> checkboxes = databaseCheckboxes;
  CheckboxData parent = databaseCheckboxes[0];
  List<CheckboxDataChild> parentTree = [];
  int parentTreeIndex = -1;
  List<CheckboxDataChild> children = [];
  bool isFirstView = true;

  void onReorderFirstView(int oldIndex, int newIndex){
    if(oldIndex == newIndex){
      return;
    }
    else if(newIndex > oldIndex){
      setState(() {
        checkboxes[oldIndex].index = newIndex-1;
        for(int i = oldIndex+1; i<newIndex;i++){
          checkboxes[i].index -= 1;
        }
        checkboxes.sort((a, b) => a.index > b.index ? 1 : 0,);
      });
    }else{
      checkboxes[oldIndex].index = newIndex;
      for(int i = newIndex; i<oldIndex;i++){
        checkboxes[i].index += 1;
      }
      checkboxes.sort((a, b) => a.index > b.index ? 1 : 0,);
    }
  }


  void onReorderChildView(int oldIndex, int newIndex){
    if(oldIndex == newIndex){
      return;
    }
    else if(newIndex > oldIndex){
      setState(() {
        children[oldIndex].index = newIndex-1;
        for(int i = oldIndex+1; i<newIndex;i++){
          children[i].index -= 1;
        }
      });
    }else{
      children[oldIndex].index = newIndex;
      for(int i = newIndex; i<oldIndex;i++){
        children[i].index += 1;
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void reassemble() {
    super.reassemble();
  }

  void onFirstItemClick(int index){
    setState(() {
      parent = checkboxes[index];
      children = [];
      children = parent.subtasks;
      isFirstView = false;
    });
  }

  void onNextItemClick(int index){
    setState(() {
      parentTree.add(children[index]);
      parentTreeIndex++;
      children = parentTree[parentTreeIndex].subtasks;
      isFirstView = false;
    });
  }

  // void onWantDeleteObject(int index) async {
  //   await showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //     title: const Text('Are you sure?'),
  //     content: const Text('Do you want to delete this object and all children??'),
  //     actions: <Widget>[
  //       TextButton(
  //         onPressed: () => {Navigator.of(context).pop()},
  //         child: const Text('Noooo'),
  //       ),
  //       TextButton(
  //         onPressed: () {
  //           setState(() {
  //             if(parentTreeIndex == -1){
  //               parent.subtasks.removeWhere((key, value) => value == children[index]);
  //               children = [];
  //               parent.subtasks.forEach((key, value) {
  //                 names.add(key);
  //                 children.add(value);
  //               });
  //             }else{
  //               parentTree[parentTreeIndex].subtasks.removeWhere((key, value) => value == children[index]);
  //               names = [];
  //               children = [];
  //               parentTree[parentTreeIndex].subtasks.forEach((key, value) {
  //                 names.add(key);
  //                 children.add(value);
  //               });
  //             }
  //           });
  //           Navigator.of(context).pop();
  //         },
  //         child: const Text('Yes'),
  //       ),
  //     ],
  //   ),
  //   );
  // }

  void addNewCategory(){

  }

  void addNewChild() async {
    TextEditingController _textFieldController = TextEditingController();
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Adding new category.'),
            content: TextField(
              controller: _textFieldController,
              textInputAction: TextInputAction.go,
              decoration: const InputDecoration(hintText: "Enter name for category:"),
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text('Add'),
                onPressed: () {
                  setState(() {
                    if(parentTreeIndex == -1){
                      parent.subtasks.add(CheckboxDataChild(_textFieldController.text, false, [], parent.subtasks.length));
                      children = parent.subtasks;
                    }else{
                      parentTree[parentTreeIndex].subtasks.add(CheckboxDataChild(_textFieldController.text, false, [], parentTree[parentTreeIndex].subtasks.length));
                      children = parentTree[parentTreeIndex].subtasks;
                    }
                  });
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void addNewChildFactory() async {

  }

  void saveOnFirestore() async {
    CollectionReference ref = FirebaseFirestore.instance.collection('users-data').doc('krisuu').collection('checkboxes');
    for (var element in checkboxes) {
      ref.doc(element.id).update(element.toJson());
    }
    showToast("Data updated successfully :)");
  }

  Widget buildFirstView(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkboxes"),
        backgroundColor: mainAppColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(padding: const EdgeInsets.fromLTRB(35, 0, 5, 15), child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton(
            onPressed: saveOnFirestore,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.save),
          ),
          FloatingActionButton(
            onPressed: addNewCategory,
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),],
      )),
      body: Column(children: [
        Flexible(child:
        ReorderableListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: checkboxes.length,
            itemBuilder: (BuildContext context, int index) {
              List<int> stats = getTaskSize(checkboxes[index].subtasks);
              String statsStr = "Tasks ${stats[0]}/${stats[1]}";
              return GestureDetector(
                key: Key('${checkboxes[index].index}'),
                onTap: () => onFirstItemClick(index),
                child: Card(
                    elevation: 5,
                    margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      children: [
                        Container(
                          color: getColorByType(checkboxes[index].type),
                          height: 10,
                        ),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(padding: const EdgeInsets.all(12),child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(checkboxes[index].name, style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 18)),
                                    Text(statsStr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20), textAlign: TextAlign.end,),
                                  ],
                                )
                              ],
                            ),),
                            Row(children: [
                              Icon(getIconDataByType(checkboxes[index].type), color: getColorByType(checkboxes[index].type), size: 60,),
                              CustomPaint(
                                painter: TrianglePainter(
                                  strokeColor: getColorByType(checkboxes[index].type),
                                  strokeWidth: 10,
                                  paintingStyle: PaintingStyle.fill,
                                ),child: Container(
                                height: 100,
                                width: 50,
                              ),),
                            ],),
                          ],)
                      ],
                    )
                ),
              );
            }, onReorder: onReorderFirstView,
        ),
        ),
      ],
      ),
    );
  }

  _showPopupMenu(Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        const PopupMenuItem(
          value: 1,
          child: Text(
            "Sort by deadline",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ),
      ],
      elevation: 8.0,
    );
  }

  Widget buildTappableCard(BuildContext context, int index){
    List<int> stats = getTaskSize(children[index].subtasks);
    String statsStr = "Tasks ${stats[0]}/${stats[1]}";
    return GestureDetector(
      key: Key('${children[index].index}'),
      onTap: () => onNextItemClick(index),
      child: Card(
          elevation: 5,
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(padding: const EdgeInsets.all(12),child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(children[index].name, style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 18)),
                          Text(statsStr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20), textAlign: TextAlign.end,),
                        ],
                      )
                    ],
                  ),),
                  Row(children: [
                    CustomPaint(
                      painter: TrianglePainter(
                        //strokeColor: getColorByType(checkboxes[index].type),
                        strokeWidth: 10,
                        paintingStyle: PaintingStyle.fill,
                      ),child: Container(
                      height: 100,
                      width: 50,
                    ),),
                  ],),
                ],)
            ],
          )
      ),
    );
  }

  Widget buildCheckboxCard(BuildContext context, int index){
    bool isCheckable = children[index].subtasks.isEmpty;
    return GestureDetector(
        key: Key('${children[index].index}'),
        onTap: () => {if(isCheckable){}else{onNextItemClick(index)}},
        onDoubleTap: () => {if(isCheckable){onNextItemClick(index)}else{}},
    child: Card(
          elevation: 5,
          margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(padding: const EdgeInsets.all(12),child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(children[index].name, style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 18)),
                    ],
                  ),),
                  Row(children: [
                    GFCheckbox(value: children[index].checked, size: GFSize.MEDIUM,
                      activeBgColor: getColorByType(parent.type),
                      onChanged: (value) {
                        setState(() {
                          children[index].checked = value == true;
                        });
                      },),
                    const Padding(padding: EdgeInsets.fromLTRB(30, 0, 10, 0)),
                    CustomPaint(
                      painter: TrianglePainter(
                        //strokeColor: getColorByType(checkboxes[index].type),
                        strokeWidth: 10,
                        paintingStyle: PaintingStyle.fill,
                      ),child: Container(
                      height: 60,
                      width: 30,
                    ),),
                  ],),
                ],)
            ],
          )
      ));
  }

  Widget buildChildView(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Category - " + parent.name),
        backgroundColor: getColorByType(parent.type),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(padding: const EdgeInsets.fromLTRB(35, 0, 5, 15), child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton(
            onPressed: addNewChildFactory,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.all_inclusive),
          ),
          FloatingActionButton(
            onPressed: addNewChild,
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),],
      )),
      body: Column(children: [
        Flexible(child:
        ReorderableListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: children.length,
            itemBuilder: (BuildContext context, int index) {
              if(children[index].subtasks.isEmpty){
                return buildCheckboxCard(context, index);
              }else{
                return buildTappableCard(context, index);
              }
            }, onReorder: onReorderChildView,
        ),),
      ],
      ),
    );
  }

  Future<bool> onWillPopFirstView() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to exit an App'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }

  Future<bool> onWillPopNextView() async {
    print(parentTreeIndex);
    print(parentTree.length);
    if(parentTreeIndex == -1){
      setState(() {
        children = [];
        isFirstView = true;
      });
    }else if(parentTreeIndex == 0) {
      setState(() {
        children = parent.subtasks;
        parentTree.removeLast();
        parentTreeIndex--;
        isFirstView = false;
      });
    }else{
      setState(() {
        children = parentTree[parentTreeIndex].subtasks;
        parentTree.removeLast();
        parentTreeIndex--;
        isFirstView = false;
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if(isFirstView){
      return WillPopScope(child: buildFirstView(context), onWillPop: onWillPopFirstView);
    }
    else{
      return WillPopScope(child: buildChildView(context), onWillPop: onWillPopNextView);
    }
  }
}

List<int> getTaskSize(List<CheckboxDataChild> data){
  int count = 0, all = 0;
  for(CheckboxDataChild child in data){
    if(child.subtasks.isEmpty){
      all += 1;
      if(child.checked){
        count += 1;
      }
    }else{
      List<int> stats = getTaskSize(child.subtasks);
      count += stats[0];
      all += stats[1];
    }
  }
  return [count, all];
}