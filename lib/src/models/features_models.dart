// To parse this JSON data, do
//
//     final features = featuresFromJson(jsonString);

import 'dart:convert';

Features featuresFromJson(String str) => Features.fromJson(json.decode(str));

String featuresToJson(Features data) => json.encode(data.toJson());

class Features {
  Features({
    this.message,
    this.data,
    this.memory,
    this.time,
  });

  String message;
  Data data;
  int memory;
  double time;

  factory Features.fromJson(Map<String, dynamic> json) => Features(
        message: json["message"],
        data: Data.fromJson(json["data"]),
        memory: json["memory"],
        time: json["time"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data.toJson(),
        "memory": memory,
        "time": time,
      };

  @override
  String toString() {
    return this.toJson().toString();
  }
}

class Data {
  Data({
    this.psFeatureSuper,
    this.psFeature,
    this.psFeatureValue,
  });

  List<PsFeatureSuper> psFeatureSuper;
  List<PsFeature> psFeature;
  List<PsFeatureValue> psFeatureValue;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        psFeatureSuper: List<PsFeatureSuper>.from(
            json["ps_feature_super"].map((x) => PsFeatureSuper.fromJson(x))),
        psFeature: List<PsFeature>.from(
            json["ps_feature"].map((x) => PsFeature.fromJson(x))),
        psFeatureValue: List<PsFeatureValue>.from(
            json["ps_feature_value"].map((x) => PsFeatureValue.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ps_feature_super":
            List<dynamic>.from(psFeatureSuper.map((x) => x.toJson())),
        "ps_feature": List<dynamic>.from(psFeature.map((x) => x.toJson())),
        "ps_feature_value":
            List<dynamic>.from(psFeatureValue.map((x) => x.toJson())),
      };

  @override
  String toString() {
    return this.toJson().toString();
  }
}

class PsFeature {
  PsFeature({
    this.idFeature,
    this.idFeatureSuper,
    this.position,
  });

  int idFeature;
  int idFeatureSuper;
  int position;

  factory PsFeature.fromJson(Map<String, dynamic> json) => PsFeature(
        idFeature: json["id_feature"],
        idFeatureSuper: json["id_feature_super"],
        position: json["position"],
      );

  Map<String, dynamic> toJson() => {
        "id_feature": idFeature,
        "id_feature_super": idFeatureSuper,
        "position": position,
      };

  @override
  String toString() {
    return this.toJson().toString();
  }
}

class PsFeatureSuper {
  PsFeatureSuper({
    this.idFeatureSuper,
    this.position,
    this.name,
  });

  int idFeatureSuper;
  int position;
  String name;

  factory PsFeatureSuper.fromJson(Map<String, dynamic> json) => PsFeatureSuper(
        idFeatureSuper: json["id_feature_super"],
        position: json["position"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id_feature_super": idFeatureSuper,
        "position": position,
        "name": name,
      };

  @override
  String toString() {
    return this.toJson().toString();
  }
}

class PsFeatureValue {
  PsFeatureValue({
    this.idFeatureValue,
    this.idFeature,
    this.position,
    this.name,
  });

  int idFeatureValue;
  int idFeature;
  int position;
  String name;

  factory PsFeatureValue.fromJson(Map<String, dynamic> json) => PsFeatureValue(
        idFeatureValue: json["id_feature_value"],
        idFeature: json["id_feature"],
        position: json["position"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id_feature_value": idFeatureValue,
        "id_feature": idFeature,
        "position": position,
        "name": name,
      };

  @override
  String toString() {
    return this.toJson().toString();
  }
}
