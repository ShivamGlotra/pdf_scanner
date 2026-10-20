import 'dart:async';
import 'package:flutter/material.dart';

class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    this.hintText = 'Search library',
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.fillColor,
  });

  final Color? fillColor;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onChanged?.call(value);
    });
  }

  void _clear() {
    _controller.clear();
    _debounce?.cancel();
    widget.onChanged?.call('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final focused = _focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: 52,
      decoration: BoxDecoration(
        // Same fill in both states, distinct from the app bar
        color: widget.fillColor ?? scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: focused ? scheme.primary : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: scheme.primary.withAlpha(30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : const [],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.search_rounded,
                key: ValueKey(focused),
                color: focused ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              textInputAction: TextInputAction.search,
              onChanged: _handleChanged,
              onSubmitted: widget.onSubmitted,
              style: theme.textTheme.bodyLarge,
              cursorColor: scheme.primary,
              decoration: InputDecoration.collapsed(
                hintText: widget.hintText,
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: _controller.text.isEmpty
                ? const SizedBox(width: 16, key: ValueKey('empty'))
                : IconButton(
                    key: const ValueKey('clear'),
                    icon: const Icon(Icons.close_rounded),
                    iconSize: 20,
                    color: scheme.onSurfaceVariant,
                    tooltip: 'Clear',
                    onPressed: _clear,
                  ),
          ),
        ],
      ),
    );
  }
}
