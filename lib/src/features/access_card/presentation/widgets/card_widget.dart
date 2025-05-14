// (In src/features/access_card/presentation/widgets/card_widget.dart)
import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final String name;
  final String domain;
  final Color cardColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress; // For potential delete/edit actions

  const CardWidget({
    super.key,
    required this.name,
    required this.domain,
    required this.cardColor,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // Determine text color based on background color's luminance for better contrast
    final textColor = cardColor.computeLuminance() > 0.4 ? Colors.black87 : Colors.white;
    final subTextColor = cardColor.computeLuminance() > 0.4 ? Colors.black54 : Colors.white70;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12.0), // Match decoration
      child: Container(
        width: double.infinity, // Make card take available width
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              name.isNotEmpty ? name : "Unnamed Account",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (domain.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                domain,
                style: TextStyle(
                  fontSize: 14,
                  color: subTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // You can add TOTP code display here later
            // For example, a placeholder for where the 6-digit code would go
            const SizedBox(height: 12),
            Text(
              "••• •••", // Placeholder for actual TOTP code
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}