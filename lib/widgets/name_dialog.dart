import 'package:flutter/material.dart';

Future<String?> showNameDialog(
  BuildContext context, {
  required String title,
  required String initialTitle,
  required String confirmLabel,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _NameDialog(
      title: title,
      initialTitle: initialTitle,
      confirmLabel: confirmLabel,
    ),
  );
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.initialTitle,
    required this.confirmLabel,
  });

  final String title;
  final String initialTitle;
  final String confirmLabel;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialTitle,
  ); // Using late final to initialize the controller directly with the initial title because we don't need to do any complex initialization in initState.

  // For now lets not use initState, since we can initialize the controller directly. If we need to do more complex initialization in the future, we can uncomment this code.
  // @override
  // void initState() {
  //   super.initState();
  //   _controller = TextEditingController(text: widget.initialTitle);
  // }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(labelText: 'Name'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}
