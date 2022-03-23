import 'dart:convert';
main() {
  String arrayText = '[{"name":"Unit 1", "subtasks": []}, {"name": "Unit 2", "subtasks":[]}]';
  var tagsJson = jsonDecode(arrayText)[0]['subtasks'];
  List<String>? tags = tagsJson != null ? List.from(tagsJson) : null;
  print(tags);
}