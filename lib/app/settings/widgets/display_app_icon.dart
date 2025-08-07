import 'package:flutter/material.dart';

class DisplayAppIcon extends StatelessWidget {
  const DisplayAppIcon({
    super.key,
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      height: height,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: const Color.fromARGB(0, 0, 0, 0)),
        borderRadius: BorderRadius.circular(2),
        color: const Color.fromARGB(0, 0, 0, 0)
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.hardEdge,
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.asset(
            'assets/resources/appIcon.png',
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
