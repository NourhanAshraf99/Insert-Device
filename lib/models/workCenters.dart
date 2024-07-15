import 'dart:convert';

WorkCenters adminWorkCentersFromJson(String str) =>
    WorkCenters.fromJson(json.decode(str));

String adminWorkCentersToJson(WorkCenters data) => json.encode(data.toJson());

class WorkCenters {
  List<WC> items;
  bool hasMore;
  int limit;
  int offset;
  int count;

  WorkCenters({
    required this.items,
    required this.hasMore,
    required this.limit,
    required this.offset,
    required this.count,
  });

  factory WorkCenters.fromJson(Map<String, dynamic> json) => WorkCenters(
        items: List<WC>.from(json["items"].map((x) => WC.fromJson(x))),
        hasMore: json["hasMore"],
        limit: json["limit"],
        offset: json["offset"],
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "items": List<WC>.from(items.map((x) => x.toJson())),
        "hasMore": hasMore,
        "limit": limit,
        "offset": offset,
        "count": count,
      };
}

class WC {
  int? code;
  String? name;

  WC({
    this.code,
    this.name,
  });

  factory WC.fromJson(Map<String, dynamic> json) => WC(
        code: json["code"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
      };
}
