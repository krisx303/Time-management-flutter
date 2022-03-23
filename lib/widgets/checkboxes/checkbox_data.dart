import 'dart:convert';

class CheckboxData {
  CheckboxData(this.id, this.name, this.type, this.subtasks);
  String id;
  String name;
  String type;
  Map<String, CheckboxDataChild> subtasks;

  factory CheckboxData.fromJson(String id, dynamic json) {
    Map<String, CheckboxDataChild> subtasks = getTasks(json['subtasks']);
    return CheckboxData(id, json['name'] as String, json['type'] as String, subtasks);
  }

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'type': type,
      'subtasks': subtasks,
    };
  }
}

class CheckboxDataChild {
  CheckboxDataChild(this.checked, this.subtasks);
  bool checked;
  Map<String, CheckboxDataChild> subtasks;
}

Map<String, CheckboxDataChild> getTasks(Map<String, dynamic> data){
  Map<String, CheckboxDataChild> tasks = {};
  data.forEach((key, value) {
    tasks.putIfAbsent(key, () => CheckboxDataChild(false, getSubtasks(value['subtasks'])));
  });
  return tasks;
}

Map<String, CheckboxDataChild> getSubtasks(Map<String, dynamic> data) {
  Map<String, CheckboxDataChild> subtasks = {};
  data.forEach((key, value) {
    subtasks.putIfAbsent(key, () => CheckboxDataChild(false, getSubtasks(value['subtasks'])));
  });
  return subtasks;
}

List<CheckboxData> databaseCheckboxes = [];