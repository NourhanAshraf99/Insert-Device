// To parse this JSON data, do
//
//     final machinesCategories = machinesCategoriesFromJson(jsonString);

import 'dart:convert';

MachinesCategories machinesCategoriesFromJson(String str) =>
    MachinesCategories.fromJson(json.decode(str));

String machinesCategoriesToJson(MachinesCategories data) =>
    json.encode(data.toJson());

class MachinesCategories {
  List<Category> items;
  bool hasMore;
  int limit;
  int offset;
  int count;

  MachinesCategories({
    required this.items,
    required this.hasMore,
    required this.limit,
    required this.offset,
    required this.count,
  });

  factory MachinesCategories.fromJson(Map<String, dynamic> json) =>
      MachinesCategories(
        items:
            List<Category>.from(json["items"].map((x) => Category.fromJson(x))),
        hasMore: json["hasMore"],
        limit: json["limit"],
        offset: json["offset"],
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "hasMore": hasMore,
        "limit": limit,
        "offset": offset,
        "count": count,
      };
}

class Category {
  int code;
  String name;

  Category({
    required this.code,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        code: json["code"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
      };
}
