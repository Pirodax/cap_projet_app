import 'package:flutter/material.dart';

class Search_Bar extends StatelessWidget {
  final TextEditingController textController;
  final String hintText;
  final VoidCallback onClear;
  final FocusNode focusNode;

  const Search_Bar({
    required this.textController,
    required this.hintText,
    required this.onClear,
    required this.focusNode,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: textController,
      builder: (context, value, child) {
        return TextField(
          controller: textController,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
            suffixIcon: value.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: onClear,
            )
                : null,
            hintStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.all(15),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.transparent)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.transparent)),
          ),
        );
      },
    );
  }
}