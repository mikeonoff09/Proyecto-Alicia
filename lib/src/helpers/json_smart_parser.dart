import 'dart:convert';

import 'package:flutter/foundation.dart';

class JsonObject {
  final Map<String, dynamic> data;

  JsonObject(this.data);
  factory JsonObject.fromString(String val) {
    return JsonObject(json.decode(val));
  }

  String getString(String name, {String def}) =>
      _getValue<String>(name, def: def);

  int getInt(String name, {int def}) => _getValue<int>(name, def: def);
  bool getBool(String name, {bool def}) => _getValue<bool>(name, def: def);

  double getDouble(String name, {double def}) =>
      _getValue<double>(name, def: def);

  DateTime getDateTime(String name, {DateTime def}) =>
      _getValue<DateTime>(name, def: def);

  List<T> toList<T>(ItemParser parser, List<T> def) =>
      getList<T>("/", parser, def);

  List<T> getList<T>(String name, ItemParser parser, List<T> def) {
    List<T> listResult = def;
    try {
      if (data == null) return null;
      dynamic value;
      if (name == "/") {
        value = data;
      } else {
        value = data[name];
      }
      List list = [];
      if (value == null) return def;
      if (value is String) {
        if (value.isEmpty) return def;
        list = json.decode(value) as List;
      } else {
        list = value;
      }
      listResult =
          List<T>.from(list.map((element) => parser(element) as T).toList());
    } catch (e) {
      // log(e);
    }
    return listResult;
  }

  operator [](Object key) => _getValue(key);

  T getValue<T>(Object key, {T def}) => _getValue(key, def: def);

  _getValue<T>(String name, {T def}) {
    try {
      if (data == null) return null;
      final val = data[name];
      if (val == null) return def;
      if (val is T) return val;

      if (T == String) return val?.toString() ?? def;
      //if (T is Timestamp && val is Timestamp) return val;
      if (T == int) {
        if (val is double) {
          return val.toInt();
        } else {
          return int.tryParse(val?.toString()) ?? def;
        }
      }
      if (T == double) {
        if (val is int) {
          return val?.toDouble() ?? def;
        } else {
          return double.tryParse(val?.toString()) ?? def;
        }
      }
      if (T == bool) {
        if (val is int) {
          return val == 1;
        } else if (val is String) {
          return val?.toUpperCase() == "TRUE";
        } else {
          return val ?? def;
        }
      }
      if (T == DateTime) return DateTime.parse(val);
      if (T == JsonObject) {
        if (val is String) {
          return JsonObject.fromString(val);
        } else {
          return JsonObject(val);
        }
      }
      return data[name];
    } catch (e) {
      return def;
    }
  }

  JsonObject getJsonObject(String name, {JsonObject def}) =>
      _getValue<JsonObject>(name, def: def);

  T getPojo<T>(String name, {@required ItemParser parser, T def}) {
    final r = data[name];
    if (r == null) return def;
    return parser(r) as T;
  }

  dynamic getEnum(String name, List<dynamic> options, dynamic def,
      {bool allowIntValues = false}) {
    final value = getString(name);

    if (value == null) return def;
    for (var option in options) {
      if (option?.toString()?.contains(value.toLowerCase()) ?? false) {
        return option;
      } else if (option.page == int.tryParse(value) && allowIntValues) {
        return option;
      }
    }
    return def;
  }
}

typedef ItemParser = dynamic Function(Map<String, dynamic> map);
