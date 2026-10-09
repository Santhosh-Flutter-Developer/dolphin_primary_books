import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

void showSnackbar(BuildContext context,
    {required String content, required bool isSuccess}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      content: Row(
        mainAxisSize: MainAxisSize
            .min, // Ensures that the row takes up only as much space as necessary
        children: [
          Icon(
            isSuccess ? Iconsax.tick_circle : Iconsax.close_circle,
            color: Colors.white,
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            // Allows the text to take up the remaining space
            child: Text(
              content,
              overflow: TextOverflow
                  .ellipsis, // Ensures text will be truncated with an ellipsis
              style: const TextStyle(
                  color:
                      Colors.white), // Ensure text color is visible on Snackbar
              maxLines: 2, // Optional: Limits the text to 2 lines if necessary
            ),
          ),
        ],
      ),
    ),
  );
}
