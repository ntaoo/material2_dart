import "package:angular2/angular2.dart";

typedef void MdUniqueSelectionDispatcherListener(String id, String name);

/**
 * Class to coordinate unique selection based on name.
 * Intended to be consumed as an Angular service.
 * This service is needed because native radio change events are only fired on the item currently
 * being selected, and we still need to uncheck the previous selection.
 *
 * This service does not *store* any IDs and names because they may change at any time, so it is
 * less error-prone if they are simply passed through when the events occur.
 */
@Injectable()
class MdUniqueSelectionDispatcher {
  List<MdUniqueSelectionDispatcherListener> _listeners = [];

  // Notify other items that selection for the given name has been set.
  void notify(String id, String name) {
    for (var listener in _listeners) {
      listener(id, name);
    }
  }

  // Listen for future changes to item selection.
  void listen(MdUniqueSelectionDispatcherListener listener) {
    _listeners.add(listener);
  }
}
