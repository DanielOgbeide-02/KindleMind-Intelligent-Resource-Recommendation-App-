import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserItem extends StatelessWidget {
  const UserItem({
    super.key,
    required this.name,
    required this.userName,
    required this.bioInfo,
  });

  final String? name;
  final String? userName;
  final String? bioInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            child: Icon(Icons.person),
          ),
          SizedBox(width: 20),
          Expanded( // Ensures text takes only available space
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name ?? '', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),),
                Text('@$userName'),
                SizedBox(width: 2.5)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
