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
    super.key,
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
            prefixIcon: Icon(Icons.search, color: Colors.teal.shade600),
            suffixIcon: value.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.blueGrey.shade400),
                    onPressed: onClear,
                  )
                : null,
            hintStyle: TextStyle(color: Colors.blueGrey.shade400),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.teal.shade400, width: 1.5),
            ),
          ),
        );
      },
    );
  }
}
