import 'package:flutter/material.dart';

import '../widgets/exercise/triangle.dart';
import 'dart:math' as math;

/// Triangle Container (used on right in cards)
class TriangleRight extends CustomPaint{
  TriangleRight({Key? key,
    required Color color,
    double? height,
    double? width,
  }) : super(
      key: key,
      painter: TrianglePainter(
        strokeColor: color,
        strokeWidth: 10,
        paintingStyle: PaintingStyle.fill,
      ),
      child: SizedBox(
        height: height ?? 100,
        width: width ?? 50,
      )
  );
}

/// Thin colored container (used on top of cards)
class ColoredContainer extends Container{
  ColoredContainer({required Color color, Key? key}) : super(
      key: key,
      color: color,
      height: 10
  );
}

/// Standard Card Class with decorations
class CardElement extends Card{
  CardElement({
    Key? key,
    double marginVertical = 12,
    double marginHorizontal = 10,
    required List<Widget> content,
    bool hasTopColorBar = false,
    Color colorTopBar = Colors.blue,
  }) : super(
      key: key,
      elevation: 5,
      margin: EdgeInsets.fromLTRB(marginHorizontal, marginVertical, marginHorizontal, marginVertical),
      child: Column(
          children: [
            (hasTopColorBar ? ColoredContainer(color: colorTopBar) : const SizedBox.shrink()),
            RowOfContent(content: content),
          ]
      )
  );
}

/// Main Row in Cards
class RowOfContent extends Row{
  RowOfContent({
    Key? key,
    required List<Widget> content,
  }) : super(
    key: key,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: content,
  );
}

/// Main Padding in Cards (Left texts in cards)
class CardMainContent extends Padding{
  CardMainContent({Key? key,
    required List<Widget> content,
  }) : super(
      key: key,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content,
      )
  );
}

/// Confirm Button (used to confirm add new element)
class ConfirmButton extends TextButton{
  const ConfirmButton({
    Key? key,
    required VoidCallback? tryConfirm,
  }) : super(
      key: key,
      onPressed: tryConfirm,
      child: const TextButtonWithIconChild(label: Icon(Icons.send), icon: Text("Confirm")),
  );
}

/// Components to ConfirmButton (copied from TextButton class)
class TextButtonWithIconChild extends StatelessWidget {
  const TextButtonWithIconChild({
    Key? key,
    required this.label,
    required this.icon,
  }) : super(key: key);

  final Widget label;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.maybeOf(context)?.textScaleFactor ?? 1;
    final double gap = scale <= 1 ? 8 : lerpDouble(8, 4, math.min(scale - 1, 1))!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[icon, SizedBox(width: gap), Flexible(child: label)],
    );
  }
}

double? lerpDouble(num? a, num? b, double t) {
  if (a == b || (a?.isNaN == true) && (b?.isNaN == true)) {
    return a?.toDouble();
  }
  a ??= 0.0;
  b ??= 0.0;
  assert(a.isFinite, 'Cannot interpolate between finite and non-finite values');
  assert(b.isFinite, 'Cannot interpolate between finite and non-finite values');
  assert(t.isFinite, 't must be finite when interpolating between values');
  return a * (1.0 - t) + b * t;
}