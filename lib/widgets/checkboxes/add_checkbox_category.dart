import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:time_management/components/app_settings.dart';
import 'package:time_management/components/main_components.dart';
import '../../loading_widget.dart';
import '../calendar/calendar_components.dart';
import '../categories_data.dart';

class AddCheckboxCategoryWidget extends StatefulWidget {
  const AddCheckboxCategoryWidget({Key? key}) : super(key: key);

  @override
  State<AddCheckboxCategoryWidget> createState() => _AddCheckboxCategoryWidgetState();
}

class _AddCheckboxCategoryWidgetState extends State<AddCheckboxCategoryWidget> {
  late Category _categoryChoose;
  String name = "";

  @override
  void initState() {
    super.initState();
    _categoryChoose = databaseCategories[0];
  }

  void _onDropDownItemSelected(Category? newCategory) {
    setState(() {
      _categoryChoose = newCategory!;
    });
  }
  void onNameChanged(String newValue){
    setState(() {
      name = newValue;
    });
  }

  void tryConfirm(){
    if(name == ""){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title:const Text("Warning!"),
              content:const Text("Your Task must have a name."),
              actions: <Widget>[
                FlatButton(onPressed: (){
                  Navigator.of(context).pop();
                }, child: const Text('OK'))
              ],
            );
          });
    }else{
      sendToFirestore();
    }
  }

  void sendToFirestore(){
    CollectionReference ref = FirebaseFirestore.instance.collection('users-data').doc("krisuu").collection("checkboxes");
    ref.add({
      'name': name,
      'type': _categoryChoose.name,
      'subtasks': {},
    }).then((value) => getUserTaskList(onSentAndUpdated))
        .catchError((error) => showToast(error));
  }

  void onSentAndUpdated(){
    setState(() {});
    showToast("Category sent successfully :)");
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mainAppColor,
          title: const Text("Add new Checkbox Category"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(child: Column(
          children: <Widget>[
            const Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0)),
            enterTaskNameWidget(onNameChanged),
            categoryPicker(_categoryChoose, _onDropDownItemSelected),
            ConfirmButton(tryConfirm: tryConfirm),
          ],
        ),)
    );
  }
}