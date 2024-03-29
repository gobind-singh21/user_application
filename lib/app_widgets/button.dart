import 'package:flutter/material.dart';
import 'package:notes_application/app_widgets/text_widgets/heading_text.dart';

class MyButton extends StatelessWidget {
  final String _buttonText;
  final double _height, _width, _borderRadius;
  const MyButton(
      this._buttonText, this._height, this._width, this._borderRadius, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      width: _width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        // color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: HeadingText(_buttonText, _height / 2.5, null, Colors.white),
    );
  }
}
