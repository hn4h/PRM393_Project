import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: const [
          CircleAvatar(
            radius: 44,
            backgroundImage:
                NetworkImage("https://picsum.photos/id/1027/500/500"),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "James Anderson",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              SizedBox(width: 6),
              Icon(Icons.verified, size: 18, color: Color(0xFF2F80ED)),
            ],
          ),
          SizedBox(height: 4),
          Text(
            "Cleaning",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2F80ED),
            ),
          ),
        ],
      ),
    );
  }
}