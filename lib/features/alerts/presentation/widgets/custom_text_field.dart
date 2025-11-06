import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget{
  final bool isEnabled;
  final ValueChanged<String>? onChanged;
  final String? labelText;
  final Widget? icon;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    this.isEnabled = true,
    this.onChanged,
    required this.controller,
    this.icon,
    this.labelText,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: Theme.of(context).textTheme.bodyMedium,
      controller: widget.controller,
      enabled: widget.isEnabled,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        prefixIcon: widget.icon,
        labelStyle: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}