import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/app_theme.dart';


class ResourceItem extends StatelessWidget {
  const ResourceItem({
    super.key,required this.quote,required this.author, this.articleType
  });

  final String? quote;
  final String? author;
  final String? articleType;




  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      height: 85,
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow:  const [
            BoxShadow(
                color: Color(0xFF17203A),
                offset: Offset(0, 5),
                blurRadius: 5
            )
          ]
      ),
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(articleType!, style: TextStyle(color: Colors.white),),
              Icon(
                  Icons.arrow_forward,
                color: Colors.white,
              )
            ],
          ),
          Text(
            '~ ${author}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }
}
