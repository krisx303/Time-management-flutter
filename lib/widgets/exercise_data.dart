import 'package:cloud_firestore/cloud_firestore.dart';
class Exercise {
  Exercise(this.id, this.name, this.description, this.type, this.deadline, this.priority);
  String id;
  String name;
  String description;
  String type;
  DateTime deadline;
  int priority;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'deadline': Timestamp.fromDate(deadline),
      'priority': priority,
    };
  }
}


List<Exercise> databaseExercises = [];