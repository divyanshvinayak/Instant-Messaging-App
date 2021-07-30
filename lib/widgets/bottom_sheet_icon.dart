import 'package:flutter/material.dart';

class BottomSheetIcon extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final String text;
  final double radius;
  final Function() function;

  const BottomSheetIcon({
    required this.icon,
    required this.backgroundColor,
    required this.text,
    required this.radius,
    required this.function,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: function,
          child: CircleAvatar(
            radius: radius,
            backgroundColor: backgroundColor,
            child: Icon(
              icon,
              size: radius - 1,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        )
      ],
    );
  }
}
