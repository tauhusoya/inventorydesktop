import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Service for debouncing operations to prevent excessive API calls
class DebounceService {
  static final DebounceService _instance = DebounceService._internal();
  factory DebounceService() => _instance;
  DebounceService._internal();

  // Map to store timers for different operations
  final Map<String, Timer> _timers = {};

  /// Debounce a function call with a specified delay
  /// 
  /// [key] - Unique identifier for this debounced operation
  /// [delay] - Delay in milliseconds before executing the function
  /// [callback] - Function to execute after the delay
  void debounce<T>(String key, Duration delay, Future<T> Function() callback) {
    // Cancel existing timer if it exists
    _timers[key]?.cancel();
    
    // Create new timer
    _timers[key] = Timer(delay, () async {
      try {
        await callback();
      } catch (e) {
        if (kDebugMode) {
          print('Debounced operation failed for key "$key": $e');
        }
      } finally {
        // Remove timer from map after execution
        _timers.remove(key);
      }
    });
  }

  /// Debounce a function call with a default delay of 300ms
  void debounce300<T>(String key, Future<T> Function() callback) {
    debounce(key, const Duration(milliseconds: 300), callback);
  }

  /// Debounce a function call with a default delay of 500ms
  void debounce500<T>(String key, Future<T> Function() callback) {
    debounce(key, const Duration(milliseconds: 500), callback);
  }

  /// Debounce a function call with a default delay of 1000ms
  void debounce1000<T>(String key, Future<T> Function() callback) {
    debounce(key, const Duration(milliseconds: 1000), callback);
  }

  /// Cancel a specific debounced operation
  void cancel(String key) {
    _timers[key]?.cancel();
    _timers.remove(key);
  }

  /// Cancel all debounced operations
  void cancelAll() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }

  /// Check if a specific operation is pending
  bool isPending(String key) {
    return _timers.containsKey(key);
  }

  /// Get the number of pending operations
  int get pendingCount => _timers.length;

  /// Dispose the service and cancel all timers
  void dispose() {
    cancelAll();
  }
}

/// Mixin for widgets that need debouncing functionality
mixin DebounceMixin {
  final DebounceService _debounceService = DebounceService();

  /// Debounce a function call
  void debounce<T>(String key, Duration delay, Future<T> Function() callback) {
    _debounceService.debounce(key, delay, callback);
  }

  /// Debounce with 300ms delay
  void debounce300<T>(String key, Future<T> Function() callback) {
    _debounceService.debounce300(key, callback);
  }

  /// Debounce with 500ms delay
  void debounce500<T>(String key, Future<T> Function() callback) {
    _debounceService.debounce500(key, callback);
  }

  /// Debounce with 1000ms delay
  void debounce1000<T>(String key, Future<T> Function() callback) {
    _debounceService.debounce1000(key, callback);
  }

  /// Cancel a specific debounced operation
  void cancelDebounce(String key) {
    _debounceService.cancel(key);
  }

  /// Cancel all debounced operations
  void cancelAllDebounces() {
    _debounceService.cancelAll();
  }

  /// Check if a specific operation is pending
  bool isDebouncePending(String key) {
    return _debounceService.isPending(key);
  }

  /// Get the number of pending operations
  int get pendingDebounceCount => _debounceService.pendingCount;

  void dispose() {
    _debounceService.dispose();
  }
}

/// Example usage in a search widget
class DebouncedSearchField extends StatefulWidget {
  final String hintText;
  final Function(String) onSearch;
  final Duration debounceDelay;

  const DebouncedSearchField({
    super.key,
    required this.hintText,
    required this.onSearch,
    this.debounceDelay = const Duration(milliseconds: 300),
  });

  @override
  State<DebouncedSearchField> createState() => _DebouncedSearchFieldState();
}

class _DebouncedSearchFieldState extends State<DebouncedSearchField> with DebounceMixin {
  final TextEditingController _controller = TextEditingController();
  String _lastSearchTerm = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final searchTerm = _controller.text.trim();
    
    // Don't search if term is the same or empty
    if (searchTerm == _lastSearchTerm || searchTerm.isEmpty) {
      return;
    }

    _lastSearchTerm = searchTerm;
    
    // Debounce the search operation
    debounce(
      'search',
      widget.debounceDelay,
      () async {
        widget.onSearch(searchTerm);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  _lastSearchTerm = '';
                  cancelDebounce('search');
                },
              )
            : null,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    cancelAllDebounces();
    super.dispose();
  }
}
