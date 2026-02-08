import 'package:whale_chat/theme/color_scheme.dart';
import 'package:flutter/material.dart';

class EditContainer extends StatelessWidget {
  const EditContainer({
    super.key,
    required this.text,
    required this.hint,
    required this.controller,
    required this.updateProfileScreen,
  });

  final String text;
  final String hint;
  final TextEditingController controller;
  final VoidCallback updateProfileScreen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 20,
              color: colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: colorScheme.secondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  width: 3,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: updateProfileScreen,
              child: Text(
                'Save',
                style: TextStyle(
                  color: colorScheme.surface,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
