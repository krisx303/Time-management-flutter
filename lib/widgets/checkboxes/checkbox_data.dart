class CheckboxDataAbstract{
  CheckboxDataAbstract(this.name, this.subtasks, this.index);
  String name;
  int index;
  List<CheckboxDataChild> subtasks;
}

class CheckboxData extends CheckboxDataAbstract {
  CheckboxData(this.id, String name, this.type, List<CheckboxDataChild> subtasks, int index) : super(name, subtasks, index);
  String id;
  String type;

  factory CheckboxData.fromJson(String id, dynamic json) {
    List<CheckboxDataChild> subtasks = getTasks(json['subtasks']);
    return CheckboxData(id, json['name'] as String, json['type'] as String, subtasks, json['index']);
  }

  Map<String, Object?> toJson() {
    Map<String, Object?> asd = {};
    for(CheckboxDataChild element in subtasks){
      asd.putIfAbsent(element.name, () => element.toJson());
    }
    return {
      'name': name,
      'type': type,
      'subtasks': asd,
      'index': index
    };
  }
}

class CheckboxDataChild extends CheckboxDataAbstract{
  CheckboxDataChild(String name, this.checked, List<CheckboxDataChild> subtasks, int index) : super(name, subtasks, index);
  bool checked;

  Map<String, Object?> toJson() {
    Map<String, Object?> asd = {};
    for(var element in subtasks) {
      asd.putIfAbsent(element.name, () => element.toJson());
    }
    return {
      'checked': checked,
      'subtasks': asd,
      'index': index,
    };
  }

  @override
  String toString() {
    return '{checked: $checked, subtasks: $subtasks}';
  }
}

List<CheckboxDataChild> getTasks(Map<String, dynamic> data){
  List<CheckboxDataChild> tasks = [];
  data.forEach((key, value) {
    tasks.add(CheckboxDataChild(key, value['checked'], getSubtasks(value['subtasks']), value['index']));
  });
  return tasks;
}

List<CheckboxDataChild> getSubtasks(Map<String, dynamic> data) {
  List<CheckboxDataChild> subtasks = [];
  data.forEach((key, value) {
    subtasks.add(CheckboxDataChild(key, value['checked'], getSubtasks(value['subtasks']), value['index']));
  });
  return subtasks;
}

List<CheckboxData> databaseCheckboxes = [];
List<CheckboxDataChild>? cacheCheckboxesDataChild;

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