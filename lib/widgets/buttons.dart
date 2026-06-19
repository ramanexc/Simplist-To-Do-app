import 'package:flutter/material.dart';

class Buttons extends StatelessWidget {
  const Buttons({super.key, required this.buttontext, required this.onPressed});
  final String buttontext;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return MaterialButton(onPressed: onPressed, child: Text(buttontext));
  }
}
