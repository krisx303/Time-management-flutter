import 'package:flutter/material.dart';
import 'package:time_management/translate/translator.dart';


class SlideRightBackground extends Container{
  SlideRightBackground({
    required Color color,
    required IconData icon,
    required String text,
    Key? key,
  }) : super(
    key: key,
    color: color,
    child: Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            width: 20,
          ),
          Icon(
            icon,
            color: Colors.white,
          ),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
      alignment: Alignment.centerLeft,
    )
  );
}

class SlideLeftBackground extends Container{
  SlideLeftBackground({
    required Color color,
    required IconData icon,
    required String text,
    Key? key,
  }) : super(
      key: key,
      color: color,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              icon,
              color: Colors.white,
            ),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      )
  );
}

final String delete = " " + translate(Tran.delete);
final String done = " " + translate(Tran.done);

Widget slideRightDeleteBackground() {
  return SlideRightBackground(color: Colors.red, icon: Icons.delete, text: delete);
}

Widget slideRightDoneBackground(){
  return SlideRightBackground(color: Colors.green, icon: Icons.done, text: done);
}

Widget slideLeftDeleteBackground(){
  return SlideLeftBackground(color: Colors.red, icon: Icons.delete, text: delete);
}