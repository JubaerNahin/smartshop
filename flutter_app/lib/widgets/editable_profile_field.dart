import 'package:flutter/material.dart';
import 'my_textfield.dart'; // Make sure this import path is correct

class EditableProfileField extends StatefulWidget {
  final String label;
  final String value;
  final bool obscure;
  final Function(String) onChanged;

  const EditableProfileField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.obscure = false,
  });

  @override
  State<EditableProfileField> createState() => _EditableProfileFieldState();
}

class _EditableProfileFieldState extends State<EditableProfileField> {
  bool isEditing = false;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child:
                isEditing
                    ? MyTextfield(
                      hintText: widget.label,
                      obsecureText: widget.obscure,
                      controller: controller,
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.label == 'Password'
                              ? 'Wanna Change Password?'
                              : widget.value,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
          ),
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (isEditing) {
                widget.onChanged(controller.text);
              }
              setState(() => isEditing = !isEditing);
            },
          ),
        ],
      ),
    );
  }
}
