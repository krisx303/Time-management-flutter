import 'dart:convert';

class CheckboxData {
  CheckboxData(this.id, this.name, this.type, this.subtasks, this.index);
  String id;
  String name;
  String type;
  int index;
  Map<String, CheckboxDataChild> subtasks;

  factory CheckboxData.fromJson(String id, dynamic json) {
    Map<String, CheckboxDataChild> subtasks = getTasks(json['subtasks']);
    return CheckboxData(id, json['name'] as String, json['type'] as String, subtasks, json['index']);
  }

  Map<String, Object?> toJson() {
    Map<String, Object?> asd = {};
    subtasks.forEach((key, value) {
      asd.putIfAbsent(key, () => value.toJson());
    });
    return {
      'name': name,
      'type': type,
      'subtasks': asd,
      'index': index
    };
  }
}

class CheckboxDataChild {
  CheckboxDataChild(this.checked, this.subtasks, this.index);
  bool checked;
  int index;
  Map<String, CheckboxDataChild> subtasks;

  Map<String, Object?> toJson() {
    Map<String, Object?> asd = {};
    subtasks.forEach((key, value) {
      asd.putIfAbsent(key, () => value.toJson());
    });
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

Map<String, CheckboxDataChild> getTasks(Map<String, dynamic> data){
  Map<String, CheckboxDataChild> tasks = {};
  data.forEach((key, value) {
    tasks.putIfAbsent(key, () => CheckboxDataChild(false, getSubtasks(value['subtasks']), value['index']));
  });
  return tasks;
}

Map<String, CheckboxDataChild> getSubtasks(Map<String, dynamic> data) {
  Map<String, CheckboxDataChild> subtasks = {};
  data.forEach((key, value) {
    subtasks.putIfAbsent(key, () => CheckboxDataChild(false, getSubtasks(value['subtasks']), value['index']));
  });
  return subtasks;
}

List<CheckboxData> databaseCheckboxes = [];