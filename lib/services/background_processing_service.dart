import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// Service for handling background processing to keep UI responsive
class BackgroundProcessingService {
  static final BackgroundProcessingService _instance =
      BackgroundProcessingService._internal();
  factory BackgroundProcessingService() => _instance;
  BackgroundProcessingService._internal();

  // Queue for background tasks
  final Queue<_BackgroundTask> _taskQueue = Queue<_BackgroundTask>();
  bool _isProcessing = false;

  /// Process a task in the background using compute
  ///
  /// [task] - The function to execute in background
  /// [data] - Data to pass to the background function
  /// [taskName] - Name for logging and debugging
  static Future<T> processInBackground<T, R>(
    Future<T> Function(R data) task,
    R data, {
    String? taskName,
  }) async {
    try {
      if (kDebugMode) {
        print(
            'BackgroundProcessingService: Starting background task: ${taskName ?? 'unnamed'}');
      }

      final result = await compute(task, data);

      if (kDebugMode) {
        print(
            'BackgroundProcessingService: Completed background task: ${taskName ?? 'unnamed'}');
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print(
            'BackgroundProcessingService: Failed background task: ${taskName ?? 'unnamed'}: $e');
      }
      rethrow;
    }
  }

  /// Process a task in the background with progress updates
  ///
  /// [task] - The function to execute in background
  /// [data] - Data to pass to the background function
  /// [onProgress] - Callback for progress updates
  /// [taskName] - Name for logging and debugging
  static Future<T> processWithProgress<T, R>(
    Future<T> Function(R data) task,
    R data, {
    String? taskName,
  }) async {
    try {
      if (kDebugMode) {
        print(
            'BackgroundProcessingService: Starting background task with progress: ${taskName ?? 'unnamed'}');
      }

      final result = await compute(task, data);

      if (kDebugMode) {
        print(
            'BackgroundProcessingService: Completed background task with progress: ${taskName ?? 'unnamed'}');
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print(
            'BackgroundProcessingService: Failed background task with progress: ${taskName ?? 'unnamed'}: $e');
      }
      rethrow;
    }
  }

  /// Queue a task for background processing
  ///
  /// [task] - The function to execute
  /// [priority] - Priority of the task (higher = more important)
  /// [taskName] - Name for logging and debugging
  Future<void> queueTask(
    Future<void> Function() task, {
    int priority = 0,
    String? taskName,
  }) async {
    final backgroundTask = _BackgroundTask(
      task: task,
      priority: priority,
      taskName: taskName,
      createdAt: DateTime.now(),
    );

    _taskQueue.add(backgroundTask);

    // Sort queue by priority (highest first)
    _taskQueue.toList().sort((a, b) => b.priority.compareTo(a.priority));

    if (!_isProcessing) {
      _processQueue();
    }
  }

  /// Process the task queue
  Future<void> _processQueue() async {
    if (_isProcessing || _taskQueue.isEmpty) return;

    _isProcessing = true;

    try {
      while (_taskQueue.isNotEmpty) {
        final task = _taskQueue.removeFirst();

        try {
          if (kDebugMode) {
            print(
                'BackgroundProcessingService: Processing queued task: ${task.taskName ?? 'unnamed'}');
          }

          await task.task();

          if (kDebugMode) {
            print(
                'BackgroundProcessingService: Completed queued task: ${task.taskName ?? 'unnamed'}');
          }
        } catch (e) {
          if (kDebugMode) {
            print(
                'BackgroundProcessingService: Failed queued task: ${task.taskName ?? 'unnamed'}: $e');
          }
        }
      }
    } finally {
      _isProcessing = false;
    }
  }

  /// Get current queue status
  Map<String, dynamic> getQueueStatus() {
    return {
      'isProcessing': _isProcessing,
      'queueLength': _taskQueue.length,
      'nextTask': _taskQueue.isNotEmpty ? _taskQueue.first.taskName : null,
      'averagePriority': _taskQueue.isNotEmpty
          ? _taskQueue.map((t) => t.priority).reduce((a, b) => a + b) /
              _taskQueue.length
          : 0,
    };
  }

