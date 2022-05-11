import 'package:flutter/material.dart';
import 'package:time_management/translate/translator.dart';

/// Short description of functions:
/// * [showCustomDialog] is used to show simple dialog with title, content and several buttons
///
/// * [showDefaultDialog] is override of [showCustomDialog] but with build in
///   [DialogButton] - 'Cancel' and argument [content] is String
///
/// * [showDialogWithTextField] is override of [showCustomDialog] but with build in
///   [TextEditingController] as [content] of dialog, with [DialogButton] - 'Cancel'
///
/// * [showDialogExitApp] is override of [showCustomDialog] and it's used when
///   player want to exit app
///
/// * [showWarningDialog] is used to show Warning with simple String [content]
///   and optional single [DialogButton]

/// Dialog default customization
const String defaultTitle = "Time Management App";
const Text defaultContentConfirm = Text("");

/// Dialog Buttons labels:
final String confirm = translate(Tran.confirm);
final String delete = translate(Tran.delete);
final String cancel = translate(Tran.cancel);
final String yes = translate(Tran.yesAnswer);
final String no = translate(Tran.noAnswer);
final String ok = translate(Tran.okAnswer);
final String add = translate(Tran.add);
final String warning = translate(Tran.warning);
final String edit = translate(Tran.edit);

/// Customs Buttons to use in [showCustomDialog] as [button]
class DialogButton extends TextButton{
  DialogButton({
    String label = "",
    Color color = Colors.black,
    Key? key,
    required VoidCallback? onPressed,
  }) : super(key: key,
      onPressed: onPressed,
      child: Text(label, style: TextStyle(color: color))
  );

  DialogButton.confirm({Key? key, required VoidCallback? onPressed}) :
        this(key: key, onPressed: onPressed, color: Colors.green, label: confirm);

  DialogButton.delete({Key? key, required VoidCallback? onPressed}) :
        this(key: key, onPressed: onPressed, color: Colors.red, label: delete);

  DialogButton.cancel({Key? key, required VoidCallback? onPressed}) :
        this(key: key, onPressed: onPressed, label: cancel);

  DialogButton.yes({Key? key, required VoidCallback? onPressed}) :
        this(key: key, onPressed: onPressed, color: Colors.blue, label: yes);

  DialogButton.no({Key? key, required VoidCallback? onPressed}) :
        this(key: key, onPressed: onPressed, color: Colors.blue, label: no);

  DialogButton.ok({Key? key, required VoidCallback? onPressed}) :
        this(key: key, onPressed: onPressed, color: Colors.blue, label: ok);

  DialogButton.add({Key? key, required VoidCallback? onPressed}) :
        this(key: key, onPressed: onPressed, color: Colors.green, label: add);

  DialogButton.edit({Key? key, required VoidCallback? onPressed}) :
        this(key: key, onPressed: onPressed, color: Colors.green, label: edit);
}

Future<bool?> showCustomDialog(
    BuildContext context, {
      String title = defaultTitle,
      Widget content = defaultContentConfirm,
      required List<DialogButton> buttons,
    }) async{
  return await showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text(title),
          content: content,
          actions: buttons,
        );
      }
  );
}

/// Shows Default dialog with Cancel button and one custom button
Future<bool?> showDefaultDialog(
    BuildContext context, {
      String title = "",
      String content = "",
      required DialogButton button,
    }) async{
  return await showCustomDialog(context,
      title: title,
      content: Text(content),
      buttons: [DialogButton.cancel(onPressed: () => Navigator.of(context).pop()), button]);
}

/// Shows Dialog like [showDefaultDialog] but with more optional [DialogButton]
Future<bool?> showOptionsDialog(
    BuildContext context, {
      String title = "",
      String content = "",
      required List<DialogButton> buttons,
    }) async{
  return await showCustomDialog(context,
      title: title,
      content: Text(content),
      buttons: [DialogButton.cancel(onPressed: () => Navigator.of(context).pop())] + buttons);
}

/// Shows Warning dialog with OK [DialogButton]
Future<bool?> showWarningDialog(
    BuildContext context, {
      String content = "",
      List<DialogButton>? buttons,
    }) async{
  return await showDialog(
      context: context,
      builder: (BuildContext context){
        List<DialogButton> list = [];
        if(buttons != null) {
          list = buttons;
        } else {
          list = [DialogButton.ok(onPressed: () => Navigator.of(context).pop())];
        }
        return AlertDialog(
          title: Text(warning, style: const TextStyle(color: Colors.deepOrange),),
          content: Text(content),
          actions: list,
        );
      }
  );
}

Future<bool?> showDialogWithTextField(
    BuildContext context, {
      String title = "",
      String hint = "",
      required TextEditingController tec,
      required DialogButton button,
    }) async{
  return await showCustomDialog(
      context,
      title: title,
      content: TextField(
        controller: tec,
        textInputAction: TextInputAction.go,
        decoration: InputDecoration(hintText: hint),
      ),
      buttons: [DialogButton.cancel(onPressed: () => Navigator.of(context).pop()), button]
  );
}


/// Dialog shows when user clicked back button in [To Do] activity
Future<bool?> showDialogExitApp(BuildContext context) async{
  return await showCustomDialog(context,
      title: translate(Tran.areYouSure),
      content: Text(translate(Tran.exitApp)),
      buttons: [
        DialogButton.no(onPressed: () => Navigator.of(context).pop(false)),
        DialogButton.yes(onPressed: () => Navigator.of(context).pop(true)),
      ],
  );
}