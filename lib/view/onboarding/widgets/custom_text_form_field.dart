import 'package:whale_chat/theme/color_scheme.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.hintText,
    required this.validator,
    required this.controller,
    this.isPasswordField = false,
    this.keyboardType = TextInputType.emailAddress,
    required this.textInputAction,
    required this.icon,
  });

  final String hintText;
  final bool isPasswordField;
  final FormFieldValidator<String> validator;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final IconData icon;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormField();
}

class _CustomTextFormField extends State<CustomTextFormField> {
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.disabled,
      textInputAction: widget.textInputAction,
      autofocus: true,
      obscureText: widget.isPasswordField && !isVisible ? true : false,
      obscuringCharacter: "*",
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: widget.hintText,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error),
          borderRadius: BorderRadius.circular(8),
        ),
        hintStyle: TextStyle(
          color: Color(0xFFAAAAAA),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        suffixIcon: widget.isPasswordField == true
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    isVisible = !isVisible;
                  });
                },
                child: Icon(
                  isVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              )
            : null,
      ),
    );
  }
}