  /// Clear all queued tasks
  void clearQueue() {
    _taskQueue.clear();
  }

  /// Get the number of pending tasks
  int get pendingTaskCount => _taskQueue.length;

  /// Check if any tasks are being processed
  bool get isProcessing => _isProcessing;
}

/// Internal class for managing background tasks
class _BackgroundTask {
  final Future<void> Function() task;
  final int priority;
  final String? taskName;
  final DateTime createdAt;

  _BackgroundTask({
    required this.task,
    required this.priority,
    this.taskName,
    required this.createdAt,
  });
}

/// Mixin for widgets that need background processing
mixin BackgroundProcessingMixin {
  final BackgroundProcessingService _backgroundService =
      BackgroundProcessingService();

  /// Process a task in the background
  Future<T> processInBackground<T, R>(
    Future<T> Function(R data) task,
    R data, {
    String? taskName,
  }) {
    return BackgroundProcessingService.processInBackground(task, data,
        taskName: taskName);
  }

  /// Process a task with progress updates
  Future<T> processWithProgress<T, R>(
    Future<T> Function(R data) task,
    R data, {
    String? taskName,
  }) {
    return BackgroundProcessingService.processWithProgress(task, data,
        taskName: taskName);
  }

  /// Queue a task for background processing
  Future<void> queueTask(
    Future<void> Function() task, {
    int priority = 0,
    String? taskName,
  }) {
    return _backgroundService.queueTask(task,
        priority: priority, taskName: taskName);
  }

  /// Get queue status
  Map<String, dynamic> get queueStatus => _backgroundService.getQueueStatus();

  /// Clear task queue
  void clearTaskQueue() {
    _backgroundService.clearQueue();
  }

  /// Get pending task count
  int get pendingTaskCount => _backgroundService.pendingTaskCount;

  /// Check if processing
  bool get isProcessing => _backgroundService.isProcessing;
}

/// Example background processing functions
class BackgroundTasks {
  /// Process a large dataset in the background
  static Future<List<Map<String, dynamic>>> processLargeDataset(
    List<Map<String, dynamic>> data,
  ) async {
    // Simulate heavy processing
    await Future.delayed(const Duration(seconds: 2));

    // Process the data
    final processedData = <Map<String, dynamic>>[];

    for (final item in data) {
      // Simulate complex processing
      await Future.delayed(const Duration(milliseconds: 10));

      final processed = Map<String, dynamic>.from(item);
      processed['processed'] = true;
      processed['timestamp'] = DateTime.now().toIso8601String();

      processedData.add(processed);
    }

    return processedData;
  }

  /// Process data with progress updates
  static Future<List<Map<String, dynamic>>> processWithProgress(
    List<Map<String, dynamic>> data,
    Function(double) onProgress,
  ) async {
    final processedData = <Map<String, dynamic>>[];
    final total = data.length;

    for (int i = 0; i < total; i++) {
      // Simulate processing
      await Future.delayed(const Duration(milliseconds: 50));

      final processed = Map<String, dynamic>.from(data[i]);
      processed['processed'] = true;
      processed['progress'] = i + 1;

      processedData.add(processed);

      // Update progress
      final progress = (i + 1) / total;
      onProgress(progress);
    }

    return processedData;
  }

  /// Image processing example
  static Future<String> processImage(
    List<int> imageBytes,
  ) async {
    // Simulate image processing
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, you would process the image here
    // For now, just return a success message
    return 'Image processed successfully (${imageBytes.length} bytes)';
  }

  /// Data export example
  static Future<String> exportData(
    List<Map<String, dynamic>> data,
  ) async {
    // Simulate data export
    await Future.delayed(const Duration(seconds: 2));
    
    // In a real app, you would format and export the data
    // For now, just return a success message
    
    return 'Data exported successfully (${data.length} records)';
  }
}
