import 'dart:convert';

Machine machineFromJson(String str) => Machine.fromJson(json.decode(str));

String machineToJson(Machine data) => json.encode(data.toJson());

class Machine {
  Machine({
    required this.items,
    required this.hasMore,
    required this.limit,
    required this.offset,
    required this.count,
    required this.links,
  });

  List<Machines> items;
  bool hasMore;
  int limit;
  int offset;
  int count;
  List<Link1> links;

  factory Machine.fromJson(Map<String, dynamic> json) => Machine(
        items:
            List<Machines>.from(json["items"].map((x) => Machines.fromJson(x))),
        hasMore: json["hasMore"],
        limit: json["limit"],
        offset: json["offset"],
        count: json["count"],
        links: List<Link1>.from(json["links"].map((x) => Link1.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "hasMore": hasMore,
        "limit": limit,
        "offset": offset,
        "count": count,
        "links": List<dynamic>.from(links.map((x) => x.toJson())),
      };
}

class Machines {
  Machines(
      {required this.code,
      this.nameA,
      this.nameE,
      this.name,
      required this.machineCategoryCode});

  int code;
  String? nameA;
  String? nameE;
  String? name;
  int machineCategoryCode;

  factory Machines.fromJson(Map<String, dynamic> json) => Machines(
      code: json["code"],
      nameA: json["name_a"],
      nameE: json["name_e"],
      name: json["name"],
      machineCategoryCode: json["machine_category_code"]);

  Map<String, dynamic> toJson() => {
        "code": code,
        "name_a": nameA,
        "name_e": nameE,
      };
}

class Link1 {
  Link1({
    required this.rel,
    required this.href,
  });

  String rel;
  String href;

  factory Link1.fromJson(Map<String, dynamic> json) => Link1(
        rel: json["rel"],
        href: json["href"],
      );

  Map<String, dynamic> toJson() => {
        "rel": rel,
        "href": href,
      };
}
