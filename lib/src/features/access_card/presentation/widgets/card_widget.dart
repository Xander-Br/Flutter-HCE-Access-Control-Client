import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  
final String name;
  final String domain; 
  final Color cardColor;

  const CardWidget({
    super.key,
    required this.name,
    required this.domain,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.0), 
        boxShadow: [ 
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold, 
            ),
            maxLines: 2, 
            overflow: TextOverflow.ellipsis, 
          ),

          Align(
            alignment: Alignment.bottomRight, 
            child: Text(
              domain,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.85), 
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      
    );
  }
}
