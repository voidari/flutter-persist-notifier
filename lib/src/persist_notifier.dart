library persist_notifier;

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An extension of ValueNotifier so an existing notification system
/// exists. Adds functionality to store the key/value pair on the file
/// system so that it loads the old value on initialization.
class PersistNotifier<T> extends ValueNotifier {
  /// The key used to identify the value in storage and sync.
  final String key;

  /// The value used by default until the value is changed.
  /// The value assigned when [reset()] is used.
  final dynamic defaultValue;

  VoidCallback? _internalListener;
  final List<VoidCallback> _listeners = <VoidCallback>[];

  /// The constructor for creating a new PersistNotifier.
  //
  /// Asynchronously pulls the default value from storage. If a
  /// synchronous method of creation is wanted, use the static
  /// [create()] method.
  PersistNotifier(this.key, this.defaultValue, {sync = true})
      : super(defaultValue) {
    if (!sync) {
      return;
    }
    _register();
  }

  /// Statically create a persist notifier and provide a means of
  /// making the process synchronous or asynchronous.
  static Future<PersistNotifier> create(
      String key, dynamic defaultValue) async {
    PersistNotifier pn = PersistNotifier(key, defaultValue, sync: false);
    await pn.resync();
    return pn;
  }

  /// Resyncs the value by pulling the existing value from storage and
  /// overriding the currently set value.
  Future<void> resync() async {
    _register();
  }

  /// Sets the value of the notifier. Returns whether the storage update was
  /// successful or if an error ocurred.
  Future<bool> set(dynamic newValue) async {
    final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
    super.value = newValue;
    if (defaultValue is int) {
      return prefs.then((SharedPreferences prefs) {
        return prefs.setInt(key, newValue);
      });
    } else if (defaultValue is double) {
      return prefs.then((SharedPreferences prefs) {
        return prefs.setDouble(key, newValue);
      });
    } else if (defaultValue is bool) {
      return prefs.then((SharedPreferences prefs) {
        return prefs.setBool(key, newValue);
      });
    } else if (defaultValue is String) {
      return prefs.then((SharedPreferences prefs) {
        return prefs.setString(key, newValue);
      });
    } else if (defaultValue is List<String>) {
      return prefs.then((SharedPreferences prefs) {
        return prefs.setStringList(key, newValue);
      });
    } else {
      throw Exception(
          "The value type ${defaultValue.runtimeType} is not supported.");
    }
  }

  Future<void> _register() async {
    // Remove the listener
    if (_internalListener != null) {
      super.removeListener(_internalListener!);
    }

    // Register the value components
    if (defaultValue is int) {
      await _registerInt(key, defaultValue);
    } else if (defaultValue is double) {
      await _registerDouble(key, defaultValue);
    } else if (defaultValue is bool) {
      await _registerBool(key, defaultValue);
    } else if (defaultValue is String) {
      await _registerString(key, defaultValue);
    } else if (defaultValue is List<String>) {
      await _registerStringList(key, defaultValue);
    } else {
      throw Exception(
          "The value type ${defaultValue.runtimeType} is not supported.");
    }

    // Register the new listener
    super.addListener(_internalListener!);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    _listeners.remove(listener);
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _listeners.add(() => listener);
  }

  /// Clears the list of listeners so that no callbacks will be
  /// made on value changes.
  void clearListeners() {
    for (VoidCallback listener in _listeners) {
      super.removeListener(listener);
    }
    _listeners.clear();
  }

  /// Resets the data back to the default and clears the value from storage.
  Future<void> reset() async {
    if (_internalListener != null) {
      super.removeListener(_internalListener!);
    }
    super.value = defaultValue;
    final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
    await prefs.then((SharedPreferences prefs) {
      prefs.remove(key);
    });
    if (_internalListener != null) {
      super.addListener(_internalListener!);
    }
  }

  /// Registers a int value, enabling the listener and setting the default
  Future<void> _registerInt(String key, int defaultValue) async {
    final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
    super.value = await prefs.then((SharedPreferences prefs) {
      return prefs.getInt(key) ?? defaultValue;
    });
    _internalListener = () {
      prefs.then((SharedPreferences prefs) {
        prefs.setInt(key, super.value);
      });
    };
  }

  /// Registers a double value, enabling the listener and setting the default
  Future<void> _registerDouble(String key, double defaultValue) async {
    final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
    super.value = await prefs.then((SharedPreferences prefs) {
      return prefs.getDouble(key) ?? defaultValue;
    });
    _internalListener = () {
      prefs.then((SharedPreferences prefs) {
        prefs.setDouble(key, super.value);
      });
    };
  }

  /// Registers a boolean value, enabling the listener and setting the default
  Future<void> _registerBool(String key, bool defaultValue) async {
    final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
    super.value = await prefs.then((SharedPreferences prefs) {
      return prefs.getBool(key) ?? defaultValue;
    });
    _internalListener = () {
      prefs.then((SharedPreferences prefs) {
        prefs.setBool(key, super.value);
      });
    };
  }

  /// Registers a string value, enabling the listener and setting the default
  Future<void> _registerString(String key, String defaultValue) async {
    final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
    super.value = await prefs.then((SharedPreferences prefs) {
      return prefs.getString(key) ?? defaultValue;
    });
    _internalListener = () {
      prefs.then((SharedPreferences prefs) {
        prefs.setString(key, super.value);
      });
    };
  }

  /// Registers a string list, enabling the listener and setting the default
  Future<void> _registerStringList(
      String key, List<String> defaultValue) async {
    final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
    super.value = await prefs.then((SharedPreferences prefs) {
      return prefs.getStringList(key) ?? defaultValue;
    });
    _internalListener = () {
      prefs.then((SharedPreferences prefs) {
        prefs.setStringList(key, super.value);
      });
    };
  }
}
