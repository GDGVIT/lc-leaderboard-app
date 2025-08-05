import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  const UserTile({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),

        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(4),
            ),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Pixel.avatar),
        
                const SizedBox(width: 20),
        
                Text(text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}