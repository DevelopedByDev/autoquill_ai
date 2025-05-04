import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:clipboard_watcher/clipboard_watcher.dart';

/// A service that listens for clipboard changes and provides callbacks
class ClipboardListenerService with ClipboardListener {
  static final ClipboardListenerService _instance = ClipboardListenerService._internal();
  
  factory ClipboardListenerService() {
    return _instance;
  }
  
  ClipboardListenerService._internal();
  
  // Callback for when clipboard content changes
  Function(String)? onClipboardTextChanged;
  
  // Flag to track if we're actively waiting for a clipboard change
  bool _isWaitingForClipboardChange = false;
  
  // Timer to handle timeout for clipboard changes
  Timer? _timeoutTimer;
  
  /// Initialize the clipboard watcher
  void init() {
    clipboardWatcher.addListener(this);
    if (kDebugMode) {
      print('ClipboardListenerService initialized');
    }
  }
  
  /// Start watching for clipboard changes with a timeout
  void startWatching({
    required Function(String) onTextChanged,
    required Function() onTimeout,
    required Function() onEmpty,
    Duration timeout = const Duration(seconds: 2),
  }) {
    // Set the callback
    onClipboardTextChanged = onTextChanged;
    
    // Always start the watcher - it's safe to call start() multiple times
    clipboardWatcher.start();
    
    _isWaitingForClipboardChange = true;
    
    // Set a timeout to stop watching if no changes occur
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(timeout, () {
      if (_isWaitingForClipboardChange) {
        _isWaitingForClipboardChange = false;
        onTimeout();
        // Don't stop the watcher here, just cancel the waiting state
      }
    });
    
    // Check if clipboard is empty immediately
    Clipboard.getData(Clipboard.kTextPlain).then((data) {
      if (data == null || data.text == null || data.text!.isEmpty) {
        onEmpty();
      }
    });
  }
  
  /// Stop watching for clipboard changes
  void stopWatching() {
    _isWaitingForClipboardChange = false;
    _timeoutTimer?.cancel();
    
    // Don't stop the watcher here, just cancel the waiting state
    // This allows us to keep the watcher running for future use
  }
  
  /// Dispose of the clipboard watcher
  void dispose() {
    clipboardWatcher.removeListener(this);
    clipboardWatcher.stop();
    _timeoutTimer?.cancel();
    if (kDebugMode) {
      print('ClipboardListenerService disposed');
    }
  }
  
  @override
  void onClipboardChanged() async {
    if (!_isWaitingForClipboardChange) return;
    
    ClipboardData? newClipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final text = newClipboardData?.text;
    
    if (text != null && text.isNotEmpty) {
      if (kDebugMode) {
        print('Clipboard changed: ${text.length} characters');
      }
      
      _isWaitingForClipboardChange = false;
      _timeoutTimer?.cancel();
      
      if (onClipboardTextChanged != null) {
        onClipboardTextChanged!(text);
      }
    }
  }
}
