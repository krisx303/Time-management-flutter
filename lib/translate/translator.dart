import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

/// IDs of every string in language files (number of line in file)
enum Tran{
  confirm,
  cancel,
  delete,
  delCategoryTitle,
  delCategoryContent,
  areYouSure,
  exitApp,
  yesAnswer,
  noAnswer,
  add,
  addSubcategory,
  enterSubcategory,
  addTask,
  enterTask,
  delExerciseTitle,
  delExerciseContent,
  markExerciseDone,
  lists,
  tasks,
  timeline,
  calendar,
  warning,
  okAnswer,
  taskHasNoName,
  done,
  categoryHasNoName,
  didYouKnowIcon,
  sameDateTimes,
  timeEndBeforeStart,
  close,
  edit,
  cellDescription,
  addCategory,
  settings,
  selectDateOnCalendar,
  taskHasNoNamePriority,
}

enum Language{
  english,
  polish
}

/// Database which stores loaded translation
List<String> dictionary = [];

/// Loads language file from assets
Future<String> loadAsset(int id) async {
  return await rootBundle.loadString('assets/languages/lang_$id.csv');
}

/// Main function to load language to dictionary
Future<void> loadLanguage(Language language) async {
  String data = await loadAsset(language.index);
  dictionary = data.split("\n");
}

/// Function used to generify strings
/// (use wherever you want to use normal string)
/// simple use: print(translate(Tran.confirm))  prints 'Confirm' or 'Potwierdź'
/// depends of loaded language in app dictionary
String translate(Tran tran){
  return dictionary[tran.index];
}

/// Function like [translate] but with arguments which are replacing in text
/// simple use: print(Tran.delCategoryContent, ["Name of Category"])
/// prints: "Are you sure you want to delete category 'Name of Category'?"
String translateArgs(Tran tran, List<dynamic> arguments){
  String s = dictionary[tran.index];
  s = s.replaceAll("\$n", "\n");
  for(int i = 0; i<arguments.length; i++){
    s = s.replaceFirst("\$$i", "${arguments[i]}");
  }
  return s;
}