// Copyright (C) 2022 by Voidari LLC or its subsidiaries.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:persist_notifier/persist_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferences', () {
    const String testString = 'Hello, World';
    const bool testBool = true;
    const int testInt = 117;
    const double testDouble = 3.14159;
    const List<String> testList = <String>['foo', 'bar'];
    const Map<String, Object> testValues = <String, Object>{
      'flutter.String': testString,
      'flutter.bool': testBool,
      'flutter.int': testInt,
      'flutter.double': testDouble,
      'flutter.List': testList,
    };

    const String testString2 = 'Goodbye, World';
    const bool testBool2 = false;
    const int testInt2 = 42;
    const double testDouble2 = 2.71828;
    const List<String> testList2 = <String>['baz', 'quox'];

    late FakeSharedPreferencesStore store;
    late SharedPreferences preferences;

    setUp(() async {
      store = FakeSharedPreferencesStore(testValues);
      SharedPreferencesStorePlatform.instance = store;
      preferences = await SharedPreferences.getInstance();
      store.log.clear();
    });

    test('basic', () async {
      // async
      PersistNotifier pn = PersistNotifier("String", "test");
      expect(pn.value, isNot(testString));
      // sync
      pn = await PersistNotifier.create("String", "test");
      expect(pn.value, testString);
    });

    test('reading', () async {
      const List<String> emptyList = <String>[];
      expect(
          (await PersistNotifier.create("String", "test")).value, testString);
      expect((await PersistNotifier.create("bool", false)).value, testBool);
      expect((await PersistNotifier.create("int", 0)).value, testInt);
      expect((await PersistNotifier.create("double", 0.0)).value, testDouble);
      expect((await PersistNotifier.create("List", emptyList)).value, testList);
      expect((await PersistNotifier.create("bool", false)).value, testBool);
      expect((await PersistNotifier.create("int", 0)).value, testInt);
      expect((await PersistNotifier.create("double", 0.0)).value, testDouble);
      expect((await PersistNotifier.create("List", emptyList)).value, testList);
      expect(store.log, <Matcher>[]);
    });

    test('writing', () async {
      PersistNotifier stringNotifier =
          await PersistNotifier.create("String", testString);
      PersistNotifier boolNotifier =
          await PersistNotifier.create("bool", testBool);
      PersistNotifier intNotifier =
          await PersistNotifier.create("int", testInt);
      PersistNotifier doubleNotifier =
          await PersistNotifier.create("double", testDouble);
      PersistNotifier listNotifier =
          await PersistNotifier.create("List", testList);

      expect(await stringNotifier.set(testString2), true);
      expect(await boolNotifier.set(testBool2), true);
      expect(await intNotifier.set(testInt2), true);
      expect(await doubleNotifier.set(testDouble2), true);
      expect(await listNotifier.set(testList2), true);

      expect(stringNotifier.value, testString2);
      expect(boolNotifier.value, testBool2);
      expect(intNotifier.value, testInt2);
      expect(doubleNotifier.value, testDouble2);
      expect(listNotifier.value, testList2);

      expect(preferences.getString('String'), testString2);
      expect(preferences.getBool('bool'), testBool2);
      expect(preferences.getInt('int'), testInt2);
      expect(preferences.getDouble('double'), testDouble2);
      expect(preferences.getStringList('List'), testList2);
    });

    test('manager', () async {
      PersistNotifierManager manager = PersistNotifierManager();
      PersistNotifier pn0 = await PersistNotifier.create("key0", 0);
      PersistNotifier pn1 = await PersistNotifier.create("key1", 7);
      PersistNotifier pn2 = await PersistNotifier.create("key2", 14);
      manager.add(pn0);
      manager.add(pn1);
      manager.add(pn2, group: "boo");
      pn0.value = 256;
      pn1.value = 42;
      expect(manager.getAll(group: "").length, 2);
      expect(manager.getAll(group: "boo").length, 1);
      expect(manager.getAll().length, 3);
      expect(pn0.value, 256);
      expect(pn1.value, 42);
      await manager.reset();
      expect(pn0.value, 0);
      expect(pn1.value, 7);
      expect(manager.remove(pn0), true);
      expect(manager.remove(pn1), true);
      expect(manager.getAll().length, 1);
    });
  });
}

class FakeSharedPreferencesStore implements SharedPreferencesStorePlatform {
  FakeSharedPreferencesStore(Map<String, Object> data)
      : backend = InMemorySharedPreferencesStore.withData(data);

  final InMemorySharedPreferencesStore backend;
  final List<MethodCall> log = <MethodCall>[];

  @override
  bool get isMock => true;

  @override
  Future<bool> clear() {
    log.add(const MethodCall('clear'));
    return backend.clear();
  }

  @override
  Future<Map<String, Object>> getAll() {
    log.add(const MethodCall('getAll'));
    return backend.getAll();
  }

  @override
  Future<bool> remove(String key) {
    log.add(MethodCall('remove', key));
    return backend.remove(key);
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) {
    log.add(MethodCall('setValue', <dynamic>[valueType, key, value]));
    return backend.setValue(valueType, key, value);
  }

  @override
  Future<bool> clearWithParameters(ClearParameters parameters) {
    log.add(MethodCall('clearWithParameters', parameters));
    return backend.clearWithParameters(parameters);
  }

  @override
  Future<bool> clearWithPrefix(String prefix) {
    log.add(MethodCall('clearWithPrefix', prefix));
    return backend.clearWithPrefix(prefix);
  }

  @override
  Future<Map<String, Object>> getAllWithParameters(
      GetAllParameters parameters) {
    log.add(MethodCall('getAllWithParameters', parameters));
    return backend.getAllWithParameters(parameters);
  }

  @override
  Future<Map<String, Object>> getAllWithPrefix(String prefix) {
    log.add(MethodCall('getAllWithPrefix', prefix));
    return backend.getAllWithPrefix(prefix);
  }
}
