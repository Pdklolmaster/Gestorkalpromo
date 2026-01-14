import 'dart:async';

enum AppAction { showSmartInput, showAddOptions }

class ActionBus {
  static final StreamController<AppAction> _controller = StreamController<AppAction>.broadcast();

  static Stream<AppAction> get stream => _controller.stream;

  static void emit(AppAction action) => _controller.add(action);

  static void dispose() {
    _controller.close();
  }
}
