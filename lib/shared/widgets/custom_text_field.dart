import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.suffixIcon = false,
    this.prefixIcon = false,
    this.icon,
    this.onIconTap,
    this.onSuffixIconTap,
    this.maxLength,
    this.validator,
    this.isPassword = false,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;

  final bool suffixIcon;
  final bool prefixIcon;
  final IconData? icon;
  final void Function()? onIconTap;
  final void Function()? onSuffixIconTap;
  final int? maxLength;
  final bool isPassword;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      maxLength: widget.maxLength,
      obscureText: _obscureText,
      validator: widget.validator,
      decoration: InputDecoration(
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Theme.of(context).primaryColor, size: 25),
              )
            : (widget.suffixIcon
                  ? GestureDetector(
                      onTap: widget.onSuffixIconTap ?? () {},
                      child: Icon(widget.icon, color: Theme.of(context).primaryColor, size: 25),
                    )
                  : null),
        prefixIcon: widget.prefixIcon
            ? GestureDetector(
                onTap: widget.onIconTap ?? () {},
                child: Icon(widget.icon, color: Theme.of(context).primaryColor, size: 25),
              )
            : null,
        hintText: widget.icon == Icons.search ? widget.hintText : "Enter ${widget.hintText}",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }
}
