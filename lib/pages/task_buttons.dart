import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.textColor = Colors.white,
  });

  final String label;
  final VoidCallback onPressed;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    //var appState = context.watch<MyAppState>();
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            elevation: 8,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(32)),
        onPressed: () {
          onPressed();
        },
        child: Text(
          label,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: (textColor != Colors.white)
                  ? textColor
                  : theme.textTheme.displayMedium!.color),
        ));
  }
}
