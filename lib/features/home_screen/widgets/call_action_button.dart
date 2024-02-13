import 'package:flutter/material.dart';
import 'package:get/utils.dart';

class CallActionButton extends StatelessWidget {
  const CallActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.color, required this.onTap,
  });

  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: SizedBox(
              height: context.height * .1,
              child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                    ),
                  ))),
        ),
        Text(text),
      ],
    );
  }
}
