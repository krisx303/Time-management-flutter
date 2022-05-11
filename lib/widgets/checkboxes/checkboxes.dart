import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/checkbox/gf_checkbox.dart';
import 'package:getwidget/components/progress_bar/gf_progress_bar.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:getwidget/types/gf_progress_type.dart';
import 'package:time_management/components/app_settings.dart';
import 'package:time_management/components/dialogs_components.dart';
import 'package:time_management/components/dismissible_components.dart';
import 'package:time_management/components/floating_buttons.dart';
import 'package:time_management/components/main_components.dart';
import 'package:time_management/translate/translator.dart';
import 'package:time_management/widgets/calendar/calendar_components.dart';
import 'package:time_management/widgets/checkboxes/add_checkbox_category.dart';
import 'package:time_management/widgets/checkboxes/add_checkbox_factory.dart';
import 'package:time_management/widgets/checkboxes/checkbox_components.dart';
import 'package:time_management/widgets/checkboxes/checkbox_data.dart';
import 'package:time_management/widgets/task_data.dart';


class CheckboxesWidget extends StatefulWidget {
  const CheckboxesWidget({Key? key,}) : super(key: key);
  @override
  _CheckboxesWidgetState createState() => _CheckboxesWidgetState();
}

class _CheckboxesWidgetState extends State<CheckboxesWidget> {
  List<CheckboxData> checkboxes = databaseCheckboxes;
  /// tree list stores all previous choices
  List<CheckboxDataAbstract> tree = [];
  Color parentColor = Colors.blue;
  int treeIndex = -1;
  List<CheckboxDataChild> children = [];
  bool isFirstView = true;

  /// Init state method, sorts categories by indexes
  @override
  void initState() {
    super.initState();
    checkboxes.sort((a, b) => a.index > b.index ? 1 : 0,);
  }

  /// Main build method, builds view depends on variable isFirstView
  @override
  Widget build(BuildContext context) {
    if(isFirstView) {
      return WillPopScope(child: buildCategoryView(context), onWillPop: onWillPopFirstView);
    } else{
      return WillPopScope(child: buildChildView(context), onWillPop: onWillPopNextView);
    }
  }

