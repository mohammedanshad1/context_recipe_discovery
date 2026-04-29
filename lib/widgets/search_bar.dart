import 'dart:async';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearch;

  const SearchBarWidget({super.key, required this.onSearch});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Search recipes...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      onChanged: _onSearchChanged,
    );
  }
}