# Persist Notifier

[![pub package](https://img.shields.io/pub/v/persist_notifier.svg)](https://pub.dev/packages/persist_notifier)

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

## Introduction

The plugin wraps platform-specific persistent storage for simple data
(NSUserDefaults on iOS and macOS, SharedPreferences on Android, etc.) using existing [ValueNotifier](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html) methods and newly defined methods for additional functionality.
Data may be persisted to disk asynchronously or synchronously.

Supported data types are `int`, `double`, `bool`, `String` and `List<String>`.

For information on storage of the values, see the documentation on [SharedPreferences](https://pub.dev/packages/shared_preferences).

## Usage
To use this plugin, add `persist_notifier` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/platform-integration/platform-channels).

### Examples
Here are small examples that show you how to use the API.

#### Definition
```dart
// Define as static or member variable
PersistNotifier pn = PersistNotifier("com.example.test", 0);

void example() async {
    // Define async
    var pn = PersistNotifier("com.example.test", 0);
    // Define sync
    var pn = await PersistNotifier.create("com.example.test", 0);
}
```

#### Read data
```dart
// Read in the default or stored value
PersistNotifier pn = await PersistNotifier.create("com.example.test", 0);
final int counter = pn.value;

// Force a sync of the stored value if the underlying value has changed.
// This should only happen if it's changed in a separate variable with
// the same key.
pn.resync();
```

#### Write data
```dart
// Read in the default or stored value
PersistNotifier pn = await PersistNotifier.create("com.example.test", 0);
pn.value = 7; // Async storage update
bool success = await pn.set(7); // Sync storage update
```

#### Remove an entry
```dart
// Reset the value back to the default
PersistNotifier pn = await PersistNotifier.create("com.example.test", 0);
pn.value = 7;
pn.reset();
// pn.value == 0
```

#### Extend the provided manager for settings
```dart
class SettingsManager extends PersistNotifierManager {
    // Make a singleton for easier access
    ...
    PersistNotifier pn = PersistNotifier("com.example.test", 0);
    PersistNotifier pnBoo = PersistNotifier("com.example.boo", 7);

    SettingsManager() {
        add(pn);
        add(pnBoo, group: "boo");
    }
}

void example() {
    SettingsManager manager = SettingsManager();
    manager.reset(group: "boo"); // Resets only the "boo" group
    manager.reset(); // Resets all
    List<PersistNotifier> list;
    list = manager.getAll(group: "boo"); // Gets only the "boo" group
    list = manager.getAll(); // Gets all groups combined
}
```

### Storage location by platform

| Platform | Location                         |
| :------- | :------------------------------- |
| Android  | SharedPreferences                |
| iOS      | NSUserDefaults                   |
| Linux    | In the XDG_DATA_HOME directory   |
| macOS    | NSUserDefaults                   |
| Web      | LocalStorage                     |
| Windows  | In the roaming AppData directory |

## Appreciation and Proposals

When we work on a project, any internal library we create that could benefit the community will be made public for free use. Please consider contributing, as work does go into creating and maintaining this library. As always, if something could be improved, please create an issue for it in the project repo and we'll be happy to discuss!

[<img src="img/buymecoffee.png" width="175"/>](https://www.buymeacoffee.com/voidari)

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/voidari/flutter-persist-notifier.svg?style=for-the-badge
[contributors-url]: https://github.com/voidari/flutter-persist-notifier/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/voidari/flutter-persist-notifier.svg?style=for-the-badge
[forks-url]: https://github.com/voidari/flutter-persist-notifier/network/members
[stars-shield]: https://img.shields.io/github/stars/voidari/flutter-persist-notifier.svg?style=for-the-badge
[stars-url]: https://github.com/voidari/flutter-persist-notifier/stargazers
[issues-shield]: https://img.shields.io/github/issues/voidari/flutter-persist-notifier.svg?style=for-the-badge
[issues-url]: https://github.com/voidari/flutter-persist-notifier/issues
[license-shield]: https://img.shields.io/github/license/voidari/flutter-persist-notifier.svg?style=for-the-badge
[license-url]: https://github.com/voidari/flutter-persist-notifier/blob/main/LICENSE