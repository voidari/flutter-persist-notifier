library persist_notifier;

import 'package:persist_notifier/persist_notifier.dart';

/// The manager of all registered persist notifiers. The persist notifier
/// manager can be used as general manager or extended for a settings manager.
class PersistNotifierManager {
  /// The map of group and notifiers for tracking.
  final Map<String, List<PersistNotifier>> _persistNotifierMap =
      <String, List<PersistNotifier>>{};

  /// Register a persist notifier with the manager for tracking.
  void add(PersistNotifier persistNotifier, {String group = ""}) {
    if (!_persistNotifierMap.containsKey(group)) {
      _persistNotifierMap[group] = <PersistNotifier>[];
    }
    if (!_persistNotifierMap[group]!.contains(persistNotifier)) {
      _persistNotifierMap[group]?.add(persistNotifier);
    }
  }

  /// Unregister a persist notifier to remove tracking.
  bool remove(PersistNotifier persistNotifier) {
    for (String key in _persistNotifierMap.keys) {
      if (_persistNotifierMap[key]!.contains(persistNotifier)) {
        _persistNotifierMap[key]!.remove(persistNotifier);
        return true;
      }
    }
    return false;
  }

  /// Helper function for resetting the list
  Future<void> _reset(List<PersistNotifier>? persistNotifierList) async {
    // Validate the list
    if (persistNotifierList == null) {
      return;
    }
    // Perform the reset
    for (PersistNotifier persistNotifier in persistNotifierList) {
      await persistNotifier.reset();
    }
  }

  /// Resets all groups back to their default value, or a single
  /// group if one is specified.
  Future<void> reset({String? group}) async {
    // If a group was speciefied, only reset that group
    if (group != null) {
      await _reset(_persistNotifierMap[group]);
      return;
    }
    // Reset every group
    for (String key in _persistNotifierMap.keys) {
      await _reset(_persistNotifierMap[key]);
    }
  }

  /// Retrieves all the persist notifiers tracked by the manager if no
  /// group is provided. An empty list will be returned if a group provided
  /// does not exist.
  List<PersistNotifier> getAll({String? group}) {
    // Validate the group
    if (group != null && !_persistNotifierMap.containsKey(group)) {
      return <PersistNotifier>[];
    }
    // Get only the group if one was specified
    if (group != null && _persistNotifierMap.containsKey(group)) {
      return _persistNotifierMap[group]!;
    }
    List<PersistNotifier> combinedList = <PersistNotifier>[];
    for (String key in _persistNotifierMap.keys) {
      combinedList.addAll(_persistNotifierMap[key]!);
    }
    return combinedList;
  }
}
