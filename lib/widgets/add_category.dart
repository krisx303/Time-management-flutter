import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:time_management/components/app_settings.dart';
import 'package:time_management/components/main_components.dart';
import 'package:time_management/loading_widget.dart';
import 'package:time_management/widgets/calendar/calendar_components.dart';


class AddCategoryWidget extends StatefulWidget {
  const AddCategoryWidget({Key? key}) : super(key: key);

  @override
  State<AddCategoryWidget> createState() => _AddCategoryWidgetState();
}

class _AddCategoryWidgetState extends State<AddCategoryWidget> {
  Color color = Colors.blue;
  IconData iconData = Icons.home;
  String name = "";

  void onChangeColor(Color newColor){
    setState(() {
      color = newColor;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  void onNameChanged(String newValue){
    setState(() {
      name = newValue;
    });
  }

  void tryConfirm(){
    if(name == ""){
      showDialogWarningNoNameCategory(context);
    }else if(iconData.codePoint == Icons.home.codePoint){
      showDialogWarningIconChange(context, send);
    }
    else{
      send();
    }
  }

  void send(){
    CollectionReference ref = FirebaseFirestore.instance.collection('users-data').doc("krisuu").collection("categories");
    ref.add({
      'name': name,
      'color': color.value,
      'icon': iconData.codePoint,
    }).then((value) => getUserCategories(onSentAndUpdated))
        .catchError((error) => print("Failed to add category: $error"));
  }

  void onSentAndUpdated(){
    setState(() {});
    Navigator.of(context).pop();
  }

  SizedBox enterCategoryNameWidget(Function(String newValue) onChanged){
    return SizedBox(width: MediaQuery.of(context).size.width*0.7,child: TextField(
      onChanged: onChanged,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Category Name',
        hintText: 'Enter Category Name',
      ),
    ));
  }


  void openIconPicker() async {
    IconData icon = await FlutterIconPicker.showIconPicker(context, iconColor: color) ?? Icons.home;
    setState(() {
      iconData = icon;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mainAppColor,
          title: const Text("Add new Category"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(child: Center(
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
              Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children: [
                enterCategoryNameWidget(onNameChanged),
                GestureDetector(onTap: openIconPicker, child: Icon(iconData, size: 60, color: color,),)
              ],),
              const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
              ColorPicker(
                paletteType: PaletteType.hslWithHue,
                enableAlpha: false,
                labelTypes: const [],
                pickerColor: color,
                onColorChanged: onChangeColor,
              ),
              ConfirmButton(tryConfirm: tryConfirm),
            ],
          ),
        )
    ));
  }
}