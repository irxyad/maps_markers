import 'package:flutter/material.dart';
import 'package:maps_markers/cons.dart';
import 'package:maps_markers/main.dart';

class ButtonIcon extends StatelessWidget {
  const ButtonIcon({
    Key? key,
    required this.label,
    required this.icon,
    required this.function,
    required this.elevation,
  }) : super(key: key);

  final String label;
  final double elevation;

  final Widget icon;
  final VoidCallback function;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        style: ButtonStyle(
            alignment: Alignment.center,
            elevation: MaterialStateProperty.all(elevation),
            padding: MaterialStateProperty.all(
              const EdgeInsets.all(8),
            ),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)))),
        onPressed: function,
        icon: icon,
        label: Text(
          label,
        ));
  }
}

class JustText extends StatelessWidget {
  final Color bgColor;
  final String label;
  final IconData icon;
  const JustText(
      {super.key,
      required this.label,
      required this.icon,
      required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(9),
      child: Row(
        children: [
          Icon(
            icon,
            color: MyApp.themeNotifier.value == ThemeMode.light ? black : white,
          ),
          const SizedBox(
            width: 6,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );
  }
}