  /// Build First View with categories of checkboxes
  Widget buildCategoryView(BuildContext context){
    return FirstViewScaffold(
      floatingButtons: [
        SaveOnFirestoreFloatingButton(saveOnFirestore),
        AddChildFloatingButton(addNewCategory),
      ],
      body: Padding(padding: const EdgeInsets.fromLTRB(0, 0, 0, 70), child: ReorderableListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: checkboxes.length,
        itemBuilder: categoryViewBuilder,
        onReorder: onReorderCategoryView,
      ),
      ));
  }

  /// Builder for category cards
  Widget categoryViewBuilder(BuildContext context, int index){
    List<int> stats = getTaskSize(checkboxes[index].subtasks);
    String statsStr = "${stats[0]}/${stats[1]}";
    Color color = Colors.red;
    double percentage = 0;
    if(stats[1] != 0){
      percentage = (stats[0].toDouble())/(stats[1].toDouble());
      color = getColorByPercent(percentage);
    }
    return GestureDetector(
      key: Key('${checkboxes[index].index}'),
      onTap: () => onCategoryItemClick(index),
      child: Dismissible(
          background: slideRightDeleteBackground(),
          secondaryBackground: Container(),
          confirmDismiss: (d) => onCategorySwiped(d, index),
          key: Key('${checkboxes[index].index}'),
          child: CardElement(
              hasTopColorBar: true,
              colorTopBar: getColorByType(checkboxes[index].type),
              content: [
                CardMainContent(
                    content: [
                      Text(checkboxes[index].name, style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 18)),
                      Text(statsStr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20), textAlign: TextAlign.end,),
                    ]
                ),
                Row(children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width/4,
                      child: Column(
                        children: [
                          GFProgressBar(
                            lineHeight: 10,
                            percentage: percentage,
                            backgroundColor : Colors.black26,
                            progressBarColor: color,
                          ),
                          Text("${(100*percentage).toStringAsFixed(2)}%")
                        ],
                      )
                  ),
                  Icon(getIconDataByType(checkboxes[index].type), color: getColorByType(checkboxes[index].type), size: 60,),
                  TriangleRight(color: getColorByType(checkboxes[index].type)),
                ],)
              ]
          ))
    );
  }

  /// This method builds every child view
  Widget buildChildView(BuildContext context){
    List<int> stats = getTaskSize(tree[treeIndex].subtasks);
    String position = "";
    for(int i = 0; i<=treeIndex; i++){
      position += "${tree[i].name} -> ";
    }
    position += "HERE :)";
    Color color = Colors.red;
    double percentage = 0;
    if(stats[1] != 0){
      percentage = (stats[0].toDouble())/(stats[1].toDouble());
      color = getColorByPercent(percentage);
    }else{
      color = Colors.blue;
      percentage = 1;
    }
    return ChildViewScaffold(
      appBarTitle: "Category - " + tree[0].name,
      appBarColor: parentColor,
      floatingButtons: [
        AddChildFactoryFloatingButton(addNewCheckboxFactory),
        AddChildFloatingButton(showDialogAddNewCheckbox),
      ],
      body: Column(children: [
        Card(margin: const EdgeInsets.fromLTRB(12, 12, 12, 1),child: Padding(padding: const EdgeInsets.all(12),
          child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [
            Text(position, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),),
          SizedBox(height: 120, child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [
            GFProgressBar(
                percentage: percentage,
                width:100,
                radius: 90,
                type: GFProgressType.circular,
                backgroundColor : Colors.black26,
                progressBarColor: color
            ),
            Text("${(100*percentage).toStringAsFixed(2)}%"),
          ],),),
          Text("Wykonano ${stats[0]} na ${stats[1]} zadań."),
        ],),)),
        Flexible(child: ReorderableListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: children.length,
          itemBuilder: childViewBuilder,
          onReorder: onReorderChildView,
        )),
        const Padding(padding: EdgeInsets.fromLTRB(0, 70, 0, 0),)
      ],)
    );
  }

  /// Method choose builder for child card depends on card element has subtasks
  Widget childViewBuilder(BuildContext context, int index){
    if(children[index].subtasks.isEmpty){
      return buildCheckboxCard(context, index);
    }else{
      return buildSubCategoryCard(context, index);
    }
  }

  /// Method which returns color by percent complete task
  Color getColorByPercent(double percent){
    if(percent < 0.3){
      return Colors.redAccent.shade700;
    }else if(percent < 0.5){
      return Colors.deepOrange;
    }else if(percent < 0.75){
      return Colors.orange;
    }else if(percent < 1){
      return Colors.yellow;
    }
    return Colors.green;
  }

  /// Builds SubCategory card
  Widget buildSubCategoryCard(BuildContext context, int index){
    List<int> stats = getTaskSize(children[index].subtasks);
    String statsStr = "Tasks ${stats[0]}/${stats[1]}";
    Color color = Colors.red;
    double percentage = 0;
    String name = children[index].name;
    name = name.length < 20 ? name : name.substring(0, 19) + "...";
    if(stats[1] != 0){
      percentage = (stats[0].toDouble())/(stats[1].toDouble());
      color = getColorByPercent(percentage);
    }
    return GestureDetector(
      key: Key('${children[index].index}'),
      onTap: () => onCheckboxItemClick(index),
      child: CardElement(
          content:[
            CardMainContent(
                content:[
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 18)),
                  Text(statsStr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20), textAlign: TextAlign.end,),
                ]
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center,children: [
              SizedBox(
                width: MediaQuery.of(context).size.width/4,
                child: Column(
                  children: [
                    GFProgressBar(
                      lineHeight: 10,
                      percentage: percentage,
                      backgroundColor : Colors.black26,
                      progressBarColor: color,
                    ),
                    Text("${(100*percentage).toStringAsFixed(2)}%")
                  ],
                )
              ),
              TriangleRight(color: Colors.black),
            ],)
          ]
      ),
    );
  }

  /// Builds Checkbox card
  Widget buildCheckboxCard(BuildContext context, int index){
    bool isCheckable = children[index].subtasks.isEmpty;
    return GestureDetector(
      key: Key('${children[index].index}'),
      onTap: () => {if(isCheckable){}else{onCheckboxItemClick(index)}},
      onDoubleTap: () => {if(isCheckable){onCheckboxItemClick(index)}else{}},
      child: CardElement(
        marginHorizontal: 12,
        marginVertical: 6,
        content: [
          CardMainContent(
              content:[
                Text(children[index].name, style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 18)),
              ]
          ),
          Row(children: [
            GFCheckbox(value: children[index].checked, size: GFSize.MEDIUM,
              activeBgColor: parentColor,
              onChanged: (value) {
                setState(() {
                  children[index].checked = value == true;
                });
              },),
            const Padding(padding: EdgeInsets.fromLTRB(30, 0, 10, 0)),
            TriangleRight(color: Colors.black, height: 60, width: 30,),
          ],),
        ],
      ),
    );
  }

  /// Method shows dialog to ask if user want to delete category
  Future<bool?> onCategorySwiped(DismissDirection direction, int index) async {
    if (direction == DismissDirection.startToEnd) {
      final bool? res = await showDefaultDialog(context,
          button: DialogButton.delete(onPressed: () => onWantDeleteCategory(index)),
          title: translate(Tran.delCategoryTitle),
          content: translateArgs(Tran.delCategoryContent, [checkboxes[index].name])
      );
      return res == true;
    }
    return false;
  }

  /// Action when user want delete category
  void onWantDeleteCategory(int index) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('users-data').doc(mainAppName).collection('checkboxes');
    ref.doc(checkboxes[index].id).delete();
    checkboxes.removeAt(index);
    for(int i = 0; i<checkboxes.length; i++){
      checkboxes[i].index = i;
    }
    saveOnFirestore();
  }

  /// Methods responsible for reorder elements in lists
  void onReorderCategoryView(int oldIndex, int newIndex){
    if(oldIndex == newIndex){
      return;
    }
    else if(newIndex > oldIndex){
      setState(() {
        checkboxes[oldIndex].index = newIndex-1;
        for(int i = oldIndex+1; i<newIndex;i++){
          checkboxes[i].index -= 1;
        }
      });
    }else{
      checkboxes[oldIndex].index = newIndex;
      for(int i = newIndex; i<oldIndex;i++){
        checkboxes[i].index += 1;
      }
    }
    checkboxes.sort((a, b) => a.index > b.index ? 1 : 0,);
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
    children.sort((a, b) => a.index > b.index ? 1 : 0,);
  }

  /// Adds actual choice to tree
  void addTreeElement(CheckboxDataAbstract child){
    tree.add(child);
    treeIndex += 1;
  }


  void updateChildren(){
    children = tree[treeIndex].subtasks;
    children.sort((a, b) => a.index > b.index ? 1 : 0,);
  }

  /// methods run when Card was clicked
  void onCategoryItemClick(int index){
    setState(() {
      addTreeElement(checkboxes[index]);
      updateChildren();
      parentColor = getColorByType(checkboxes[index].type);
      isFirstView = false;
    });
  }


  void onCheckboxItemClick(int index){
    setState(() {
      addTreeElement(children[index]);
      updateChildren();
      isFirstView = false;
    });
  }

  /// Opens new widget to add new category
  void addNewCategory(){
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const AddCheckboxCategoryWidget())).then((value) => {
          setState((){
            checkboxes = databaseCheckboxes;
            checkboxes.sort((a, b) => a.index > b.index ? 1 : 0,);
          })
        });
  }

  void addNewCheckbox(TextEditingController tec){
    setState(() {
      tree[treeIndex].subtasks.add(CheckboxDataChild(tec.text, false, [], tree[treeIndex].subtasks.length));
    });
    Navigator.pop(context);
  }

  /// Opens dialog to enter name for new Checkbox
  void showDialogAddNewCheckbox() async {
    TextEditingController tec = TextEditingController();
    showDialogWithTextField(
        context,
        tec: tec,
        title: translate(Tran.addSubcategory),
        hint: translate(Tran.enterSubcategory),
        button: DialogButton.add(onPressed: () => addNewCheckbox(tec))
    );
  }

  /// Opens new widget to create Checkbox factory
  void addNewCheckboxFactory() async {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const AddCheckboxFactoryWidget())).then((value) => {
      setState((){
        if(cacheCheckboxesDataChild != null){
          int l = tree[treeIndex].subtasks.length;
          for(int i = 0;i<cacheCheckboxesDataChild!.length; i++){
            cacheCheckboxesDataChild![i].index += l;
            tree[treeIndex].subtasks.add(cacheCheckboxesDataChild![i]);
          }
          //saveSingleOnFirestore(tree[0].index);
        }
      })
    });
  }

  /// Saves single Checkbox Category on Firestore
  void saveSingleOnFirestore(int index) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('users-data').doc(mainAppName).collection('checkboxes');
    ref.doc(checkboxes[index].id).update(checkboxes[index].toJson());
    showToast("Data updated successfully :)");
    setState(() {});
  }

  /// Saves data on Firestore
  void saveOnFirestore() async {
    CollectionReference ref = FirebaseFirestore.instance.collection('users-data').doc(mainAppName).collection('checkboxes');
    for (var element in checkboxes) {
      ref.doc(element.id).update(element.toJson());
    }
    showToast("Data updated successfully :)");
    setState(() {});
  }

  /// Method when back button was pressed in category view
  Future<bool> onWillPopFirstView() async {
    return (await showDialogExitApp(context)) ?? false;
  }

  /// Method when back button was pressed in checkbox view
  Future<bool> onWillPopNextView() async {
    setState(() {
      if(treeIndex == 0){
        children = [];
        isFirstView = true;
      }else{
        children = tree[treeIndex-1].subtasks;
        isFirstView = false;
      }
      tree.removeLast();
      treeIndex--;
    });
    return false;
  }
}