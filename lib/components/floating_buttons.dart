import 'package:flutter/material.dart';

class SaveOnFirestoreFloatingButton extends FloatingActionButton{
  const SaveOnFirestoreFloatingButton(VoidCallback? callback, {Key? key}) :
        super(
        key: key,
        onPressed: callback,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.save),
      );
}

class AddChildFloatingButton extends FloatingActionButton{
  const AddChildFloatingButton(VoidCallback? callback, {Key? key}) :
        super(
        key: key,
        onPressed: callback,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      );
}

class AddChildFactoryFloatingButton extends FloatingActionButton{
  const AddChildFactoryFloatingButton(VoidCallback? callback, {Key? key}) :
        super(
        key: key,
        onPressed: callback,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.all_inclusive),
      );
}

class BottomFloatingButtons extends Padding {
  BottomFloatingButtons({List<FloatingActionButton>? buttons, Key? key}) : super(
      key: key,
      padding: const EdgeInsets.fromLTRB(35, 0, 5, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: buttons ?? [],
      )
  );
}