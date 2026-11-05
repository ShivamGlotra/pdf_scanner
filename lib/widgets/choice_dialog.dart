import 'package:flutter/material.dart';

// Shows the user a dialog with a list of options to choose from and returns the value of the selected option.
// Works for theme, formats, numbers and returns null if the user cancels the dialog.
Future<T?> showChoiceDialog<T>({
  required BuildContext context,
  required String title,
  required List<T> options,
  required T selected,
  required String Function(T option) labelOf,
}) {
  return showDialog<T>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(title),
      children: [
        for (final option in options)
          ListTile(
            title: Text(labelOf(option)),
            trailing: selected == option ? const Icon(Icons.check) : null,
            onTap: () => Navigator.pop(context, option),
          ),
      ],
    ),
  );
}
