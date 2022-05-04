
import 'package:flutter/material.dart';


Future<bool?> showDialogWantToDelete(BuildContext context, String content, String title, VoidCallback onYesClick) async{
  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            CancelDialogButton(onPressed: () {
              Navigator.of(context).pop();
            }),
            DeleteDialogButton(onPressed: () {
              Navigator.of(context).pop();
              onYesClick();
            }),
          ],
        );
      });
}

Future<bool?> showDialogConfirm(BuildContext context, String content, String title, VoidCallback onYesClick) async{
  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            CancelDialogButton(onPressed: () {
              Navigator.of(context).pop();
            }),
            ConfirmDialogButton(onPressed: () {
              Navigator.of(context).pop();
              onYesClick();
            }),
          ],
        );
      });
}


Future<bool?> showDialogExitApp(BuildContext context) async{
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Are you sure?'),
      content: const Text('Do you want to exit an App? :('),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Yes'),
        ),
      ],
    ),
  );
}

Future<bool?> showDialogWithTextField(BuildContext context, String title, TextEditingController tec, String hintText, VoidCallback onYesClick) async{
  return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: tec,
            textInputAction: TextInputAction.go,
            decoration: InputDecoration(hintText: hintText),
          ),
          actions: <Widget>[
            AddDialogButton(onPressed: () {
              onYesClick();
              Navigator.of(context).pop();
            })
          ],
        );
      });
}

class AddDialogButton extends TextButton{
  const AddDialogButton({Key? key,
    required VoidCallback? onPressed,
  }) : super(key: key,
      onPressed: onPressed,
      child: const Text(
        "Add",
        style: TextStyle(color: Colors.blue),
      )
  );
}


class CancelDialogButton extends TextButton{
  const CancelDialogButton({Key? key,
    required VoidCallback? onPressed,
  }) : super(key: key,
      onPressed: onPressed,
      child: const Text(
        "Cancel",
        style: TextStyle(color: Colors.black),
      )
  );
}

class DeleteDialogButton extends TextButton{
  const DeleteDialogButton({Key? key,
    required VoidCallback? onPressed,
  }) : super(key: key,
      onPressed: onPressed,
      child: const Text(
        "Delete",
        style: TextStyle(color: Colors.red),
      )
  );
}

class ConfirmDialogButton extends TextButton{
  const ConfirmDialogButton({Key? key,
    required VoidCallback? onPressed,
  }) : super(key: key,
      onPressed: onPressed,
      child: const Text(
        "Confirm",
        style: TextStyle(color: Colors.green),
      )
  );
}