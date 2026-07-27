import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [

        Expanded(
          child: Divider(
            color: Colors.white38,
            thickness: 1,
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
        ),

        Expanded(
          child: Divider(
            color: Colors.white38,
            thickness: 1,
          ),
        ),

      ],
    );
  }
}